//
//  AppDelegate.h
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AWCommunitacion.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) AWCommunitacion * communicator;
@end

