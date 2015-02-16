//
//  PKCAsyncTask.m
//  PodioFoundation
//
//  Created by Sebastian Rehnby on 28/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PKCAsyncTask.h"
#import "PKCMacros.h"
#import "NSArray+PKCAdditions.h"

typedef NS_ENUM(NSUInteger, PKCAsyncTaskState) {
  PKCAsyncTaskStatePending = 0,
  PKCAsyncTaskStateSucceeded,
  PKCAsyncTaskStateErrored,
};

@interface PKCAsyncTask ()

@property (readwrite) PKCAsyncTaskState state;
@property (strong) id result;
@property (strong, readonly) NSMutableArray *completeCallbacks;
@property (strong, readonly) NSMutableArray *successCallbacks;
@property (strong, readonly) NSMutableArray *errorCallbacks;
@property (copy) PKCAsyncTaskCancelBlock cancelBlock;
@property (strong) NSLock *stateLock;

- (void)succeedWithResult:(id)result;
- (void)failWithError:(NSError *)error;

@end

@interface PKCAsyncTaskResolver ()

// Make the task reference strong to make sure that if the resolver lives
// on (in a completion handler for example), the task does as well.
@property (strong) PKCAsyncTask *task;

- (instancetype)initWithTask:(PKCAsyncTask *)task;

@end

@implementation PKCAsyncTask {

  dispatch_once_t _resolvedOnceToken;
}

- (instancetype)init {
  self = [super init];
  if (!self) return nil;
  
  _state = PKCAsyncTaskStatePending;
  _completeCallbacks = [NSMutableArray new];
  _successCallbacks = [NSMutableArray new];
  _errorCallbacks = [NSMutableArray new];
  _stateLock = [NSLock new];
  
  return self;
}

+ (instancetype)taskForBlock:(PKCAsyncTaskResolveBlock)block {
  PKCAsyncTask *task = [self new];
  PKCAsyncTaskResolver *resolver = [[PKCAsyncTaskResolver alloc] initWithTask:task];
  task.cancelBlock = block(resolver);
  
  return task;
}

+ (instancetype)taskWithResult:(id)result {
  return [self taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:result];
    
    return nil;
  }];
}

+ (instancetype)taskWithError:(NSError *)error {
  return [self taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    [resolver failWithError:error];
    
    return nil;
  }];
}

+ (instancetype)when:(NSArray *)tasks {
  return [self taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    NSMutableSet *pendingTasks = [NSMutableSet setWithArray:tasks];
    
    NSUInteger taskCount = [tasks count];
    NSMutableDictionary *results = [NSMutableDictionary new];
    
    // We need a lock to synchronize access to the results dictionary and remaining tasks set.
    NSLock *lock = [NSLock new];
    
    void (^cancelRemainingBlock) (void) = ^{
      // Clear the backlog of tasks and cancel remaining ones.
      [lock lock];
      
      NSSet *tasksToCancel = [pendingTasks copy];
      [pendingTasks removeAllObjects];
      
      for (PKCAsyncTask *task in tasksToCancel) {
        [task cancel];
      }
      
      [lock unlock];
    };
    
    NSUInteger pos = 0;
    for (PKCAsyncTask *task in tasks) {
      
      [task onSuccess:^(id result) {
        id res = result ?: [NSNull null];
        
        [lock lock];
        
        // Add the result to the results dictionary at the original position of the task,
        // and remove the task from the list of pending tasks to avoid it from being
        // cancelled if the combined task is cancelled later.
        results[@(pos)] = res;
        [pendingTasks removeObject:task];
        
        [lock unlock];
        
        if ([pendingTasks count] == 0) {
          // All tasks have completed, collect the results and sort them in the
          // tasks' original ordering
          NSArray *positions = [NSArray pkc_arrayFromRange:NSMakeRange(0, taskCount)];
          NSArray *orderedResults = [positions pkc_mappedArrayWithBlock:^id(NSNumber *pos) {
            return results[pos];
          }];
          
          [resolver succeedWithResult:orderedResults];
        }
      } onError:^(NSError *error) {
        cancelRemainingBlock();
        
        [resolver failWithError:error];
      }];
      
      ++pos;
    }
    
    return cancelRemainingBlock;
  }];
}

- (instancetype)then:(PKCAsyncTaskThenBlock)thenBlock {
  return [PKCAsyncTask taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    [self onSuccess:^(id result) {
      thenBlock(result, nil);
      [resolver succeedWithResult:result];
    } onError:^(NSError *error) {
      thenBlock(nil, error);
      [resolver failWithError:error];
    }];
    
    PKC_WEAK_SELF weakSelf = self;
    
    return ^{
      [weakSelf cancel];
    };
  }];
}

- (instancetype)map:(id (^)(id result))block {
  return [PKCAsyncTask taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    
    [self onSuccess:^(id result) {
      id mappedResult = block ? block(result) : result;
      [resolver succeedWithResult:mappedResult];
    } onError:^(NSError *error) {
      [resolver failWithError:error];
    }];
    
    PKC_WEAK_SELF weakSelf = self;
    
    return ^{
      [weakSelf cancel];
    };
  }];
}

