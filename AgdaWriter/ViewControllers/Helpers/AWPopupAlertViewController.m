//
//  AWPopupAlertViewController.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 26. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWPopupAlertViewController.h"

@interface AWPopupAlertViewController ()

@end

@implementation AWPopupAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        items = [[NSMutableArray alloc] init];
        for (int i = 1; i < 10; i++) {
            NSString * text = [NSString stringWithFormat:@"help%i",i];
            [items addObject:text];
        }
        
        self.view.layer = [self.view layer];
        self.view.wantsLayer = YES;
        self.view.layer.masksToBounds = YES;
        self.view.layer.cornerRadius = 8.0;
    }
    return self;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    
    return [items count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * name = items[row];
    NSString * identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"mainCell"]) {
        NSTableCellView * cellView = [tableView makeViewWithIdentifier:@"mainCell" owner:self];
        [cellView.textField setStringValue:name];
        return cellView;
    }
    return nil;

}


@end