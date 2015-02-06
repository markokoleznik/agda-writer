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

#import "AWAgdaParser.h"




@implementation AWMainWindow


#pragma mark - initialize



-(void)awakeFromNib
{
    // Called, when xib is loaded
//    NSLog(@"%@", self.mainTextView);
    
    [self setUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:[self.mainTextView.enclosingScrollView contentView]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeController:) name:REMOVE_CONTROLLER object:nil];
    
    // Add this class as observer, when font (in Prefrences) is changed. It might be reusable in other classes as well.
    // Don't forget to remove observer in dealloc, because it has strong pointer to self.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontSizeFromNotification:) name:fontSizeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontFamilyFromNotification:) name:fontFamilyChanged object:nil];
    
    
    
    if (!self.communicator) {
        self.communicator = [[AWCommunitacion alloc] init];
    }
    
    
}



- (void)removeController:(NSNotification *)notification
{
    NSLog(@"Removing view controller");
    NSViewController * vc = (NSViewController *)notification.object;
    if ([vc isKindOfClass:[AWPopupAlertViewController class]]) {
        for (NSWindow *window in self.childWindows) {
            if ([window.identifier isEqualToString:@"Helper"]) {
                [self removeChildWindow:window];
                self.isHelperWindowOpened = NO;
            }
        }
    }
    [self makeKeyWindow];
    
    
}



- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification
{
    // get the changed content view from the notification
    NSClipView *changedContentView = [notification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;;
    
    // get our current origin
    NSPoint curOffset = [[self contentView] bounds].origin;
    NSPoint newOffset = curOffset;
    
    // scrolling is synchronized in the vertical plane
    // so only modify the y component of the offset
    newOffset.y = changedBoundsOrigin.y;
    
    // if our synced position is different from our current
    // position, reposition our content view
    if (!NSEqualPoints(curOffset, changedBoundsOrigin))
    {
        // note that a scroll view watching this one will
        // get notified here
        [[self.lineNumbersView.enclosingScrollView contentView] scrollToPoint:newOffset];
    }
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


-(BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    [AWNotifications notifyTextChangedInRange:affectedCharRange replacementString:replacementString];
    
    return YES;
}

- (void)saveCurrentWork
{
    // TODO: error handling
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    NSError * error;
    NSString *content = [[self.mainTextView textStorage] string];
    [content writeToFile:fullPath
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:&error];
    
}

- (IBAction)hideOutputs:(id)sender {
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        context.duration = 0.4f;
//        self.mainTextView.animator.frame = CGRectOffset(self.mainTextView.frame, 20, 0);
//    } completionHandler:^{
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//            context.duration = 0.3f;
//            self.mainTextView.animator.frame = CGRectOffset(self.mainTextView.frame, -20, 0);
//        } completionHandler:nil];
//        
//    }];

}

- (IBAction)writeToAgda:(id)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    [self saveCurrentWork];
    NSString * writeToAgda = [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_load \"%@\" [] )", fullPath, fullPath];
//    NSString * writeToAgda2 = @"IOTCM \"/Users/markokoleznik/Documents/os_x_development/agda-writer/foo.agda\" NonInteractive Indirect ( Cmd_load \"/Users/markokoleznik/Documents/os_x_development/agda-writer/foo.agda\" [] )";
    [self.communicator writeData:writeToAgda];
}

- (IBAction)saveAs:(id)sender {

    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        NSInteger choice = result;
        if (choice == NSFileHandlingPanelOKButton) {
            NSURL *directoryToSave = [savePanel directoryURL];
            NSURL *fileName = [savePanel URL];
            [self writeToTextFile:directoryToSave filename:fileName];
            
        }
        else if (choice == NSCancelButton) {
        
        }
        else {
            
        }
        
        
    }];
    
}

- (IBAction)doOpen:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowedFileTypes = @[@"txt", @"agda"];
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL * directory = [openPanel directoryURL];
            NSURL * filename = [openPanel URL];
            
            NSLog(@"Directory: %@, Filename: %@", directory, filename);
            NSString * fullPath = [NSString stringWithFormat:@"%@/%@", [directory path], [filename lastPathComponent]];
            NSString * fileContent = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
            NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:fullPath forKey:@"currentFile"];
            [ud synchronize];
            [self.mainTextView setString:fileContent];
        }
    }];
    
}

-(void) writeToTextFile: (NSURL *)directoryToSave filename:(NSURL *)filename {
    
    NSString *directory = [directoryToSave path];
    NSString *fileName = [[filename absoluteString] lastPathComponent];
    NSError * error;
    NSString *content = [[self.mainTextView textStorage] string];
    [content writeToFile:[NSString stringWithFormat:@"%@/%@.txt",directory, fileName]
              atomically:YES
                encoding:NSStringEncodingConversionAllowLossy
                   error:&error];
    
}





