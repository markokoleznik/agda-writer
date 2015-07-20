//
//  AWToastWindow.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWToastWindow.h"

#define VISIBLE_TIME 0.8 // in seconds
#define FADING_TIME 0.4  //  -- || --
#define WINDOW_SIZE 150

@implementation AWToastWindow
- (id) initWithToastType:(ToastType)toastType
{
    NSRect frame = NSMakeRect(0, 0, WINDOW_SIZE, WINDOW_SIZE);
    // Prepare borderless window
    self = [super initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreRetained defer:NO];
    if (self) {
        [self setOpaque:NO];
        [self setMovableByWindowBackground:YES];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setAlphaValue:0.0];
        // Ensure that Toast always stays in front of every window
        [self setLevel:kCGOverlayWindowLevelKey];
        
        // Prepare content view
        NSView * contentView = [[NSView alloc] initWithFrame:frame];
        [contentView setWantsLayer:YES];
        [contentView.layer setCornerRadius:20];
        NSColor * backgroundColor = [NSColor colorWithWhite:0.3 alpha:0.7];
        [contentView.layer setBackgroundColor:backgroundColor.CGColor];
        
        NSImageView * imageView = [[NSImageView alloc] initWithFrame:frame];
        
        // Prepare image
        NSString * imageName;
        switch (toastType) {
            case ToastTypeLoadSuccessful:
                imageName = @"load_successful";
                break;
            case ToastTypeLoadFailed:
                imageName = @"load_failed";
                break;
            case ToastTypeFailed:
                imageName = @"failed_default";
                break;
            case ToastTypeSuccess:
                imageName = @"successful_default";
            default:
                break;
        }
        
        [imageView setImage:[NSImage imageNamed:imageName]];
        
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
        [self performSelector:@selector(closeToast) withObject:nil afterDelay:VISIBLE_TIME];
    }];
}

- (void) closeToast
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:FADING_TIME];
        [self.animator setAlphaValue:0.0];
    } completionHandler:^{
        
    }];
}

@end
