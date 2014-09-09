# AIObservable

AIObservable is an implementation of the observer pattern in Objective-C. It handles a set of observers and dispatches notifications, handling the case where observers are added or removed in the notification callback. 

One question you may have is why not just use `NSNotificationCenter`? There are several reasons why I prefer this approach:

* You don't need to call `removeObserver:` on dealloc, `AIObservable` uses weak pointers.
* Each observable object keeps its own set of observers. This makes it easier to debug. Also when the observable is destroyed all observers are automatically removed.
* I like having an observer protocol for each class that is observable. A protocol allows you to better document each event that the observable class can dispatch and what parameters it has. It also gives meaningul names to the methods. For instance `collection:didAddObject:atIndex:` as opposed to `didAddObject:(NSNotification*)notification`.

For more (somewhat outdated) information see the [blog post](http://a-coding.com/observer-pattern-in-objective-c/).

## Example

As an eample suppose you have a chat room. The chat room object dispatches obseravable events when messages are added and people join and leave the room.

```objc
#import <AIObservable.h>
#import <NSInvocation+AIConstructors.h>

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

## Usage
Copy the source files to your project or add `pod 'AIObservable'` to your Podfile.
