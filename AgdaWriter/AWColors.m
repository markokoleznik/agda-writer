//
//  AWColors.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#define COLOR_MAX_VALUE 255.0

#import "AWColors.h"

@implementation AWColors

+ (CGColorRef) defaultBackgroundColor
{

    return CGColorCreateGenericRGB(239.0/255.0, 239.0/255.0, 239.0/255.0, 1);
}

+ (CGColorRef) defaultSeparatorColor
{
    return CGColorCreateGenericRGB(176.0/255.0, 176.0/255.0, 176.0/255.0, 1);
}

+ (NSColor *) unselectedTokenColor
{
    return [NSColor colorWithCalibratedRed:0/COLOR_MAX_VALUE green:64.0/COLOR_MAX_VALUE blue:153.0/COLOR_MAX_VALUE alpha:1.0];
}

+ (NSColor *) borderTokenColor
{
    return [NSColor colorWithCalibratedRed:110.f/255.f green:116.f/255.f blue:114.f/255.f alpha:1.f];
}

@end
