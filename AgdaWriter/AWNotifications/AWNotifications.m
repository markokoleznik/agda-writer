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

@implementation AWNotifications


+ (void) notifyFontSizeChanged: (NSNumber *) fontSize
{
    [[NSNotificationCenter defaultCenter] postNotificationName:fontSizeChanged object:fontSize];
}

+ (void) notifyFontFamilyChanged: (NSString *) fontFamily
{
    [[NSNotificationCenter defaultCenter] postNotificationName:fontFamilyChanged object:fontFamily];
}


@end
