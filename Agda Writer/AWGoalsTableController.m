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
    NSMutableArray * items;
    NSMutableArray * goalIndexes;
    NSArray * goals;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
    
}

- (void)allGoalsAction:(NSNotification *)notification
{
    if (notification.object != self.parentViewController) {
        return;
    }
    // Create array of goals
    items = [[NSMutableArray alloc] init];
    goalIndexes = [[NSMutableArray alloc] init];
    NSArray * arrayOfDicts = [AWAgdaParser makeArrayOfGoalsWithSuggestions:notification.userInfo[@"goals"]];
    for (NSDictionary * dict in arrayOfDicts) {
        [items addObject:dict[@"goalType"]];
        [goalIndexes addObject:dict[@"goalIndex"]];
    }
    [self.goalsTable reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return items.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    if ([tableColumn.identifier isEqualToString:@"GoalType"]) {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalType" owner:self];
        result.textField.stringValue = [items objectAtIndex:row];

        return result;
    }
    else if ([tableColumn.identifier isEqualToString:@"GoalNumber"])
    {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalNumber" owner:self];
        result.textField.stringValue = [goalIndexes objectAtIndex:row];

        return result;
    }
    return nil;
    
}



- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView * tableView = notification.object;
    if (items.count > tableView.selectedRow) {
        NSLog(@"User pressed goal number: %li, name: %@", tableView.selectedRow, items[tableView.selectedRow]);
        
        // Find all goals (ranges of goals) and show pressed goal.
        NSRange selectedGoal = [AWAgdaParser goalAtIndex:tableView.selectedRow textStorage:self.mainTextView.textStorage];
        // Show pressed goal
        if (selectedGoal.location != NSNotFound) {
            [self.mainTextView scrollRangeToVisible:selectedGoal];
            [self.mainTextView showFindIndicatorForRange:selectedGoal];
            [self.mainTextView setSelectedRange:NSMakeRange(selectedGoal.location + 2, selectedGoal.length - 4)];
        }
        
        [self.mainTextView.window makeFirstResponder:self.mainTextView];
    }
    else
    {
        NSLog(@"Index %li out of bounds for array of length %li",tableView.selectedRow, items.count);
    }
    
    
}


@end
