//
//  AWMainWindow.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 15. 10. 14.
//  Copyright (c) 2014 koleznik.net. All rights reserved.
//

#import "AWMainWindow.h"
#import "MAAttachedWindow.h"
#import "AWNotifications.h"
#import "AWPopupAlertViewController.h"


@implementation AWMainWindow

@synthesize delegate;

#pragma mark - initialize

-(void)awakeFromNib
{
    // Called, when xib is loaded
    self.mainTextView.delegate = self;
    [self.mainTextView setString:@"Some pre-entered text! :)"];
    // TODO: Get font from NSDefaults!
    [self setUserDefaults];
    
    
//    NSLog(@"Font description: %@",self.mainTextView.font.description);
    
    // Add this class as observer, when font (in Prefrences) is changed. It might be reusable in other classes as well.
    // Don't forget to remove observer in dealloc, because it has strong pointer to self.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontSizeFromNotification:) name:fontSizeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontFamilyFromNotification:) name:fontFamilyChanged object:nil];
    
}

- (void) setUserDefaults
{
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    // Default font will be Helvetica, 12pt.
    if (![ud objectForKey:FONT_SIZE_KEY]) {
        [ud setObject:[NSNumber numberWithInt:12] forKey:FONT_SIZE_KEY]; // Default value
    }
    if (![ud stringForKey:FONT_FAMILY_KEY]) {
        [ud setObject:@"Helvetica" forKey:FONT_FAMILY_KEY]; // Default value
    }
    // Write changes to disk.
    [ud synchronize];
    
    // Both keys/values are in NSUserDefaults
    NSNumber * fontSize = (NSNumber *)[ud objectForKey:FONT_SIZE_KEY];
    NSNotification * notif1 = [[NSNotification alloc] initWithName:fontSizeChanged object:fontSize userInfo:nil];
    
    NSString *fontFamily = (NSString *)[ud stringForKey:FONT_FAMILY_KEY];
    NSNotification * notif2 = [[NSNotification alloc] initWithName:fontFamilyChanged object:fontFamily userInfo:nil];
    
    [self changeFontSizeFromNotification:notif1];
    [self changeFontFamilyFromNotification:notif2];

}

-(void) textDidBeginEditing:(NSNotification *)notification
{
    // Called, when user pressed a key in our "editor" window.
    // This method is called before any visual change is made. After this method, textDidChange is called.
    

}


- (void) textDidChange:(NSNotification *)notification
{
    // Here we can send typed words to Agda.
    

}

-(void)changeFontSizeFromNotification:(NSNotification *)notification
{
    // When "fontSizeChanged" notification is recieved, change font to our editor
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        
        NSNumber *fontSize = (NSNumber *) notification.object;
        NSFont *font = self.mainTextView.font;
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:[fontSize floatValue]];
        [self.mainTextView setFont:font];
        
        // Save changes to NSUserDefaults!
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:fontSize forKey:FONT_SIZE_KEY];
        [ud synchronize];
        
    }
}
- (void) changeFontFamilyFromNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *fontFamily = (NSString *) notification.object;
        NSFont *font = self.mainTextView.font;
        font = [[NSFontManager sharedFontManager] convertFont:font toFamily:fontFamily];
        [self.mainTextView setFont:font];
        
        // Save changes to NSUserDefaults!
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:fontFamily forKey:FONT_FAMILY_KEY];
        [ud synchronize];
    }
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    // Called, when we select text
    
    // Check for selected range, and put rectangle around it.
    NSRange selectedText = [self.mainTextView selectedRange];
    NSRect rectangle = [self.mainTextView firstRectForCharacterRange:selectedText actualRange:nil];
    
    
//    int location = (int)selectedText.location;
    int lenght = (int) selectedText.length;
    if (lenght > 0) {
        [self.numberLabel setStringValue:[NSString stringWithFormat:@"%i", lenght]];
        
        [self.mainTextView addToolTipRect:NSMakeRect(100, 100, 300, 300) owner:self userData:nil];
        
        // Open help window
        [self showHelpWindowAtRect:rectangle];
    }
    else
    {
        // Remove window!
        // TODO: use delegation to remove help window.
        [self.numberLabel setStringValue:@""];
        for (NSWindow *window in self.childWindows) {
            if ([window.identifier isEqualToString:@"Helper"]) {
                [self removeChildWindow:window];
                self.isHelperWindowOpened = NO;
            }
        }
    }
}


-(void) showHelpWindowAtRect: (NSRect) rect
{
    // If one instance of window is already opened, return.
    if (self.isHelperWindowOpened) {
        return;
    }
    

    // TODO: Change fixed values. For testing only.

    if (!self.helperView) {
        self.helperView = [[AWPopupAlertViewController alloc] initWithNibName:@"AWPopupAlertViewController" bundle:[NSBundle mainBundle]];
    }
    MAAttachedWindow * MAAwindow = [[MAAttachedWindow alloc] initWithView:self.helperView.view attachedToPoint:NSMakePoint(rect.origin.x + rect.size.width/2, rect.origin.y)];
    [self.helperView.view setFrame:NSMakeRect(5, 5, self.helperView.view.frame.size.width - 5, self.helperView.view.frame.size.height - 5)];
    [MAAwindow setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
    MAAwindow.identifier = @"Helper";
    
    [self addChildWindow:MAAwindow ordered:1];

    // Animation inside window (on it's child view) -> For experimenting only.
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        context.duration = 0.5f;
//        view.animator.frame = CGRectOffset(view.frame, 20, 0);
//    } completionHandler:^{
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//            context.duration = 1.0f;
//            view.animator.frame = CGRectOffset(view.frame, -20, 0);
//        } completionHandler:nil];
//        
//    }];
    
    self.isHelperWindowOpened = YES;

}



-(NSString *) description
{
    return @"Tooltip effect";
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
