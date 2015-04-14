# AIObservable

The `AIObservable` class lets you to dispatch events to a list of observers. It's an implementation of the *Observer* design pattern. You can add and remove observers even within the notification callback and from multiple threads or queues.

This implementation has a few advantages over `NSNotificationCenter`:
* You don't need to call `removeObserver:` on the observer's dealloc, `AIObservable` uses zeroing weak references.
* When the observable is destroyed all observers are automatically removed.
* Each observable object keeps its own set of observers. This makes it easier to debug.
* I like having an observer protocol for each class that is observable. A protocol allows you to better document each event that the observable class can dispatch and what parameters it has. It also gives meaningul names to the methods. For instance `collection:didAddObject:atIndex:` as opposed to `didAddObject:(NSNotification*)notification`.

## Known Issues

`AIObservable` is currently not (fully) compatible with Swift because Swift doesn't support invocations. I don't have any plans to fix this on this project as it would require a completly different approach. You can still use it in Swift but your classes (both observers and observables) need to inherit from `NSObject`.

## Example

As an example suppose you have a chat room. The chat room object dispatches obseravable events when messages are added and people join and leave the room.

```objc
@class AIMessage;
@class AIUser;
@protocol AIChatRoomObserver;


@interface AIChatRoom : NSObject 

- (void)postMessage:(AIMessage*)message;
// ...

- (void)addObserver:(id<AIChatRoomObserver>)observer;
- (void)removeObserver:(id<AIChatRoomObserver>)observer;

@end


@protocol AIChatRoomObserver

@optional
- (void)chatRoom:(AIChatRoom*)room didGetNewMessage:(AIMessage*)message;
- (void)chatRoom:(AIChatRoom*)room userDidJoin:(AIUser*)user;
- (void)chatRoom:(AIChatRoom*)room userDidLeave:(AIUser*)user;

@end
```

As you can see everything has a clear intent and the observer methods are self-documenting. Here is the implementation:

```objc
#import <AIObservable.h>
#import <NSInvocation+AIConstructors.h>

@interface AIChatRoom ()

// We use composition but you could also use inheritance
@property (nonatomic, strong) AIObservable* observable;

@end


@implementation AIChatRoom

- (void)postMessage:(AIMessage*)message {
    // ...

    // Create an invocation that will be dispatched to every observer
    AIChatRoom* chatRoom = self;
    NSInvocation* invocation = [NSInvocation invocationWithProtocol:@protocol(AIChatRoomObserver)
                                                           selector:@selector(chatRoom:didGetNewMessage:)];
    [invocation setArgument:&chatRoom atIndex:2];
    [invocation setArgument:&message atIndex:3];
    [self.observable notifyObservers:invocation];
}

- (void)addObserver:(id<AIChatRoomObserver>)observer {
    [self.observable addObserver:observer];
}

- (void)removeObserver:(id<AIChatRoomObserver>)observer {
    [self.observable removeObserver:observer];
}

@end
```

## Installation

Copy the source files to your project or add `pod 'AIObservable'` to your Podfile.
