//
//  AWLineNumbersTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 29. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWLineNumbersTextView.h"

@implementation AWLineNumbersTextView

-(void)awakeFromNib
{
    NSString *line = @"";
    for (int i = 1; i < 10000; i++) {
        line = [line stringByAppendingFormat:@"%i\n",i];
    }
    self.textColor = [NSColor grayColor];
    
    [self setString:line];
}

-(void)scrollWheel:(NSEvent *)theEvent
{
    // empty overwritten method prevents line numbers view to scroll
}

@end
