//
//  AWCustomCell.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWCustomCell.h"

@implementation AWCustomCell

-(id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.textLabel = [[NSTextField alloc] initWithFrame:frameRect];
        [self.textLabel setTextColor:[NSColor blackColor]];
        [self addSubview:self.textLabel];
    }
    
    return self;
}

@end
