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
extern NSString * const AWAllGoals;
extern NSString * const AWPossibleAgdaPathFound;
extern NSString * const AWPlaceInsertionPointAtCharIndex;
extern NSString * const AWAgdaGaveAction;
extern NSString * const AWAgdaMakeCaseAction;
extern NSString * const AWAgdaHighlightCode;
extern NSString * const AWAgdaClearHighlighting;
extern NSString * const AWAgdaGoto;

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
+ (void) notifyAgdaReplied:(NSString *)reply sender:(id)sender;
+ (void) notifyExecuteActions:(NSArray *)actions sender:(NSViewController *)sender;
+ (void) notifyAgdaBufferDataAvaliable:(NSString *)buffer sender:(id)sender;
+ (void) notifyAgdaVersion:(NSString *)version;
+ (void) notifyAllGoals: (NSString *)allGoals  sender:(id)sender;
+ (void) notifyPossibleAgdaPathFound: (NSString *)agdaPaths;
+ (void) notifyAgdaGaveAction:(NSInteger)goalIndex content:(NSString *)content sender:(id)sender;
+ (void) notifyMakeCaseAction:(NSString *)makeCaseActions sender:(id)sender;
+ (void) notifyHighlightCode:(NSArray *)array sender:(id)sender;
+ (void) notifyClearHighlightingWithSender:(id)sender;
+ (void) notifyAgdaGotoIndex:(NSInteger)index sender:(id)sender;

+ (void) notifyPlaceInsertionPointAtCharIndex:(NSUInteger) charIndex;

+ (void) notifyOpenPreferences;

+ (NSDictionary *) dictionaryOfDefaults;
+ (NSString *) agdaLaunchPath;
+ (void) setAgdaLaunchPath:(NSString *)path;


@end
