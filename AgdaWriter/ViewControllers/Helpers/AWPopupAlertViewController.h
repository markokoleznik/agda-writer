//
//  AWPopupAlertViewController.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 26. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWPopupAlertViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>{
    NSMutableArray * items;
}

@end
