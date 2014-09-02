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
@property (strong, nonatomic) NSHashTable* pendingAdds;
@property (strong, nonatomic) NSHashTable* pendingRemoves;
@property (nonatomic) BOOL notifying;

@end


@implementation AIObservable

- (id)init {
	self = [super init];
	if (self) {
		self.observers = [NSHashTable weakObjectsHashTable];
		self.pendingAdds = [NSHashTable weakObjectsHashTable];
		self.pendingRemoves = [NSHashTable weakObjectsHashTable];
	}
	return self;
}

- (void)addObserver:(id<NSObject>)observer {
	if (self.notifying) {
		// The main set cannot be mutated while iterating, add to a secondary set
		// to be processed when the iteration finishes
		[self.pendingRemoves removeObject:observer];
		[self.pendingAdds addObject:observer];
	} else {
		[self.observers addObject:observer];
	}
}

- (void)removeObserver:(id<NSObject>)observer {
	if (self.notifying) {
		// The main set cannot be mutated while iterating, add to a secondary set
		// to be processed when the iteration finishes
		[self.pendingAdds removeObject:observer];
		[self.pendingRemoves addObject:observer];
	} else {
		[self.observers removeObject:observer];
	}
}

- (BOOL)containsObserver:(id<NSObject>)observer {
	return ([self.observers containsObject:observer] && ![self.pendingRemoves containsObject:observer]) ||
		[self.pendingAdds containsObject:observer];
}

- (void)notifyObservers:(NSInvocation*)invocation {
	self.notifying = YES;
	for (id<NSObject> observer in self.observers) {
		if (![self.pendingRemoves containsObject:observer] && [observer respondsToSelector:[invocation selector]]) {
			[invocation setTarget:observer];
			[invocation invoke];
		}
	}
	self.notifying = NO;
	[self commitPending];
}

- (void)commitPending {
	NSAssert(!self.notifying, @"Tried to commit pending observers while notifying");
	for (id<NSObject> observer in self.pendingRemoves)
		[self.observers removeObject:observer];
	[self.pendingRemoves removeAllObjects];

	for (id<NSObject> observer in self.pendingAdds)
		[self.observers addObject:observer];
	[self.pendingAdds removeAllObjects];
}

@end
