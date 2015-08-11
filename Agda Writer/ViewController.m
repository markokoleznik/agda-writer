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
    
    // Clear status window
    [self.statusTextView setString:@""];
    
    // save
    [document saveDocument:self];
    
    if (fullPath) {
        NSString * message = [AWAgdaActions actionLoadWithFilePath:fullPath];
        AppDelegate * appDelegate = (AppDelegate *)[NSApp delegate];
        [appDelegate.communicator writeDataToAgda:message sender:self];
    }
    
}

- (IBAction)actionQuitAndRestartAgda:(NSMenuItem *)sender {
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator quitAndRestartConnectionToAgda];
    [self.mainTextView clearHighligting];
}

- (IBAction)actionCompile:(id)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    NSString * message = [AWAgdaActions actionCompileWithFilePath:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
    
}

- (IBAction)actionQuit:(NSMenuItem *)sender {
    [self showNotImplementedAlert];
}

#pragma mark -

- (IBAction)actionGive:(NSMenuItem *)sender {
    
    [self.mainTextView clearHighligting];
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGiveWithFilePath:fullPath goal:goal];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}


- (IBAction)actionRefine:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionRefineWithFilePath:fullPath goal:goal];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionAuto:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionAutoWithFilePath:fullPath goal:goal];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionCase:(NSMenuItem *)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionCaseWithFilePath:fullPath goal:goal];
    self.mainTextView.lastSelectedGoal = goal;
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

- (IBAction)actionGoalTypeSimplified:(id)sender {
    [self actionGoalType:AWNormalisationLevelSimplified];
}
- (IBAction)actionGoalTypeNormalised:(id)sender {
    [self actionGoalType:AWNormalisationLevelNormalised];
}
- (IBAction)actionGoalTypeInstantiated:(id)sender {
    [self actionGoalType:AWNormalisationLevelInstantiated];
}
- (void)actionGoalType:(AWNormalisationLevel) normalisationLevel {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeWithFilePath:fullPath goal:goal normalisationLevel:normalisationLevel];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

// Type and Context
- (IBAction)actionGoalTypeAndContextSimplified:(id)sender {
    [self actionGoalTypeAndContext:AWNormalisationLevelSimplified];
}
- (IBAction)actionGoalTypeAndContextNormalised:(id)sender {
    [self actionGoalTypeAndContext:AWNormalisationLevelNormalised];
}
- (IBAction)actionGoalTypeAndContextInstantiated:(id)sender {
    [self actionGoalTypeAndContext:AWNormalisationLevelInstantiated];
}
- (void)actionGoalTypeAndContext: (AWNormalisationLevel) normalisationLevel {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionGoalTypeAndContextWithFilePath:fullPath goal:goal normalisationLevel:normalisationLevel];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}


// Type and Inffered Context
- (IBAction)actionGoalTypeAndInfferedContextSimplified:(id)sender {
    [self actionGoalTypeAndInfferedContext:AWNormalisationLevelSimplified];
}
- (IBAction)actionGoalTypeAndInfferedContextNormalised:(id)sender {
    [self actionGoalTypeAndInfferedContext:AWNormalisationLevelNormalised];
}
- (IBAction)actionGoalTypeAndInfferedContextInstantiated:(id)sender {
    [self actionGoalTypeAndInfferedContext:AWNormalisationLevelInstantiated];
}
-(void) actionGoalTypeAndInfferedContext:(AWNormalisationLevel) normalisationLevel {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    if (goal) {
        NSString * message = [AWAgdaActions actionGoalTypeAndInfferedContextWithFilePath:fullPath goal:goal normalisationLevel:normalisationLevel];
        AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
        [appDelegate.communicator writeDataToAgda:message sender:self];
    }
    
}

