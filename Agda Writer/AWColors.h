//
//  AWColors.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>



@interface AWColors : NSObject

+ (CGColorRef) defaultBackgroundColor;
+ (CGColorRef) defaultSeparatorColor;
+ (NSColor *) unselectedTokenColor;
+ (NSColor *) borderTokenColor;
+ (NSColor *) highlightColorForType:(NSString *)type;
@end
