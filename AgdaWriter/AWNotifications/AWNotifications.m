//
//  AWNotifications.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWNotifications.h"

NSString * const fontSizeChanged = @"net.koleznik.fontSizeChanged";
NSString * const fontFamilyChanged = @"net.koleznik.fontFamilyChanged";
NSString * const FONT_SIZE_KEY = @"fontSize";
NSString * const FONT_FAMILY_KEY = @"fontFamily";
NSString * const KEY_ON_TABLE_PRESSED = @"net.koleznik.keyReturnPressed";
NSString * const REMOVE_CONTROLLER = @"net.koleznik.removeController";
NSString * const AWAgdaReplied = @"net.koleznik.agdaReplied";




@implementation AWNotifications


+ (void) notifyFontSizeChanged: (NSNumber *) fontSize
{
    [[NSNotificationCenter defaultCenter] postNotificationName:fontSizeChanged object:fontSize];
}

+ (void) notifyFontFamilyChanged: (NSString *) fontFamily
{
    [[NSNotificationCenter defaultCenter] postNotificationName:fontFamilyChanged object:fontFamily];
}

+ (void) notifyKeyReturnPressed: (NSInteger) key;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_ON_TABLE_PRESSED object:[NSNumber numberWithInteger:key]];
}

+ (void) notifyRemoveViewController:(NSViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_CONTROLLER object:viewController];
}

+ (void) notifyTextChangedInRange: (NSRange) affectedRange replacementString: (NSString *) replacementString
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"textChangedInRangeWithReplacementString" object:@{@"range":[NSValue valueWithRange:affectedRange], @"replacementString":replacementString}];
}

+ (void) notifyAgdaReplied:(NSString *)reply
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaReplied object:reply];
}

@end
