//
//  AWMainWindow.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 15. 10. 14.
//  Copyright (c) 2014 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AWPopupAlertViewController.h"
#import "AWCommunitacion.h"
#import "AWAgdaActions.h"
#import "AWToastWindow.h"
#import "AWMainTextView.h"

@class AgdaGoal;

@interface AWMainWindow : NSWindow <NSApplicationDelegate, NSTextViewDelegate, NSTextDelegate, NSTableViewDataSource, NSTableViewDelegate>{
    
}


- (IBAction)showHelp:(id)sender;

@property IBOutlet AWMainTextView *mainTextView;
@property IBOutlet NSTextView *lineNumbersView;
@property (weak) IBOutlet NSTextField *agdaVersion;
@property BOOL isHelperWindowOpened;
@property AWPopupAlertViewController * helperView;
@property AWCommunitacion * communicator;
@property AWToastWindow * toastView;
@property (weak) IBOutlet NSTextField *lastStatusTextField;



- (IBAction)hideOutputs:(id)sender;

- (IBAction)AddToken:(NSButton *)sender;

#pragma mark -
#pragma mark Global actions

    // Global actions
- (IBAction)actionLoad:(NSMenuItem *)sender;
- (IBAction)actionQuitAndRestartAgda:(NSMenuItem *)sender;
- (IBAction)actionQuit:(NSMenuItem *)sender;
    // Goal specific actions
#pragma mark Goal specific actions
- (IBAction)actionGive:(NSMenuItem *)sender;
- (IBAction)actionRefine:(NSMenuItem *)sender;
- (IBAction)actionAuto:(NSMenuItem *)sender;
- (IBAction)actionCase:(NSMenuItem *)sender;
- (IBAction)actionGoalType:(NSMenuItem *)sender;
- (IBAction)actionContextEnvironment:(NSMenuItem *)sender;
- (IBAction)actionGoalTypeAndContext:(NSMenuItem *)sender;
- (IBAction)actionGoalTypeAndInferredType:(NSMenuItem *)sender;
- (IBAction)actionComputeNormalForm:(NSMenuItem *)sender;
#pragma mark -




- (IBAction)writeToAgda:(NSButton *)sender;
- (IBAction)autoAction:(NSButton *)sender;
- (IBAction)loadAction:(NSButton *)sender;
- (IBAction)giveAction:(NSButton *)sender;
- (IBAction)refineAction:(NSButton *)sender;

- (IBAction)saveAs:(id)sender;
- (IBAction)doOpen:(id)sender;


@end
