//
//  AWHelperView.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWHelperViewController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray * items;
}

@property (strong) IBOutlet NSWindow *window;


//-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end
