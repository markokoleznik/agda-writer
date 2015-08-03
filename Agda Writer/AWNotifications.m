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
NSString * const AWExecuteActions = @"net.koleznik.executeActions";
NSString * const AWAgdaBufferDataAvaliable = @"net.koleznik.agdaBufferDataAvaliable";
NSString * const AWAgdaVersionAvaliable = @"net.koleznik.agdaVersionAvaliable";
NSString * const AWOpenPreferences = @"net.koleznik.openPreferences";
NSString * const AWAllGoals = @"net.koleznik.allGoals";
NSString * const AWPossibleAgdaPathFound = @"net.koleznik.possibleAgdaPathFound";
NSString * const AWPlaceInsertionPointAtCharIndex = @"net.koleznik.placeInsertionPointAtCharIndex";
NSString * const AWAgdaGaveAction = @"net.koleznik.AgdaGaveAction";
NSString * const AWAgdaMakeCaseAction = @"net.koleznik.AgdaMakeCaseAction";
NSString * const AWAgdaHighlightCode = @"net.koleznik.AgdaHighlightCode";
NSString * const AWAgdaClearHighlighting = @"net.koleznik.AgdaClearHighlighting";
NSString * const AWAgdaGoto = @"net.koleznik.AgdaGoto";
NSString * const AWSelectAgdaRange = @"net.koleznik.SelectAgdaRange";



@implementation AWNotifications

+ (void) notifyClearHighlightingWithSender:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaClearHighlighting object:sender];
}
+ (void) notifyHighlightCode:(NSArray *)array sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaHighlightCode object:sender userInfo:@{@"actions" : array}];
}

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

+ (void) notifyAgdaReplied:(NSString *)reply sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaReplied object:reply];
}

+ (void) notifyAgdaGaveAction:(NSInteger)goalIndex content:(NSString *)content sender:(id)sender
{
    NSDictionary * action = @{@"goalIndex" : @(goalIndex), @"content": content};
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaGaveAction object:sender userInfo:@{@"action" : action}];
}

+ (NSURL *) defaultUrl
{
    return [[NSBundle mainBundle] URLForResource:@"defaults" withExtension:@"plist"];
}

+ (NSDictionary *) dictionaryOfDefaults
{
    NSDictionary *plistContent = [NSDictionary dictionaryWithContentsOfURL: [self defaultUrl]];
    
    return plistContent;
}

+ (void) setAgdaLaunchPath:(NSString *)path
{
    NSDictionary *plistContent = [self dictionaryOfDefaults];
    [plistContent setValue:path forKey:@"agdaLaunchPath"];
    [plistContent writeToURL:[self defaultUrl] atomically:YES];
}

+ (NSString *) agdaLaunchPath
{
    NSDictionary *plistContent = [self dictionaryOfDefaults];
    return [plistContent objectForKey:@"agdaLaunchPath"];
    
}

+ (void) notifyExecuteActions:(NSArray *)actions sender:(NSViewController *)sender;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWExecuteActions object:sender userInfo:@{@"actions" : actions}];
}

+ (void) notifyAgdaBufferDataAvaliable:(NSString *)buffer sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaBufferDataAvaliable object:sender userInfo:@{@"buffer" : buffer}];
}

+ (void)notifyAgdaVersion:(NSString *)version
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaVersionAvaliable object:version];
}

+ (void) notifyOpenPreferences {
    [[NSNotificationCenter defaultCenter] postNotificationName:AWOpenPreferences object:nil];
}

+ (void) notifyAllGoals: (NSString *)allGoals  sender:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAllGoals object:sender userInfo:@{@"goals" : allGoals}];
}

+ (void) notifyPossibleAgdaPathFound:(NSString *)agdaPaths
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWPossibleAgdaPathFound object:agdaPaths];
}

+ (void) notifyPlaceInsertionPointAtCharIndex:(NSUInteger) charIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWPlaceInsertionPointAtCharIndex object:[NSNumber numberWithUnsignedInteger:charIndex]];
}

+(void) notifyMakeCaseAction:(NSString *)makeCaseActions sender:(id)sender;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaMakeCaseAction object:sender userInfo:@{@"action" : makeCaseActions}];
}
+(void)notifyAgdaGotoIndex:(NSInteger)index sender:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:AWAgdaGoto object:sender userInfo:@{@"index" : [NSNumber numberWithInteger:index]}];
}

+ (void)notifySelectAgdaRange:(NSString *)agdaRange sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AWSelectAgdaRange object:sender userInfo:@{@"agdaRange" : agdaRange}];
}


@end
