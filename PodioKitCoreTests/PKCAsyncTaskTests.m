//
//  PKCAsyncTaskTests.m
//  PodioFoundation
//
//  Created by Sebastian Rehnby on 28/07/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PKCAsyncTask.h"

@interface PKCAsyncTaskTests : XCTestCase

@end

@implementation PKCAsyncTaskTests

- (void)testCanOnlySucceed {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@"Value1"];
  }];
  
  __block BOOL finished = NO;
  __block BOOL errored = NO;
  
  [task onSuccess:^(id x) {
    finished = YES;
  }];
  
  [task onError:^(NSError *error) {
    errored = YES;
  }];
  
  expect(finished).will.beTruthy();
  expect(errored).notTo.beTruthy();
}

- (void)testCanOnlyError {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver failWithError:[NSError errorWithDomain:@"PodioFoundation" code:0 userInfo:nil]];
  }];
  
  __block BOOL finished = NO;
  __block BOOL errored = NO;
  
  [task onSuccess:^(id x) {
    finished = YES;
  }];
  
  [task onError:^(NSError *error) {
    errored = YES;
  }];
  
  expect(errored).will.beTruthy();
  expect(finished).notTo.beTruthy();
}

- (void)testComplete {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@"Value1"];
  }];
  
  __block id taskResult = nil;
  __block NSError *taskError = nil;
  
  [task onComplete:^(id result, NSError *error) {
    taskResult = result;
    taskError = error;
  }];

  expect(taskResult).willNot.beNil();
  expect(taskError).to.beNil();
}

- (void)testCanOnlyFinishOnlyOnce {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@"Value1"];
    [resolver succeedWithResult:@"Value2"];
  }];
  
  __block id value = nil;
  [task onSuccess:^(id x) {
    value = x;
  }];
  
  expect(value).will.equal(@"Value1");
}

- (void)testCanOnlyFinishForMultipleCallbacks {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@[]];
  }];
  
  __block BOOL completed1 = NO;
  [task onSuccess:^(id x) {
    completed1 = YES;
  }];
  
  __block BOOL completed2 = NO;
  [task onSuccess:^(id x) {
    completed2 = YES;
  }];
  
  expect(completed1).will.beTruthy();
  expect(completed2).will.beTruthy();
}

- (void)testMap {
  PKCAsyncTask *arrayTask = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@[@1, @2, @3]];
  }];
  
  PKCAsyncTask *task = [arrayTask map:^id(NSArray *array) {
    return @10;
  }];
  
  __block id value = nil;
  [task onSuccess:^(id result) {
    value = result;
  }];
  
  expect(value).will.equal(@10);
}

- (void)testWhen {
  PKCAsyncTask *task1 = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@1];
  }];
  PKCAsyncTask *task2 = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@2];
  }];
  
  __block id mergedResult = nil;
  [[PKCAsyncTask when:@[task1, task2]] onSuccess:^(id result) {
    mergedResult = result;
  }];
  
  expect(mergedResult).will.equal(@[@1, @2]);
}

- (void)testFailingFirstOfWhenTasksWillFailOuterTask {
  PKCAsyncTask *task1 = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver failWithError:[NSError errorWithDomain:@"PodioKit" code:0 userInfo:nil]];
  }];
  
  PKCAsyncTask *task2 = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@2];
  }];

  __block BOOL task2Failed = NO;
  [task2 onError:^(NSError *error) {
    task2Failed = YES;
  }];
  
  PKCAsyncTask *mergedTask = [PKCAsyncTask when:@[task1, task2]];
  
  __block NSError *mergedError = nil;
  [mergedTask onError:^(NSError *error) {
    mergedError = error;
  }];
  
  expect(mergedError).willNot.beNil();
}

- (void)testPipe {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@3];
  }];
  
  PKCAsyncTask *pipedTask = [task pipe:^PKCAsyncTask *(NSNumber *num) {
    return [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
      NSUInteger number =  [num unsignedIntegerValue];
      [resolver succeedWithResult:@(number * number)];
    }];
  }];
  
  __block NSNumber *pipedTaskValue = nil;
  [pipedTask onSuccess:^(id result) {
    pipedTaskValue = result;
  }];
  
  expect(pipedTaskValue).will.equal(@9);
}

- (void)testCancellingPipedTaskShouldCancelOriginalTasks {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@3];
  }];
  
  PKCAsyncTask *pipedTask = [task pipe:^PKCAsyncTask *(NSNumber *num) {
    return [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
      NSUInteger number =  [num unsignedIntegerValue];
      [resolver succeedWithResult:@(number * number)];
    }];
  }];

  __block NSError *taskError = nil;
  [task onError:^(NSError *error) {
    taskError = error;
  }];
  
  __block NSError *pipedError = nil;
  [pipedTask onError:^(NSError *error) {
   pipedError = error;
  }];
  
  [pipedTask cancel];
   
  expect(pipedError).willNot.beNil();
  expect(taskError).willNot.beNil();
}

- (void)testThen {
  PKCAsyncTask *task = [self taskWithCompletion:^(PKCAsyncTaskResolver *resolver) {
    [resolver succeedWithResult:@YES];
  }];
  
  __block BOOL then1Finished = NO;
  task = [task then:^(id result, NSError *error) {
    then1Finished = YES;
  }];
  
  __block BOOL then2Finished = NO;
  task = [task then:^(id result, NSError *error) {
    then2Finished = YES;
  }];
  
  __block BOOL thensFinishedBeforeSuccess = NO;
  [task onSuccess:^(id result) {
    thensFinishedBeforeSuccess = then1Finished && then2Finished;
  }];
  
  __block BOOL thensFinishedBeforeComplete = YES;
  [task onComplete:^(id result, NSError *error) {
    thensFinishedBeforeComplete = then1Finished && then2Finished;
  }];
  
  // Check that the side effects of the then: blocks were executed before the success and complete callbacks.
  expect(thensFinishedBeforeSuccess).will.beTruthy();
  expect(thensFinishedBeforeComplete).will.beTruthy();
}

#pragma mark - Helpers

- (PKCAsyncTask *)taskWithCompletion:(void (^)(PKCAsyncTaskResolver *resolver))completion {
  return [PKCAsyncTask taskForBlock:^PKCAsyncTaskCancelBlock(PKCAsyncTaskResolver *resolver) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
          if (completion) completion(resolver);
        });
      });
    });
    
    return ^{
      [resolver failWithError:[NSError errorWithDomain:@"PodioKit" code:0 userInfo:nil]];
    };
  }];
}

@end
