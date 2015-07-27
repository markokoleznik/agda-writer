//
//  AppDelegate.m
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AppDelegate.h"
#import "AWHelper.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.communicator = [[AWCommunitacion alloc] initForCommunicatingWithAgda];
    [self.communicator openConnectionToAgda];
    
    [AWHelper setUserDefaults];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self.communicator closeConnectionToAgda];
}

@end
