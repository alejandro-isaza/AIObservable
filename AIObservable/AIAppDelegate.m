//  Created by Alejandro Isaza on 2014-09-02.
//  Copyright (c) 2014 Alejandro Isaza. All rights reserved.

#import "AIAppDelegate.h"

@implementation AIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
