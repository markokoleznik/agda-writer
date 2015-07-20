//
//  ViewController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "ViewController.h"
#import "Document.h"


#import "AWAgdaParser.h"
#import "AWNotifications.h"
#import "AppDelegate.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.mainTextView.parentViewController = self;
    self.goalsTableController.parentViewController = self;
    self.statusTextView.parentViewController = self;
    
    
    [self setUserDefaults];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:[self.mainTextView.enclosingScrollView contentView]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeController:) name:REMOVE_CONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBufferDataAvaliable:) name:AWAgdaBufferDataAvaliable object:nil];
    
    // Add this class as observer, when font (in Prefrences) is changed. It might be reusable in other classes as well.
    // Don't forget to remove observer in dealloc, because it has strong pointer to self.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontSizeFromNotification:) name:fontSizeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontFamilyFromNotification:) name:fontFamilyChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(executeActions:) name:AWExecuteActions object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaVersionAvaliable:) name:AWAgdaVersionAvaliable object:nil];
    
}


- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification
{
//    // get the changed content view from the notification
//    NSClipView *changedContentView = [notification object];
//    
//    // get the origin of the NSClipView of the scroll view that
//    // we're watching
//    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;;
//    
//    // get our current origin
//    NSPoint curOffset = [[self contentView] bounds].origin;
//    NSPoint newOffset = curOffset;
//    
//    // scrolling is synchronized in the vertical plane
//    // so only modify the y component of the offset
//    newOffset.y = changedBoundsOrigin.y;
//    
//    // if our synced position is different from our current
//    // position, reposition our content view
//    if (!NSEqualPoints(curOffset, changedBoundsOrigin))
//    {
//        // note that a scroll view watching this one will
//        // get notified here
//        [[self.lineNumbersView.enclosingScrollView contentView] scrollToPoint:newOffset];
//    }
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
//    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
//    NSString * fullPath = [ud objectForKey:@"currentFile"];
//    NSError * error;
//    [self replaceTokensWithQuestionMarks];
//    NSString *content = [[self.mainTextView textStorage] string];
//    [content writeToFile:fullPath
//              atomically:YES
//                encoding:NSUTF8StringEncoding
//                   error:&error];
    
    
}


- (IBAction)hideOutputs:(id)sender {
    
    self.toastView = [[AWToastWindow alloc] initWithToastType:ToastTypeLoadSuccessful];
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


- (IBAction)actionLoad:(id)sender {
    NSString * fullPath = [document filePath].path;
    
    // save
    [document saveDocument:self];
    
    if (fullPath) {
        NSString * message = [AWAgdaActions actionLoadWithFilePath:fullPath andIncludeDir:@""];
        AppDelegate * appDelegate = (AppDelegate *)[NSApp delegate];
        [appDelegate.communicator writeDataToAgda:message sender:self];
    }
    
}

- (IBAction)actionQuitAndRestartAgda:(NSMenuItem *)sender {
    [self showNotImplementedAlert];
}

- (IBAction)actionQuit:(NSMenuItem *)sender {
    [self showNotImplementedAlert];
}

#pragma mark -

- (IBAction)actionGive:(NSMenuItem *)sender {
    
    
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGiveWithFilePath:fullPath goalIndex:goal.goalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startRow endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionRefine:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionRefineWithFilePath:fullPath goalIndex:goal.goalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startRow endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionAuto:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionAutoWithFilePath:fullPath goalIndex:goal.goalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startColumn endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionCase:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionCaseWithFilePath:fullPath goalIndex:goal.goalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startColumn endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalType:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeWithFilePath:fullPath goalIndex:goal.goalIndex];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionContextEnvironment:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionContextWithFilePath:fullPath goalIndex:goal.goalIndex];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalTypeAndContext:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeAndContextWithFilePath:fullPath goalIndex:goal.goalIndex];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalTypeAndInferredType:(NSMenuItem *)sender {
    [document saveDocument:self];
    NSString * fullPath = [document filePath].path;
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeAndInferredTypeWithFilePath:fullPath goalIndex:goal.goalIndex content:goal.content];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionComputeNormalForm:(NSMenuItem *)sender {
    [self showNotImplementedAlert];
}
#pragma mark -
-(void)showNotImplementedAlert
{
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"I will patiently wait for a lazy developer to implement this..."];
    [alert setMessageText:@"This method is not yet implemented!"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        
    }
}



- (IBAction)loadAction:(NSButton *)sender {
//    [self saveCurrentWork];
    [self.loadingIndicator startAnimation:self];
    NSString * fullPath = [document filePath].path;
    
    // save
    [document saveDocument:self];
    
    if (fullPath) {
        NSString * message = [AWAgdaActions actionLoadWithFilePath:fullPath andIncludeDir:@""];
        AppDelegate * appDelegate = (AppDelegate *)[NSApp delegate];
        [appDelegate.communicator writeDataToAgda:message sender:self];
    }
    
    
    
    
}



#pragma mark -


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

- (void) agdaBufferDataAvaliable:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *reply = notification.object;
        reply = [reply substringWithRange:NSMakeRange(1, reply.length - 2)];
        reply = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        
        [self.lastStatusTextField setStringValue:reply];
        
        
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
//        for (NSWindow *window in self.childWindows) {
//            if ([window.identifier isEqualToString:@"Helper"]) {
//                [self removeChildWindow:window];
//                self.isHelperWindowOpened = NO;
//            }
//        }
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
//            [self.agdaVersion setStringValue:[NSString stringWithFormat:@"Agda is now running... Version: %@", version]];
        }
    }
}

-(void)executeActions:(NSNotification *)actions
{
    [self.loadingIndicator stopAnimation:self];
    NSDate * date1 = [NSDate date];
    if (actions.object == self) {
        [AWAgdaActions executeArrayOfActions:(NSArray *)actions.userInfo[@"actions"] sender:self];
    }
    
    
    NSDate * date2 = [NSDate date];
    NSLog(@"Running time: %f", [date2 timeIntervalSinceDate:date1]);
}

#pragma mark - Table of goals

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalType" owner:self];
    
    if (result) {
        // Set the stringValue of the cell's text field to the nameArray value at row
        result.textField.stringValue = [NSString stringWithFormat:@"value %li",row];
    }
    
    
    // Return cell
    return result;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 2;
}



#pragma mark - Dealloc

-(void)viewDidDisappear
{

}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    Document * document1 = (Document *)representedObject;
    
    document = document1;
    
    document.mainTextView = self.mainTextView;
    
    if (document.contentString) {
        [self.mainTextView setString:document.contentString];
    }
    
    // Update the view, if already loaded.
}

@end