- (instancetype)pipe:(PKCAsyncTask *(^)(id result))block {
  NSParameterAssert(block);
  
  return [[self class] taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    __block PKCAsyncTask *pipedTask = nil;
    
    [self onSuccess:^(id result1) {
      pipedTask = block(result1);
      
      [pipedTask onSuccess:^(id result2) {
        [resolver succeedWithResult:result2];
      } onError:^(NSError *error) {
        [resolver failWithError:error];
      }];
    } onError:^(NSError *error) {
      [resolver failWithError:error];
    }];
    
    // Cancel both tasks in the case of the parent task being cancelled.
    PKC_WEAK_SELF weakSelf = self;
    PKC_WEAK(pipedTask) weakPipedTask = pipedTask;
    
    return ^{
      [weakSelf cancel];
      [weakPipedTask cancel];
    };
  }];
}

#pragma mark - Properties

- (BOOL)completed {
  return self.state != PKCAsyncTaskStatePending;
}

- (BOOL)succeeded {
  return self.state == PKCAsyncTaskStateSucceeded;
}

- (BOOL)errored {
  return self.state == PKCAsyncTaskStateErrored;
}

#pragma mark - KVO

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSMutableSet *keyPaths = [[super keyPathsForValuesAffectingValueForKey:key] mutableCopy];
  
  NSArray *keysAffectedByState = @[
                                   NSStringFromSelector(@selector(completed)),
                                   NSStringFromSelector(@selector(succeeded)),
                                   NSStringFromSelector(@selector(errored))
                                   ];
  
  if ([keysAffectedByState containsObject:key]) {
		[keyPaths addObject:NSStringFromSelector(@selector(state))];
  }
  
	return [keyPaths copy];
}

#pragma mark - Register callbacks

- (instancetype)onComplete:(PKCAsyncTaskCompleteBlock)completeBlock {
  NSParameterAssert(completeBlock);
  
  [self performSynchronizedBlock:^{
    if (self.succeeded) {
      completeBlock(self.result, nil);
    } else if (self.errored) {
      completeBlock(nil, self.result);
    } else {
      [self.completeCallbacks addObject:[completeBlock copy]];
    }
  }];
  
  return self;
}

- (instancetype)onSuccess:(void (^)(id x))successBlock {
  NSParameterAssert(successBlock);
  
  [self performSynchronizedBlock:^{
    if (self.completed) {
      if (self.succeeded) {
        successBlock(self.result);
      }
    } else {
      [self.successCallbacks addObject:[successBlock copy]];
    }
  }];
  
  return self;
}

- (instancetype)onError:(void (^)(NSError *error))errorBlock {
  NSParameterAssert(errorBlock);
  
  [self performSynchronizedBlock:^{
    if (self.completed) {
      if (self.errored) {
        errorBlock(self.result);
      }
    } else {
      [self.errorCallbacks addObject:[errorBlock copy]];
    }
  }];
  
  return self;
}

- (instancetype)onSuccess:(PKCAsyncTaskSuccessBlock)successBlock onError:(PKCAsyncTaskErrorBlock)errorBlock {
  [self onSuccess:successBlock];
  [self onError:errorBlock];
  
  return self;
}

#pragma mark - Resolve

- (void)succeedWithResult:(id)result {
  [self resolveWithState:PKCAsyncTaskStateSucceeded result:result];
}

- (void)failWithError:(NSError *)error {
  [self resolveWithState:PKCAsyncTaskStateErrored result:error];
}

- (void)resolveWithState:(PKCAsyncTaskState)state result:(id)result {
  dispatch_once(&_resolvedOnceToken, ^{
    [self performSynchronizedBlock:^{
      self.state = state;
      self.result = result;
      
      if (state == PKCAsyncTaskStateSucceeded) {
        [self performSuccessCallbacksWithResult:result];
        [self performCompleteCallbacksWithResult:result error:nil];
      } else if (state == PKCAsyncTaskStateErrored) {
        [self performErrorCallbacksWithError:result];
        [self performCompleteCallbacksWithResult:nil error:result];
      }
      
      [self removeAllCallbacks];
    }];
  });
}

- (void)performSuccessCallbacksWithResult:(id)result {
  for (PKCAsyncTaskSuccessBlock callback in self.successCallbacks) {
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(self.result);
    });
  }
}

- (void)performErrorCallbacksWithError:(NSError *)error {
  for (PKCAsyncTaskErrorBlock callback in self.errorCallbacks) {
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(self.result);
    });
  }
}

- (void)performCompleteCallbacksWithResult:(id)result error:(NSError *)error {
  for (PKCAsyncTaskCompleteBlock callback in self.completeCallbacks) {
    dispatch_async(dispatch_get_main_queue(), ^{
      callback(result, error);
    });
  }
}

- (void)removeAllCallbacks {
  [self.successCallbacks removeAllObjects];
  [self.errorCallbacks removeAllObjects];
  [self.completeCallbacks removeAllObjects];
  self.cancelBlock = nil;
}

- (void)cancel {
  if (self.cancelBlock) {
    self.cancelBlock();
    self.cancelBlock = nil;
  }
}

#pragma mark - Helpers

- (void)performSynchronizedBlock:(void (^)(void))block {
  NSParameterAssert(block);
  
  [self.stateLock lock];
  block();
  [self.stateLock unlock];
}

@end

@implementation PKCAsyncTaskResolver

- (instancetype)initWithTask:(PKCAsyncTask *)task {
  self = [super init];
  if (!self) return nil;
  
  _task = task;
  
  return self;
}

- (void)succeedWithResult:(id)result {
  [self.task succeedWithResult:result];
  self.task = nil;
}

- (void)failWithError:(NSError *)error {
  [self.task failWithError:error];
  self.task = nil;
}

@end