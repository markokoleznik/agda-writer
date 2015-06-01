//
//  AWGoalsTableController.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 1. 06. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWGoalsTableController.h"
#import "AWNotifications.h"
#import "AWAgdaParser.h"

@implementation AWGoalsTableController {
    NSArray * items;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
}

- (void)allGoalsAction:(NSNotification *)notification
{
    items = [AWAgdaParser makeArrayOfGoalsWithSuggestions:notification.object];
    [self.goalsTable reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return items.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    if ([tableColumn.identifier isEqualToString:@"GoalType"]) {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalType" owner:self];
        
        // Set the stringValue of the cell's text field to the nameArray value at row
        result.textField.stringValue = [items objectAtIndex:row];
        
        // Return the result
        return result;
    }
    else if ([tableColumn.identifier isEqualToString:@"GoalNumber"])
    {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalNumber" owner:self];
        
        // Set the stringValue of the cell's text field to the nameArray value at row
        result.textField.stringValue = [NSString stringWithFormat:@"%li", row];
        
        // Return the result
        return result;
    }
    return nil;
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView * tableView = notification.object;
    NSLog(@"User pressed goal number: %li, name: %@", tableView.selectedRow, items[tableView.selectedRow]);
}

@end
