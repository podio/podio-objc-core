//
//  PodioKitExtensions.swift
//  PodioKit
//
//  Created by Sebastian Rehnby on 21/04/15.
//  Copyright (c) 2015 Citrix Systems, Inc. All rights reserved.
//

extension PKTAsyncTask {
  
  func onSuccess<ResultType>(successBlock: ResultType! -> Void) -> Self {
    return onSuccess { obj in
      let typedObj = obj as? ResultType
      successBlock(typedObj)
    }
  }
  
  func then<ResultType>(thenBlock: (ResultType?, NSError?) -> Void) -> Self {
    return then { (obj, error) in
      let typedObj = obj as? ResultType
      thenBlock(typedObj, error)
    }
  }
  
  func onComplete<ResultType>(completeBlock: (ResultType?, NSError?) -> Void) -> Self {
    return onComplete { (obj, error) in
      let typedObj = obj as? ResultType
      completeBlock(typedObj, error)
    }
  }
  
  func pipe<ResultType>(mapBlock: (ResultType!) -> PKTAsyncTask) -> Self {
    return pipe { obj in
      let typedObj = obj as? ResultType
      return mapBlock(typedObj)
    }
  }
}
