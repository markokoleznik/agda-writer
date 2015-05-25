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


//@interface AWMainWindow : NSWindow <NSApplicationDelegate, NSTextViewDelegate, NSTextDelegate, NSTableViewDataSource, NSTableViewDelegate>{
@interface AWMainWindow : NSWindow <NSApplicationDelegate, NSTextViewDelegate, NSTextDelegate>{
    
}


- (IBAction)showHelp:(id)sender;

@property IBOutlet NSTextView *mainTextView;
@property IBOutlet NSTextView *lineNumbersView;
@property (weak) IBOutlet NSTextField *agdaVersion;
@property BOOL isHelperWindowOpened;
@property AWPopupAlertViewController * helperView;
@property AWCommunitacion * communicator;
@property AWToastWindow * toastView;


- (IBAction)hideOutputs:(id)sender;

- (IBAction)AddToken:(NSButton *)sender;

- (IBAction)writeToAgda:(NSButton *)sender;
- (IBAction)autoAction:(NSButton *)sender;
- (IBAction)loadAction:(NSButton *)sender;
- (IBAction)giveAction:(NSButton *)sender;
- (IBAction)refineAction:(NSButton *)sender;

- (IBAction)saveAs:(id)sender;
- (IBAction)doOpen:(id)sender;

//- (IBAction)copy:sender;
//- (IBAction)paste:sender;

@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSPipe *inputPipe;

@end
