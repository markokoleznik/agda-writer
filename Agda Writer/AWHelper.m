//
//  AWHelper.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWHelper.h"
#import "AWNotifications.h"

@implementation AWHelper

+ (NSFont *)defaultFontInAgda
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fontName = [ud objectForKey:FONT_FAMILY_KEY];
    NSNumber * fontSize = [ud objectForKey:FONT_SIZE_KEY];
    if (fontName && fontSize) {
        NSFont * defaultFont = [NSFont fontWithName:fontName size:[fontSize floatValue]];
        return defaultFont;
    }
    
    return nil;
}

@end
