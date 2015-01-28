//
//  AWPopupAlertViewController.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 26. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWPopupAlertViewController.h"
#import "AWNotifications.h"

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
        for (int i = 1; i <= 100000; i++) {
            NSString * text = [NSString stringWithFormat:@"help%i",i];
            [items addObject:text];
        }
        
        self.view.layer = [self.view layer];
        self.view.wantsLayer = YES;
        self.view.layer.masksToBounds = YES;
        self.view.layer.cornerRadius = 8.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyPressed:) name:KEY_ON_TABLE_PRESSED object:nil];
        [self.table setTarget:self];
        [self.table setDoubleAction:@selector(handleDoubleClick)];

    }
    return self;
}

-(BOOL)becomeFirstResponder
{
    return YES;
}

-(BOOL)resignFirstResponder{
    [AWNotifications notifyRemoveViewController:self];
    return YES;
}


- (void) handleDoubleClick
{
    NSLog(@"User pressed enter at: %@", [items objectAtIndex:[self.table selectedRow]]);
    [AWNotifications notifyRemoveViewController:self];
}

- (void) handleKeyPressed: (NSNotification *)notification
{
    NSNumber * keyNumber = (NSNumber *)notification.object;
    switch ([keyNumber integerValue]) {
        case AWEnterPressed:
            if ([self.table selectedRow] >= 0) {
                [self handleDoubleClick];
            }
            
            break;
        case AWEscapePressed:
            [AWNotifications notifyRemoveViewController:self];
            break;
            
            
        default:
            break;
    }
}


-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = (NSTableView *)notification.object;
    NSInteger selectedRow = tableView.selectedRow;
    NSLog(@"%@", [items objectAtIndex:selectedRow]);
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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
