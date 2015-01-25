//
//  AWHelperView.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWHelperView : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (retain) IBOutlet NSTableView *tableView;
@property NSMutableArray * items;


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end
