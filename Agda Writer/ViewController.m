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
#import "AWHelper.h"

#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"
#import "MarkerLineNumberView.h"

@implementation ViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.mainTextView.parentViewController = self;
    self.goalsTableController.parentViewController = self;
    self.statusTextView.parentViewController = self;
    
    self.lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:self.mainScrollView];
    [self.mainScrollView setVerticalRulerView:self.lineNumberView];
    [self.mainScrollView setHasHorizontalRuler:NO];
    [self.mainScrollView setHasVerticalRuler:YES];
    [self.mainScrollView setRulersVisible:YES];
    [self.lineNumberView setBackgroundColor:[NSColor whiteColor]];
    [self.lineNumberView setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBufferDataAvaliable:) name:AWAgdaBufferDataAvaliable object:nil];
    
    // Add this class as observer, when font (in Prefrences) is changed. It might be reusable in other classes as well.
    // Don't forget to remove observer in dealloc, because it has strong pointer to self.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontSizeFromNotification:) name:fontSizeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontFamilyFromNotification:) name:fontFamilyChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(executeActions:) name:AWExecuteActions object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaVersionAvaliable:) name:AWAgdaVersionAvaliable object:nil];  
    
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
    NSString * message = [AWAgdaActions actionGiveWithFilePath:fullPath goalIndex:goal.agdaGoalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startRow endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}


- (IBAction)actionRefine:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionRefineWithFilePath:fullPath goalIndex:goal.agdaGoalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startRow endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionAuto:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionAutoWithFilePath:fullPath goalIndex:goal.agdaGoalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startColumn endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionCase:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionCaseWithFilePath:fullPath goalIndex:goal.agdaGoalIndex startCharIndex:goal.startCharIndex startRow:goal.startRow startColumn:goal.startColumn endCharIndex:goal.endCharIndex endRow:goal.endRow endColumn:goal.endColumn content:goal.content];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalType:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeWithFilePath:fullPath goalIndex:goal.agdaGoalIndex];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionContextEnvironment:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionContextWithFilePath:fullPath goalIndex:goal.agdaGoalIndex];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalTypeAndContext:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeAndContextWithFilePath:fullPath goalIndex:goal.agdaGoalIndex];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalTypeAndInferredType:(NSMenuItem *)sender {
    [document saveDocument:self];
    NSString * fullPath = [document filePath].path;
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeAndInferredTypeWithFilePath:fullPath goalIndex:goal.agdaGoalIndex content:goal.content];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionComputeNormalForm:(NSMenuItem *)sender {
    [self showNotImplementedAlert];
}

- (void)saveDocument:(id)sender
{
    [document saveDocument:self];
}

- (IBAction)actionNormalize:(id)sender {
    
    if (self.inputWindow) {
        return;
    }
    
    self.inputViewController = [[AWInputViewController alloc] initWithNibName:@"AWInputViewController" bundle:nil];
    
    // Check if normalization is goal specific
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    if (goal && goal.rangeOfContent.location != NSNotFound) {
        // We have goal
        [self.mainTextView scrollRangeToVisible:goal.rangeOfContent];
        NSRect rect = [self.mainTextView firstRectForCharacterRange:goal.rangeOfContent actualRange:nil];
        
        
        NSPoint point = NSMakePoint(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
        NSRect frame = self.inputViewController.view.frame;
        [self.inputViewController.view setFrame:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width*2/3, frame.size.width*1/3)];
        [self.inputViewController.inputTitle setStringValue:@"Normalize goal:"];
        self.inputWindow = [[MAAttachedWindow alloc] initWithView:self.inputViewController.view attachedToPoint:point atDistance:10];
    }
    else {
        self.inputWindow = [[MAAttachedWindow alloc] initWithView:self.inputViewController.view attachedToPoint:NSMakePoint(200, 220)];
        [self.inputWindow setHasArrow:0];
        [self.inputWindow center];
    }
    
    self.inputViewController.delegate = self;
    
    
    [self.inputWindow makeKeyWindow];
    
    [self.inputWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    
}

- (IBAction)actionNormalizeGoal:(id)sender {
    
}

-(void)normalizeInputDidEndEditing:(NSString *)content
{
//    [document saveDocument:self];
    NSString * fullPath = [document filePath].path;
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionNormalizeWithGoal:goal filePath:fullPath content:content];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
    
//    [self.inputWindow orderOut:self];
    [self closeWindow];
}
-(void)closeWindow
{
    [self.inputWindow close];
    self.inputWindow = nil;
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




#pragma mark -


-(void)changeFontSizeFromNotification:(NSNotification *)notification
{
    // When "fontSizeChanged" notification is recieved, change font to our editor
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        
        NSNumber *fontSize = (NSNumber *) notification.object;
        NSFont *font = [AWHelper defaultFontInAgda];
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:[fontSize floatValue]];
        [self.mainTextView.textStorage addAttribute:@"NSFontAttributeName" value:font range:NSMakeRange(0, self.mainTextView.textStorage.string.length)];
        [self.mainTextView.textStorage setFont:font];
        [self.lineNumbersView setFont:font];
        
//         Save changes to NSUserDefaults!
        [AWHelper saveDefaultFont:font];
        
    }
}
- (void) changeFontFamilyFromNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        
        NSString *fontFamily = (NSString *) notification.object;
        NSFont *font = [AWHelper defaultFontInAgda];
        font = [[NSFontManager sharedFontManager] convertFont:font toFamily:fontFamily];
        [self.mainTextView.textStorage addAttribute:@"NSFontAttributeName" value:font range:NSMakeRange(0, self.mainTextView.textStorage.string.length)];
        [self.mainTextView.textStorage setFont:font];
        [self.lineNumbersView setFont:font];
        
        // Save changes to NSUserDefaults!
        [AWHelper saveDefaultFont:font];
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
    if (actions.object == self) {
        [AWAgdaActions executeArrayOfActions:(NSArray *)actions.userInfo[@"actions"] sender:self];
    }
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
//        NSLog(@"%@", document.contentString);
        
        [self.mainTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:document.contentString attributes:@{NSFontAttributeName : [AWHelper defaultFontInAgda]}]];
    }
    
    // Update the view, if already loaded.
}

- (IBAction)applyUnicodeTransformation:(id)sender {
    [self.mainTextView applyUnicodeTransformation];
}

- (IBAction)biggerText:(id)sender {
    NSFont *font = self.mainTextView.textStorage.font;
    font = [[NSFontManager sharedFontManager] convertFont:font toSize:(font.pointSize + 1)];

    [self.mainTextView.textStorage setFont:font];
}

- (IBAction)smallerText:(id)sender {
    NSFont *font = self.mainTextView.textStorage.font;
    CGFloat desiredSize = font.pointSize - 1;
    if (desiredSize > 8) {
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:(font.pointSize - 1)];
        [self.mainTextView.textStorage setFont:font];
    }
    
}
@end
