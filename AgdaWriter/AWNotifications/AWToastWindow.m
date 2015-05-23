//
//  AWToastWindow.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWToastWindow.h"

@implementation AWToastWindow
- (id) initWithToastType:(ToastType)toastType
{
    NSRect frame = NSMakeRect(0, 0, 200, 200);
    // Prepare borderless window
    self = [super initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreRetained defer:NO];
    if (self) {
        [self setOpaque:NO];
        [self setMovableByWindowBackground:YES];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setAlphaValue:0.0];
        
        // Prepare content view
        NSView * contentView = [[NSView alloc] initWithFrame:frame];
        [contentView setWantsLayer:YES];
        [contentView.layer setCornerRadius:20];
        NSColor * backgroundColor = [NSColor colorWithWhite:0.3 alpha:0.7];
        [contentView.layer setBackgroundColor:backgroundColor.CGColor];
        
        NSImageView * imageView = [[NSImageView alloc] initWithFrame:frame];
        // Prepare image
        
        // TODO: implement other images!
        switch (toastType) {
            case ToastTypeLoadSuccessful:
                [imageView setImage:[NSImage imageNamed:@"load_successful"]];
                break;
                
            default:
                break;
        }
        
        [contentView addSubview:imageView];
        [self setContentView:contentView];
        [self center];
    }
    
    return self;
    
}

- (void)show
{
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [self makeKeyAndOrderFront:NSApp];
        [context setDuration:0.1];
        [self.animator setAlphaValue:1.0];
    } completionHandler:^{
        [self performSelector:@selector(closeToast) withObject:nil afterDelay:1.5];
    }];
}

- (void) closeToast
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.5];
        [self.animator setAlphaValue:0.0];
    } completionHandler:^{
        
    }];
}

@end
