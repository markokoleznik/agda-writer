//
//  AWHelper.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AWHelper : NSObject

+ (NSFont *)defaultFontInAgda;
+ (void) saveDefaultFont:(NSFont *)font;
+ (void) setUserDefaults;
+ (BOOL) isShowingNotifications;
+ (void) setShowingNotifications:(BOOL)isShowing;
+ (NSDictionary *) keyBindings;
+ (void) saveKeyBindings: (NSDictionary *)keyBindings;
+ (void) savePathToLibraries: (NSString *)path;
+ (NSString *)pathToLibraries;
+ (CGFloat) delayForAutocomplete;


@end
