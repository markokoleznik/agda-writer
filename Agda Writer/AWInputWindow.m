//
//  AWInputWindow.m
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWInputWindow.h"

@implementation AWInputWindow
-(id)init {
    NSRect frame = NSMakeRect(0, 0, 400, 200);
    // Prepare borderless window
    self = [super initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreRetained defer:NO];
    if (self) {
        
        [self setOpaque:NO];
        [self setMovableByWindowBackground:YES];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setAlphaValue:1.0];
        // Ensure that Toast always stays in front of every window
//        [self setLevel:kCGOverlayWindowLevelKey];
        
        // Prepare content view
        NSView * contentView = [[NSView alloc] initWithFrame:frame];
        [contentView setWantsLayer:YES];
        [contentView.layer setCornerRadius:20];
        NSColor * backgroundColor = [NSColor colorWithWhite:0.3 alpha:0.7];
        [contentView.layer setBackgroundColor:backgroundColor.CGColor];
        
        NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(frame.origin.x, frame.origin.y + 20, frame.size.width, 100)];
        [textField setBezeled:YES];
        [textField setDrawsBackground:NO];
        [textField setEditable:YES];
        [textField setSelectable:YES];
        [textField setPlaceholderString:@"Normalize..."];
        [contentView addSubview:textField];
        

        [self setContentView:contentView];
        [self center];
    }
    
    return self;
}

-(void)show {
    [self makeKeyAndOrderFront:NSApp];
//    [self ]
}

-(void)close {
    
}
@end