- (IBAction)actionShowConstraints:(id)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    NSString * message = [AWAgdaActions actionShowConstraintsWithFilePath:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}
- (IBAction)actionShowMetas:(id)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    NSString * message = [AWAgdaActions actionShowMetasWithFilePath:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}
// Module Contents
- (IBAction)actionShowModuleContentsSimplified:(id)sender {
    [self actionShowModuleContents:AWNormalisationLevelSimplified];
}
- (IBAction)actionShowModuleContentsNormalised:(id)sender {
    [self actionShowModuleContents:AWNormalisationLevelNormalised];
}
- (IBAction)actionShowModuleContentsInstantiated:(id)sender {
    [self actionShowModuleContents:AWNormalisationLevelInstantiated];
}
- (void)actionShowModuleContents:(AWNormalisationLevel) normalisationLevel {
    [self openInputViewWithType:AWInputViewTypeShowModuleContents normalisationLevel:normalisationLevel];
    
}
// Implicit Arguments
- (IBAction)actionImplicitArguments:(id)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    NSString * message = [AWAgdaActions actionImplicitArgumentsWithFilePath:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

// Infer
- (IBAction)actionInferSimplified:(id)sender {
    [self actionInfer:AWNormalisationLevelSimplified];
}
- (IBAction)actionInferNormalised:(id)sender {
    [self actionInfer:AWNormalisationLevelNormalised];
}
- (IBAction)actionInferInstantiated:(id)sender {
    [self actionInfer:AWNormalisationLevelInstantiated];
}
-(void)actionInfer:(AWNormalisationLevel)normalisationLevel {
    [self openInputViewWithType:AWInputViewTypeInfer normalisationLevel:normalisationLevel];

}

// Togle Implicit Arguments
- (IBAction)actionToggleImplicitArguments:(id)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    NSString * message = [AWAgdaActions actionToggleImplicitArgumentsWithFilePath:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

// Solve All Constraints
- (IBAction)actionSolveAllConstraints:(id)sender {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    NSString * message = [AWAgdaActions actionSolveAllConstraints:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
}

// Why in Scope?
- (IBAction)actionWhyInScope:(id)sender {
    [self openInputViewWithType:AWInputViewTypeWhyInScope normalisationLevel:AWNormalisationLevelNone];
}

// Context
- (IBAction)actionContextSimplified:(id)sender {
    [self actionContext:AWNormalisationLevelSimplified];
}
- (IBAction)actionContextNormalised:(id)sender {
    [self actionContext:AWNormalisationLevelNormalised];
}
- (IBAction)actionContextInstantiated:(id)sender {
    [self actionContext:AWNormalisationLevelInstantiated];
}
-(void)actionContext:(AWNormalisationLevel)normalisationLevel {
    NSString * fullPath = [document filePath].path;
    [document saveDocument:self];
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message = [AWAgdaActions actionContextWithFilePath:fullPath goal:goal normalisationLevel:normalisationLevel];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];
    
}

// Show Version
- (IBAction)actionShowVersion:(id)sender {
    NSString * fullPath = [document filePath].path;
    NSString * message = [AWAgdaActions actionShowVersionWithFilePath:fullPath];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.communicator writeDataToAgda:message sender:self];

}








//- (IBAction)actionGoalType:(NSMenuItem *)sender {
//    NSString * fullPath = [document filePath].path;
//    [document saveDocument:self];
//    AgdaGoal * goal = self.mainTextView.selectedGoal;
//    NSString * message = [AWAgdaActions actionGoalTypeWithFilePath:fullPath goalIndex:goal.agdaGoalIndex];
//    self.mainTextView.lastSelectedGoal = goal;
//    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
//    [appDelegate.communicator writeDataToAgda:message sender:self];
//}
//
//- (IBAction)actionContextEnvironment:(NSMenuItem *)sender {
//    NSString * fullPath = [document filePath].path;
//    [document saveDocument:self];
//    AgdaGoal * goal = self.mainTextView.selectedGoal;
//    NSString * message = [AWAgdaActions actionContextWithFilePath:fullPath goalIndex:goal.agdaGoalIndex];
//    self.mainTextView.lastSelectedGoal = goal;
//    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
//    [appDelegate.communicator writeDataToAgda:message sender:self];
//}
//
//- (IBAction)actionGoalTypeAndContext:(NSMenuItem *)sender {
//    NSString * fullPath = [document filePath].path;
//    [document saveDocument:self];
//    AgdaGoal * goal = self.mainTextView.selectedGoal;
//    NSString * message = [AWAgdaActions actionGoalTypeAndContextWithFilePath:fullPath goalIndex:goal.agdaGoalIndex];
//    self.mainTextView.lastSelectedGoal = goal;
//    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
//    [appDelegate.communicator writeDataToAgda:message sender:self];
//}
//
//- (IBAction)actionGoalTypeAndInferredType:(NSMenuItem *)sender {
//    [document saveDocument:self];
//    NSString * fullPath = [document filePath].path;
//    AgdaGoal * goal = self.mainTextView.selectedGoal;
//    NSString * message = [AWAgdaActions actionGoalTypeAndInferredTypeWithFilePath:fullPath goalIndex:goal.agdaGoalIndex content:goal.content];
//    self.mainTextView.lastSelectedGoal = goal;
//    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
//    [appDelegate.communicator writeDataToAgda:message sender:self];
//}

- (IBAction)actionComputeNormalForm:(NSMenuItem *)sender {
    [self openInputViewWithType:AWInputViewTypeComputeNormalForm normalisationLevel:AWNormalisationLevelNone];
}

- (void)saveDocument:(id)sender
{
    [document saveDocument:self];
}


- (void)openInputViewWithType:(AWInputViewType)inputType normalisationLevel:(AWNormalisationLevel)level {
    if (self.inputWindow) {
        return;
    }
    // Check if normalization is goal specific
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    if (goal && goal.rangeOfContent.location != NSNotFound) {
        // We have goal
        [self.mainTextView scrollRangeToVisible:goal.rangeOfContent];
        NSRect rect = [self.mainTextView firstRectForCharacterRange:goal.rangeOfContent actualRange:nil];
        self.inputViewController = [[AWInputViewController alloc] initWithInputType:inputType global:NO rect:rect];
        
        self.inputWindow = [[MAAttachedWindow alloc] initWithView:self.inputViewController.view attachedToPoint:self.inputViewController.point atDistance:10];
    }
    else {
        self.inputViewController = [[AWInputViewController alloc] initWithInputType:inputType global:YES rect:NSZeroRect];
        self.inputWindow = [[MAAttachedWindow alloc] initWithView:self.inputViewController.view attachedToPoint:self.inputViewController.point];
        [self.inputWindow setHasArrow:0];
        [self.inputWindow center];
    }
    
    self.inputViewController.delegate = self;
    self.inputViewController.normalisationLevel = level;
    [self.inputWindow makeKeyWindow];
    [self.inputWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}


-(void)inputDidEndEditing:(NSString *)content withType:(AWInputViewType)type normalisationLevel:(AWNormalisationLevel)level
{
    NSString * fullPath = [document filePath].path;
    AgdaGoal * goal = self.mainTextView.selectedGoal;
    NSString * message;
    switch (type) {
        case AWInputViewTypeComputeNormalForm:
            message = [AWAgdaActions actionComputeNormalFormWithFilePath:fullPath goal:goal content:content];
            break;
        case AWInputViewTypeInfer:
            message = [AWAgdaActions actionInferWithFilePath:fullPath goal:goal normalisationLevel:level content:content];
        case AWInputViewTypeShowModuleContents:
            message = [AWAgdaActions actionShowModuleContentsFilePath:fullPath goal:goal normalisationLevel:level content:content];
            break;
        case AWInputViewTypeWhyInScope:
            message = [AWAgdaActions actionWhyInScopeWithFilePath:fullPath goal:goal content:content];
        default:
            break;
    }
    
    // append input to status window
    [self.statusTextView.textStorage.mutableString appendFormat:@"Input:\n%@\n\n",content];
    
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
    [alert addButtonWithTitle:@"Well, OK"];
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
    [self.mainTextView setTypingAttributes:@{NSFontAttributeName : font}];
}

- (IBAction)smallerText:(id)sender {
    NSFont *font = self.mainTextView.textStorage.font;
    CGFloat desiredSize = font.pointSize - 1;
    if (desiredSize > 8) {
        font = [[NSFontManager sharedFontManager] convertFont:font toSize:(font.pointSize - 1)];
        [self.mainTextView.textStorage setFont:font];
        [self.mainTextView setTypingAttributes:@{NSFontAttributeName : font}];
    }
    
}
@end
