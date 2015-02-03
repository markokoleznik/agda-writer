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


@end
