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
    NSArray * goals;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
    
}

- (void)allGoalsAction:(NSNotification *)notification
{
    // Create array of goals
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
    
    if ([tableColumn.identifier isEqualToString:@"GoalType"]) {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalType" owner:self];
        result.textField.stringValue = [items objectAtIndex:row];

        return result;
    }
    else if ([tableColumn.identifier isEqualToString:@"GoalNumber"])
    {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalNumber" owner:self];
        result.textField.stringValue = [NSString stringWithFormat:@"%li", row];

        return result;
    }
    return nil;
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView * tableView = notification.object;
    NSLog(@"User pressed goal number: %li, name: %@", tableView.selectedRow, items[tableView.selectedRow]);
    
    // Find all goals (ranges of goals) and show pressed goal.
    NSRange selectedGoal = [self goalAtIndex:tableView.selectedRow textStorage:self.mainTextView.textStorage];
    // Show pressed goal
    [self.mainTextView scrollRangeToVisible:selectedGoal];
    [self.mainTextView showFindIndicatorForRange:selectedGoal];
    
}

-(NSRange) goalAtIndex: (NSInteger) index textStorage:(NSTextStorage *)textStorage
{
    NSRange foundRange;
    [self.mainTextView showFindIndicatorForRange:foundRange];
    // We'll use Regular Expressions to find goals range.
    NSString * regexPattern = @"^(?!--).*(\\{![^!]*!\\})";
    NSError * error;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray * matches = [regex matchesInString:textStorage.string options:0 range:NSMakeRange(0, textStorage.length)];
    
    NSTextCheckingResult * result = [matches objectAtIndex:index];
    foundRange = [result rangeAtIndex:1];
    [self.mainTextView showFindIndicatorForRange:foundRange];
    return foundRange;

}

@end
