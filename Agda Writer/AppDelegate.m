//
//  AppDelegate.m
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AppDelegate.h"
#import "AWHelper.h"
#import "AWNotifications.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
    // check for agda!
    if ([[AWNotifications agdaLaunchPath] isEqualToString:@""]) {
        // agda path is not yet set
        NSArray * reasonablePlacesForAgda = @[@"~/.cabal/bin/agda", @"~/Library/Haskell/bin/agda", @"/Library/Haskell/bin/agda"];
        for (NSString * path in reasonablePlacesForAgda) {
            
            if ([self isAgdaAvaliableAtPath:path]) {
                [AWNotifications setAgdaLaunchPath:path];
                break;
            }
        }
    }
    
    
    
    self.communicator = [[AWCommunitacion alloc] initForCommunicatingWithAgda];
    [self.communicator openConnectionToAgda];
    [AWHelper setUserDefaults];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self.communicator closeConnectionToAgda];
}

#pragma mark -
-(BOOL)isAgdaAvaliableAtPath:(NSString *)path
{
    AWCommunitacion * agdaComm = [[AWCommunitacion alloc] init];
    return [agdaComm isAgdaAvaliableAtPath:path];
    
}

@end
