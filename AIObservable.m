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

#import "AIObservable.h"


@interface AIObservable ()

@property (strong, nonatomic) NSHashTable* observers;
@property (strong, nonatomic) dispatch_queue_t queue;

@end


@implementation AIObservable

- (id)init {
	self = [super init];
	if (self) {
		self.observers = [NSHashTable weakObjectsHashTable];
        self.queue = dispatch_queue_create("AIObservable", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

- (void)addObserver:(id<NSObject>)observer {
    dispatch_async(self.queue, ^() {
        [self.observers addObject:observer];
    });
}

- (void)removeObserver:(id<NSObject>)observer {
    dispatch_async(self.queue, ^() {
        [self.observers removeObject:observer];
    });
}

- (BOOL)containsObserver:(id<NSObject>)observer {
    BOOL __block result;
    dispatch_sync(self.queue, ^() {
        result = [self.observers containsObject:observer];
    });
    return result;
}

- (void)notifyObservers:(NSInvocation*)invocation {
    dispatch_sync(self.queue, ^() {
        for (id<NSObject> observer in self.observers) {
            [self notifyObserver:observer withInvocation:invocation];
        }
    });
}

- (void)notifyObserver:(id)observer withInvocation:(NSInvocation*)invocation {
    if (![observer respondsToSelector:invocation.selector])
        return;

    [invocation setTarget:observer];
    [invocation invoke];
}

@end
