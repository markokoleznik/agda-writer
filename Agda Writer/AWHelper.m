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
    else
    {
        // Load font from plist
        NSDictionary * defaults = [AWNotifications dictionaryOfDefaults];
        NSDictionary * font = [defaults objectForKey:@"defaultFont"];
        NSString * name = [font objectForKey:@"name"];
        NSNumber * fontSize = (NSNumber *)[font objectForKey:@"size"];
        NSFont * fontRet = [NSFont fontWithName:name size:[fontSize floatValue]];
        return fontRet;
    }
    
    return nil;
}

+ (void) saveDefaultFont:(NSFont *)font
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:font.fontName forKey:FONT_FAMILY_KEY];
    [ud setObject:[NSNumber numberWithFloat:font.pointSize] forKey:FONT_SIZE_KEY];
    [ud synchronize];
}

+ (void) setUserDefaults {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * keyBindings = [ud objectForKey:@"KeyBindings"];
    if (!keyBindings) {
        NSURL * keyBindingsUrl = [[NSBundle mainBundle] URLForResource:@"Key Bindings" withExtension:@"plist"];
        [ud setObject:[NSDictionary dictionaryWithContentsOfURL:keyBindingsUrl] forKey:@"KeyBindings"];
    }
    NSNumber * showNotifications = [ud objectForKey:@"showNotifications"];
    if (!showNotifications) {
        [ud setObject:[NSNumber numberWithBool:YES] forKey:@"showNotifications"];
    }
    [ud synchronize];
    
}

+ (NSDictionary *)keyBindings {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * keyBindings = [ud objectForKey:@"KeyBindings"];
    return keyBindings;
}

+ (void)saveKeyBindings: (NSDictionary *)keyBindings {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:keyBindings forKey:@"KeyBindings"];
    [ud synchronize];
}

+ (BOOL)isShowingNotifications {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSNumber * showNotifications = [ud objectForKey:@"showNotifications"];
    return [showNotifications boolValue];
}

+ (void)setShowingNotifications:(BOOL)isShowing {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithBool:isShowing] forKey:@"showNotifications"];
}

@end
