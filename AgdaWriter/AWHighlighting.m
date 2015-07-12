//
//  AWHighlighting.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 12. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWHighlighting.h"
#import "AWColors.h"


@implementation AWHighlighting

+ (void) highlightCodeAtRange:(NSRange) range actionName: (NSString *) actionName textView: (NSTextView *)textView
{
    range = NSMakeRange(range.location - 1, range.length);
    NSColor * color = [AWColors highlightColorForType:actionName];
    if (color) {
        [textView.layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName] forCharacterRange:range];
    }
    
}

@end
