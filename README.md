# AIObservable

AIObservable is an implementation of the observer pattern in Objective-C. It handles a set of observers and dispatches notifications, handling the case where observers are added or removed in the notification callback. 

One question you may have is why not just use `NSNotificationCenter`? There are several reasons why I prefer this approach:

* You don't need to call `removeObserver:` on dealloc, `AIObservable` uses weak pointers.
* Each observable object keeps its own set of observers. This makes it easier to debug. Also when the observable is destroyed all observers are automatically removed.
* I like having an observer protocol for each class that is observable. A protocol allows you to better document each event that the observable class can dispatch and what parameters it has. It also gives meaningul names to the methods. For instance `collection:didAddObject:atIndex:` as opposed to `didAddObject:(NSNotification*)notification`.

For more (somewhat outdated) information see the [blog post](http://a-coding.com/observer-pattern-in-objective-c/).


## Usage
Copy the source files to your project or add `pod 'AIObservable'` to your Podfile.
