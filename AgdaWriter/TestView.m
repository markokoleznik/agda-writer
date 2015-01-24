//
//  TestView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 10. 12. 14.
//  Copyright (c) 2014 koleznik.net. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}


-(void)awakeFromNib
{
    NSLog(@"custom view loaded");
    
}

-(id)initWithFrame:(NSRect)frameRect
{
    NSString* nibName = NSStringFromClass([self class]);
    self = [super initWithFrame:frameRect];
    if (self) {
        if ([[NSBundle mainBundle] loadNibNamed:nibName
                                          owner:self
                                topLevelObjects:nil]) {
        }
    }
    return self;
}

@end
