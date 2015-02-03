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

//@interface AWMainWindow : NSWindow <NSApplicationDelegate, NSTextViewDelegate, NSTextDelegate, NSTableViewDataSource, NSTableViewDelegate>{
@interface AWMainWindow : NSWindow <NSApplicationDelegate, NSTextViewDelegate, NSTextDelegate>{
    
}

@property IBOutlet NSTextView *mainTextView;
@property IBOutlet NSTextView *lineNumbersView;
@property BOOL isHelperWindowOpened;
@property AWPopupAlertViewController * helperView;
@property AWCommunitacion * communicator;


- (IBAction)writeToAgda:(id)sender;

- (IBAction)saveAs:(id)sender;
- (IBAction)doOpen:(id)sender;

- (IBAction)copy:sender;
- (IBAction)paste:sender;
@end
