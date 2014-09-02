//  Copyright 2010 Alejandro Isaza.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.

#import <Foundation/Foundation.h>


/**
 AIObservable manages a set of observers and dispatches notifications. It will handle
 the case where an observer is added or removed in an observer notification. Observers
 are not retained. This class is not thread safe.
 */
@interface AIObservable : NSObject

- (void)addObserver:(id<NSObject>)observer;
- (void)removeObserver:(id<NSObject>)observer;
- (BOOL)containsObserver:(id<NSObject>)observer;

- (void)notifyObservers:(NSInvocation*)invocation;

@end
