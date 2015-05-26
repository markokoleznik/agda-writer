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
#import "AWAgdaActions.h"
#import "AWAgdaParser.h"




@implementation AWMainWindow


#pragma mark - initialize



-(void)awakeFromNib
{
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(executeActions:) name:AWExecuteActions object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaVersionAvaliable:) name:AWAgdaVersionAvaliable object:nil];
    
    
    if (!self.communicator) {
        self.communicator = [[AWCommunitacion alloc] initForCommunicatingWithAgda];
        [self.communicator openConnectionToAgda];
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
        [ud setObject:@"Menlo" forKey:FONT_FAMILY_KEY]; // Default value
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
    [self replaceTokensWithQuestionMarks];
    NSString *content = [[self.mainTextView textStorage] string];
    [content writeToFile:fullPath
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:&error];
    

}


- (IBAction)hideOutputs:(id)sender {
    
    self.toastView = [[AWToastWindow alloc] initWithToastType:ToastTypeSuccess];
    [self.toastView show];


}

- (void)closeToast
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.5];
        [self.toastView.animator setAlphaValue:0.0];
    } completionHandler:^{
//        [self.toastView ];
    }];
    
}

- (IBAction)AddToken:(NSButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AW.addToken" object:nil];
}

#pragma mark -
#pragma mark Agda Actions

- (IBAction)writeToAgda:(NSButton *)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    [self saveCurrentWork];
    NSString * message = [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect ( Cmd_show_version )", fullPath];

    [self.communicator writeDataToAgda:message];
}

- (IBAction)autoAction:(NSButton *)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    [self saveCurrentWork];
    NSString * load = [AWAgdaActions actionLoadWithFilePath:fullPath andIncludeDir:@""];
    
    NSString * message = [AWAgdaActions actionAutoWithFilePath:fullPath goalIndex:0 startCharIndex:0 startRow:0 startColumn:0 endCharIndex:0 endRow:0 endColumn:0 content:@""];
    
    [self.communicator writeData:[NSString stringWithFormat:@"%@\n%@", load, message]];
}

- (IBAction)loadAction:(NSButton *)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    [self saveCurrentWork];
    NSString * message = [AWAgdaActions actionLoadWithFilePath:fullPath andIncludeDir:@""];
    [self.communicator writeDataToAgda:message];

}

- (IBAction)giveAction:(NSButton *)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    [self saveCurrentWork];
    NSString * load = [AWAgdaActions actionLoadWithFilePath:fullPath andIncludeDir:@""];
    
    NSString * message = [AWAgdaActions actionGiveWithFilePath:fullPath goalIndex:0 startCharIndex:0 startRow:0 startColumn:0 endCharIndex:0 endRow:0 endColumn:0 content:@""];
    
    [self.communicator writeData:[NSString stringWithFormat:@"%@\n%@", load, message]];
}

- (IBAction)refineAction:(NSButton *)sender {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    [self saveCurrentWork];
    NSString * message = [AWAgdaActions actionRefineWithFilePath:fullPath goalIndex:0 startCharIndex:0 startRow:0 startColumn:0 endCharIndex:0 endRow:0 endColumn:0 content:@""];
    
    [self.communicator writeData:message];
}



#pragma mark -

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
    openPanel.allowedFileTypes = @[@"txt", @"rtf", @"agda"];
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
            
            // Add this file to recent.
            [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:filename];
        }
    }];
    
}

-(void) writeToTextFile: (NSURL *)directoryToSave filename:(NSURL *)filename {
    
    NSString *directory = [directoryToSave path];
    NSString *fileName = [[filename absoluteString] lastPathComponent];
    NSError * error;
    // Replace tokens with question marks
    [self replaceTokensWithQuestionMarks];
    
    NSString *content = [[self.mainTextView textStorage] string];
    [content writeToFile:[NSString stringWithFormat:@"%@/%@.txt",directory, fileName]
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:&error];
    if (error) {
        NSLog(@"Error writing to file: %@", error.description);
    }
    
}


- (void)replaceTokensWithQuestionMarks
{
    NSMutableArray * arrayOfRangesOfAttachments = [NSMutableArray new];
    [self.mainTextView.attributedString enumerateAttribute:@"NSAttachment" inRange:NSMakeRange(0, self.mainTextView.attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        // Search all NSAttachments, fill them in array and then raplace tokens (attachments) with question marks
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            // Text attachments
            [arrayOfRangesOfAttachments addObject:NSStringFromRange(range)];
        }
    }];
    for (NSString * stringRange in arrayOfRangesOfAttachments) {
        NSRange range = NSRangeFromString(stringRange);
        self.mainTextView.string = [self.mainTextView.string stringByReplacingCharactersInRange:range withString:@"?"];
    }

}


-(void)changeFontSizeFromNotification:(NSNotification *)notification
{
    // When "fontSizeChanged" notification is recieved, change font to our editor
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        
        
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        
        NSNumber *fontSize = (NSNumber *) notification.object;
        NSFont *font = self.mainTextView.textStorage.font;
        if (!font) {
            NSString * fontFamily = [ud stringForKey:FONT_FAMILY_KEY];
            font = [NSFont fontWithName:fontFamily size:[fontSize floatValue]];
        }
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:[fontSize floatValue]];
//        [self.mainTextView.textStorage addAttribute:@"NSFontAttributeName" value:font range:NSMakeRange(0, self.mainTextView.textStorage.string.length)];
        [self.mainTextView.textStorage setFont:font];
        [self.lineNumbersView setFont:font];
        
        // Save changes to NSUserDefaults!
        [ud setObject:fontSize forKey:FONT_SIZE_KEY];
        [ud synchronize];
        
    }
}
- (void) changeFontFamilyFromNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        
        NSString *fontFamily = (NSString *) notification.object;
        NSFont *font = self.mainTextView.textStorage.font;
        font = [[NSFontManager sharedFontManager] convertFont:font toFamily:fontFamily];
        if (!font) {
            NSNumber * fontSize = [ud objectForKey:FONT_SIZE_KEY];
            font = [NSFont fontWithName:fontFamily size:[fontSize floatValue]];
        }
//        [self.mainTextView.textStorage addAttribute:@"NSFontAttributeName" value:font range:NSMakeRange(0, self.mainTextView.textStorage.string.length)];
        [self.mainTextView.textStorage setFont:font];
        [self.lineNumbersView setFont:font];
        
        // Save changes to NSUserDefaults!
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
//        [self.numberLabel setStringValue:@""];
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


}
-(void)agdaVersionAvaliable:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        // Show agda version
        NSString * agdaVersion = notification.object;
        if (agdaVersion) {
            NSString * version = [agdaVersion componentsSeparatedByString:@" "][2];
            version = [version substringToIndex:version.length - 1];
            [self.agdaVersion setStringValue:[NSString stringWithFormat:@"Agda is now running... Version: %@", version]];
        }
    }
}

-(void)executeActions:(NSNotification *)actions
{
    NSDate * date1 = [NSDate date];
    [AWAgdaActions executeArrayOfActions:(NSArray *)actions.object];
    
    NSDate * date2 = [NSDate date];
    NSLog(@"Running time: %f", [date2 timeIntervalSinceDate:date1]);
}


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)showHelp:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHelp" object:nil];
}
@end
