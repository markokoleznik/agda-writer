//
//  AWGoalsTableController.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 1. 06. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AWGoalsTableController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *goalsTable;




@end
