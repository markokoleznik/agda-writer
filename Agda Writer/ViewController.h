//
//  ViewController.h
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "AWCommunitacion.h"
#import "AWAgdaActions.h"
#import "AWToastWindow.h"
#import "AWMainTextView.h"
#import "Document.h"
#import "AWGoalsTableController.h"
#import "AWStatusTextView.h"
#import "AWInputWindow.h"
#import "MAAttachedWindow.h"
#import "AWInputViewController.h"


@class AgdaGoal, NoodleLineNumberView;

@interface ViewController : NSViewController <NSApplicationDelegate, NSTextViewDelegate, NSTextDelegate, AWInputDelegate>
{
    Document * document;
}

@property (unsafe_unretained) IBOutlet AWMainTextView *mainTextView;

@property (strong) IBOutlet AWGoalsTableController *goalsTableController;

@property (unsafe_unretained) IBOutlet AWStatusTextView *statusTextView;



@property IBOutlet NSTextView *lineNumbersView;
@property AWToastWindow * toastView;
@property MAAttachedWindow * inputWindow;
@property AWInputViewController * inputViewController;
@property (weak) IBOutlet NSTextField *lastStatusTextField;

#pragma mark -
#pragma mark Global actions

// Global actions
- (IBAction)actionLoad:(id)sender;
- (IBAction)actionQuitAndRestartAgda:(NSMenuItem *)sender;
- (IBAction)actionCompile:(id)sender;
- (IBAction)actionQuit:(NSMenuItem *)sender;
// Goal specific actions
#pragma mark Goal specific actions
- (IBAction)actionGive:(NSMenuItem *)sender;
- (IBAction)actionRefine:(id)sender;
- (IBAction)actionAuto:(NSMenuItem *)sender;
- (IBAction)actionCase:(NSMenuItem *)sender;

// Goal
    // Type
    - (IBAction)actionGoalTypeSimplified:(id)sender;
    - (IBAction)actionGoalTypeNormalised:(id)sender;
    - (IBAction)actionGoalTypeInstantiated:(id)sender;
    // Type and Context
    - (IBAction)actionGoalTypeAndContextSimplified:(id)sender;
    - (IBAction)actionGoalTypeAndContextNormalised:(id)sender;
    - (IBAction)actionGoalTypeAndContextInstantiated:(id)sender;
    // Type and Inffered Context
    - (IBAction)actionGoalTypeAndInfferedContextSimplified:(id)sender;
    - (IBAction)actionGoalTypeAndInfferedContextNormalised:(id)sender;
    - (IBAction)actionGoalTypeAndInfferedContextInstantiated:(id)sender;

// Show
    // Constraints
- (IBAction)actionShowConstraints:(id)sender;
- (IBAction)actionShowMetas:(id)sender;
    // Module Contents
    - (IBAction)actionShowModuleContentsSimplified:(id)sender;
    - (IBAction)actionShowModuleContentsNormalised:(id)sender;
    - (IBAction)actionShowModuleContentsInstantiated:(id)sender;
    // Implicit Arguments
- (IBAction)actionImplicitArguments:(id)sender;

// Infer
- (IBAction)actionInferSimplified:(id)sender;
- (IBAction)actionInferNormalised:(id)sender;
- (IBAction)actionInferInstantiated:(id)sender;

// Compute Normal Form
- (IBAction)actionComputeNormalFormSimplified:(id)sender;
- (IBAction)actionComputeNormalFormNormalised:(id)sender;
- (IBAction)actionComputeNormalFormInstantiated:(id)sender;

// Togle Implicit Arguments
- (IBAction)actionToggleImplicitArguments:(id)sender;

// Solve All Constraints
- (IBAction)actionSolveAllConstraints:(id)sender;

// Why in Scope?
- (IBAction)actionWhyInScope:(id)sender;

// Context
- (IBAction)actionContextSimplified:(id)sender;
- (IBAction)actionContextNormalised:(id)sender;
- (IBAction)actionContextInstantiated:(id)sender;

// Show Version
- (IBAction)actionShowVersion:(id)sender;

- (IBAction)actionGoalType:(NSMenuItem *)sender;
- (IBAction)actionContextEnvironment:(NSMenuItem *)sender;
- (IBAction)actionGoalTypeAndContext:(NSMenuItem *)sender;
- (IBAction)actionGoalTypeAndInferredType:(NSMenuItem *)sender;
- (IBAction)actionComputeNormalForm:(NSMenuItem *)sender;
- (IBAction)actionNormalize:(id)sender;
- (IBAction)actionNormalizeGoal:(id)sender;

#pragma mark -
- (IBAction)applyUnicodeTransformation:(id)sender;
- (IBAction)biggerText:(id)sender;
- (IBAction)smallerText:(id)sender;

- (void)saveDocument:(id)sender;

@property (weak) IBOutlet NSTableView *lineNumberTableView;

@property NoodleLineNumberView * lineNumberView;

@property (weak) IBOutlet NSScrollView *mainScrollView;

@end

