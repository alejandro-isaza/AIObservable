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

#import <XCTest/XCTest.h>
#import "AIObservable.h"
#import "NSInvocation+AIConstructors.h"


#pragma mark -
#pragma mark ObserverProtocol
@protocol ObservableTest_ObserverProtocol
- (void)notification;
@optional
- (void)notificationWithInt:(int)i;
@end


#pragma mark -
#pragma mark Observable
@interface ObservableTest_Observable : AIObservable
@end

@implementation ObservableTest_Observable
@end


#pragma mark -
#pragma mark Basic Observer
@interface ObservableTest_Observer : NSObject <ObservableTest_ObserverProtocol>
@property (nonatomic) BOOL notified;
@end

@implementation ObservableTest_Observer
- (void)notification {
	self.notified = YES;
}
@end


#pragma mark -
#pragma mark Extended Observer
@interface ObservableTest_ExtendedObserver : NSObject <ObservableTest_ObserverProtocol>
@property (nonatomic) BOOL notified;
@end

@implementation ObservableTest_ExtendedObserver
- (void)notification {
	self.notified = YES;
}
- (void)notificationWithInt:(int)i {
	self.notified = YES;
}
@end


#pragma mark -
#pragma mark Removing Observer
@interface ObservableTest_RemovingObserver : NSObject <ObservableTest_ObserverProtocol>
@property (weak, nonatomic) AIObservable* observable;
@property (weak, nonatomic) ObservableTest_Observer* observerToRemove;
@property (nonatomic) BOOL notified;
@end

@implementation ObservableTest_RemovingObserver

- (void)notification {
	self.notified = YES;
	[self.observable removeObserver:self.observerToRemove];
}

@end


#pragma mark -
#pragma mark Adding Observer
@interface ObservableTest_AddingObserver : NSObject <ObservableTest_ObserverProtocol>
@property (weak, nonatomic) AIObservable* observable;
@property (weak, nonatomic) id<NSObject> observerToAdd;
@property (nonatomic) BOOL notified;
@end

@implementation ObservableTest_AddingObserver
- (void)notification {
	self.notified = YES;
	[self.observable addObserver:self.observerToAdd];
}
@end



#pragma mark -
#pragma mark ObservableTest
@interface ObservableTest : XCTestCase
@end

@implementation ObservableTest

- (void)testNotification {
	ObservableTest_Observer* observer = [[ObservableTest_Observer alloc] init];
	ObservableTest_Observable* observable = [[ObservableTest_Observable alloc] init];
	
	[observable addObserver:observer];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
                                                            selector:@selector(notification)]];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);

	XCTAssertTrue(observer.notified, @"The observer should have been notified");
}

- (void)testOptionalNotification {
	ObservableTest_Observer* observer1 = [[ObservableTest_Observer alloc] init];
	ObservableTest_ExtendedObserver* observer2 = [[ObservableTest_ExtendedObserver alloc] init];
	ObservableTest_Observable* observable = [[ObservableTest_Observable alloc] init];
	
	[observable addObserver:observer1];
	[observable addObserver:observer2];
	
	NSInvocation* inv = [NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
													selector:@selector(notificationWithInt:)];
	int i = 3;
	[inv setArgument:&i atIndex:2];
    [observable notifyObservers:inv];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);
	
	// 'observer1' does not implement the optional method, so it should not be notified
	XCTAssertFalse(observer1.notified, @"The first observer should not have been notified");
	XCTAssertTrue(observer2.notified, @"The second observer should have been notified");
}

- (void)testObserverRemoving {
	ObservableTest_Observer* observer1 = [[ObservableTest_Observer alloc] init];
	ObservableTest_Observer* observer2 = [[ObservableTest_Observer alloc] init];
	ObservableTest_Observable* observable = [[ObservableTest_Observable alloc] init];
	
	[observable addObserver:observer1];
	[observable addObserver:observer2];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
                                                            selector:@selector(notification)]];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);
	
	// Both observers are notified
	XCTAssertTrue(observer1.notified, @"The first observer should have been notified");
	XCTAssertTrue(observer2.notified, @"The second observer should have been notified");
	
	observer1.notified = NO;
	observer2.notified = NO;
	[observable removeObserver:observer1];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
                                                            selector:@selector(notification)]];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);
	
	// After removing 'observer2' it is no longer notified
	XCTAssertFalse(observer1.notified, @"The removed observer should not have been notified");
	XCTAssertTrue(observer2.notified, @"The second observer should have been notified");
}

- (void)testLiveRemoval {
	ObservableTest_Observer* observer = [[ObservableTest_Observer alloc] init];
	ObservableTest_RemovingObserver* removingObserver = [[ObservableTest_RemovingObserver alloc] init];
	ObservableTest_Observable* observable = [[ObservableTest_Observable alloc] init];
	
	// when it gets a notification 'removingObserver' will remove 'observer' from the notification list
	removingObserver.observable = observable;
	removingObserver.observerToRemove = observer;
	
	[observable addObserver:removingObserver];
	[observable addObserver:observer];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
                                                            selector:@selector(notification)]];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);
	
	// Both observers should be notified but afterwards 'observer' should be removed fron the observable
    XCTAssertTrue(removingObserver.notified, @"Removing observer should have been notified");
    XCTAssertTrue(observer.notified, @"Observer should have been notified");
    XCTAssertTrue(![observable containsObserver:observer]);
}

- (void)testLiveAddition {
	ObservableTest_Observer* observer = [[ObservableTest_Observer alloc] init];
	ObservableTest_AddingObserver* addingObserver = [[ObservableTest_AddingObserver alloc] init];
	ObservableTest_Observable* observable = [[ObservableTest_Observable alloc] init];
	
	// when it gets a notification 'addingObserver' will add 'observer' to the notification list
	addingObserver.observable = observable;
	addingObserver.observerToAdd = observer;
	
	[observable addObserver:addingObserver];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
                                                            selector:@selector(notification)]];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);
	
	// 'observer' is not notified on the first run, it was just added
	XCTAssertFalse(observer.notified, @"The added observer should not have been notified");
	XCTAssertTrue(addingObserver.notified, @"The adding observer should have been notified");
	
	addingObserver.notified = NO;
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
                                                            selector:@selector(notification)]];
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, NO);
	
	// But it's notified on the second run
	XCTAssertTrue(observer.notified, @"The added observer should have been notified");
	XCTAssertTrue(addingObserver.notified, @"The adding observer should have been notified");
}

@end
