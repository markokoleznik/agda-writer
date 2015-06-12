//
//  AWGoalsTableView.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 30. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWGoalsTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate> {
    
}
@property (nonatomic) NSArray * items;
@end
