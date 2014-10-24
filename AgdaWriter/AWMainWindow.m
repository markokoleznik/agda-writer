//
//  AWMainWindow.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 15. 10. 14.
//  Copyright (c) 2014 koleznik.net. All rights reserved.
//

#import "AWMainWindow.h"
#import "MAAttachedWindow.h"

@implementation AWMainWindow

@synthesize delegate;

#pragma mark - initialize

-(void)awakeFromNib
{
    NSLog(@"Zdaj sem se zbudil");
    self.mainTextView.delegate = self;
    [self.mainTextView setString:@"Tukaj je nek text"];
    
}

-(void) textDidBeginEditing:(NSNotification *)notification
{
    NSLog(@"Text did begin editing");
}

- (void) textDidChange:(NSNotification *)notification
{
    NSLog(@"Text did change");
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    NSRange selectedText = [self.mainTextView selectedRange];
    
    xpc_connection_create(<#const char *name#>, <#dispatch_queue_t targetq#>)
    
    int location = (int)selectedText.location;
    int lenght = (int) selectedText.length;
    NSLog(@"Število označenih znakov: %i, lokacija: %i", lenght, location);
    if (lenght > 0) {
        [self.numberLabel setStringValue:[NSString stringWithFormat:@"%i", lenght]];
        
//        [self.mainTextView setToolTip:@"Hover"];
        [self.mainTextView addToolTipRect:NSMakeRect(100, 100, 300, 300) owner:self userData:nil];
        
        [self showHelpWindowAtRect:NSMakeRect(110, 600, 60, 30)];
    
//        [textStorage  addAttribute: NSToolTipAttributeName
//                             value:error.description
//                             range:range];
    }
    else
    {
        [self.numberLabel setStringValue:@""];
        for (NSWindow *window in self.childWindows) {
            if ([window.identifier isEqualToString:@"Helper"]) {
                [self removeChildWindow:window];
            }
        }
    }
}

-(void) showHelpWindowAtRect: (NSRect) rect
{
//    NSWindow *window = [[NSWindow alloc] initWithContentRect:rect styleMask:0 backing:NSBackingStoreBuffered defer:YES];
//    [window setBackgroundColor:[NSColor redColor]];
//    window.identifier = @"Helper";
//    
//    [self addChildWindow:window ordered:1];
    
    
    NSView * view = [[NSView alloc] initWithFrame:NSMakeRect(20, 20, 300, 70)];
    
#pragma mark - handling subviews
    
    NSTextField *subview = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, 200, 50)];
    [subview setStringValue:@"Nek tekst"];
    [subview setTextColor:[NSColor whiteColor]];
    [subview setDrawsBackground:NO];
    [subview setBezeled:NO];
    [subview setDrawsBackground:NO];
    [subview setEditable:NO];
    [subview setSelectable:NO];
    [view addSubview:subview];
    
    NSLog(@"število besed: %@", self.mainTextView.textStorage.words);
//    self.mainTextView.textStorage.st
    
    CGPoint currentMousePosition = [NSEvent mouseLocation];
    MAAttachedWindow * window = [[MAAttachedWindow alloc] initWithView:view attachedToPoint:NSMakePoint(currentMousePosition.x, currentMousePosition.y)];
    window.identifier = @"Helper";
    [window setTitle:@"Naslov"];
    [self addChildWindow:window ordered:1];
    
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        context.duration = 2.f;
//        view.animator.frame = CGRectOffset(view.frame, 100, 0);
//    } completionHandler:nil];

}

-(NSString *) description
{
    return @"Ta klas se uporablja za marsikaj";
}


@end
