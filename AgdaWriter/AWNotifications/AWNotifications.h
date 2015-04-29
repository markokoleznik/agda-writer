//
//  AWNotifications.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

extern NSString * const fontSizeChanged;
extern NSString * const fontFamilyChanged;
extern NSString * const FONT_SIZE_KEY;
extern NSString * const FONT_FAMILY_KEY;
extern NSString * const KEY_ON_TABLE_PRESSED;
extern NSString * const REMOVE_CONTROLLER;
extern NSString * const AWAgdaReplied;
extern NSString * const AWExecuteActions;
extern NSString * const AWAgdaBufferDataAvaliable;
extern NSString * const AWAgdaVersionAvaliable;
extern NSString * const AWOpenPreferences;

typedef NS_ENUM(NSInteger, KeyPressed) {
    AWEnterPressed,
    AWEscapePressed
};

@interface AWNotifications : NSObject

+ (void) notifyFontSizeChanged: (NSNumber *) fontSize;
+ (void) notifyFontFamilyChanged: (NSString *) fontFamily;
+ (void) notifyKeyReturnPressed: (NSInteger) key;
+ (void) notifyRemoveViewController: (NSViewController *) viewController;
+ (void) notifyTextChangedInRange: (NSRange) affectedRange replacementString: (NSString *) replacementString;
+ (void) notifyAgdaReplied: (NSString *) reply;
+ (void) notifyExecuteActions: (NSArray *) actions;
+ (void) notifyAgdaBufferDataAvaliable:(NSString *)buffer;
+ (void) notifyAgdaVersion:(NSString *)version;

+ (void) notifyOpenPreferences;

+ (NSDictionary *) dictionaryOfDefaults;
+ (NSString *) agdaLaunchPath;
+ (void) setAgdaLaunchPath:(NSString *)path;


@end
