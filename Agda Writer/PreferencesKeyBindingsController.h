//
//  PreferencesKeyBindingsController.h
//  Agda Writer
//
//  Created by Marko Koležnik on 25. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesKeyBindingsController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *keyBindingsTableView;
- (IBAction)addBinding:(id)sender;

- (IBAction)removeBinding:(id)sender;

@end