-(void)changeFontSizeFromNotification:(NSNotification *)notification
{
    // When "fontSizeChanged" notification is recieved, change font to our editor
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        
        
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        
        NSNumber *fontSize = (NSNumber *) notification.object;
        NSFont *font = self.mainTextView.font;
        if (!font) {
            NSString * fontFamily = [ud stringForKey:FONT_FAMILY_KEY];
            font = [NSFont fontWithName:fontFamily size:[fontSize floatValue]];
        }
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:[fontSize floatValue]];
        [self.mainTextView setFont:font];
        [self.lineNumbersView setFont:font];
        
        // Save changes to NSUserDefaults!
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
        [self.lineNumbersView setFont:font];
        
        // Save changes to NSUserDefaults!
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:fontFamily forKey:FONT_FAMILY_KEY];
        [ud synchronize];
    }
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    // Called, when we select text
    
//    return;
    
    // Check for selected range, and put rectangle around it.
    NSRange selectedText = [self.mainTextView selectedRange];
    NSRect rectangle = [self.mainTextView firstRectForCharacterRange:selectedText actualRange:nil];
    
    
//    int location = (int)selectedText.location;
    int lenght = (int) selectedText.length;
    if (lenght > 0) {
//        [self.numberLabel setStringValue:[NSString stringWithFormat:@"%i", lenght]];
        
        [self.mainTextView addToolTipRect:NSMakeRect(100, 100, 300, 300) owner:self userData:nil];
        
        // Open help window
        [self showHelpWindowAtRect:rectangle];
    }
    else
    {
        // Remove window!
        // TODO: use delegation to remove help window.
//        [self.numberLabel setStringValue:@""];
        for (NSWindow *window in self.childWindows) {
            if ([window.identifier isEqualToString:@"Helper"]) {
                [self removeChildWindow:window];
                self.isHelperWindowOpened = NO;
            }
        }
    }
}

- (IBAction)copy:(id)sender {
    NSRange selectedTextRange = [self.mainTextView selectedRange];
    NSString *content = [[self.mainTextView textStorage] string];
    NSString * substring = [content substringWithRange:selectedTextRange];
    if (substring) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *copiedObjects = [NSArray arrayWithObject:substring];
        [pasteboard writeObjects:copiedObjects];
    }
}

-(IBAction)paste:(id)sender {
    NSPasteboard * pasteboard = [NSPasteboard generalPasteboard];
    NSArray * classArray = [NSArray arrayWithObject:[NSString class]];
    // for we have empty options.
    NSDictionary * options = [NSDictionary dictionary];
    
    BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
    if (ok) {
        NSArray * objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        NSString * content = [objectsToPaste objectAtIndex:0];
        NSString * oldText = [[self.mainTextView textStorage] string];
        [self.mainTextView setString:[oldText stringByAppendingString:content]];
    }
}





-(void) showHelpWindowAtRect: (NSRect) rect
{
    // If one instance of window is already opened, return.
    if (self.isHelperWindowOpened) {
        return;
    }
    
    // TODO: Remove this! Don't show helper for now.
    return;

    // TODO: Change fixed values. For testing only.

    self.helperView = [[AWPopupAlertViewController alloc] initWithNibName:@"AWPopupAlertViewController" bundle:[NSBundle mainBundle]];
    MAAttachedWindow * MAAwindow = [[MAAttachedWindow alloc] initWithView:self.helperView.view attachedToPoint:NSMakePoint(rect.origin.x + rect.size.width/2, rect.origin.y)];
    [self.helperView.view setFrame:NSMakeRect(4, 5, self.helperView.view.frame.size.width - 5, self.helperView.view.frame.size.height - 5)];
    [self.helperView.view becomeFirstResponder];
    NSLog(@"%i", [self.helperView.view becomeFirstResponder]);
    [MAAwindow setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
    MAAwindow.identifier = @"Helper";
    
    
    
    [self addChildWindow:MAAwindow ordered:1];
    [MAAwindow makeKeyWindow];

    // Animation inside window (on it's child view) -> For experimenting only.
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        context.duration = 0.4f;
//        self.helperView.view.animator.frame = CGRectOffset(self.helperView.view.frame, 20, 0);
//    } completionHandler:^{
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//            context.duration = 0.3f;
//            self.helperView.view.animator.frame = CGRectOffset(self.helperView.view.frame, -20, 0);
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
