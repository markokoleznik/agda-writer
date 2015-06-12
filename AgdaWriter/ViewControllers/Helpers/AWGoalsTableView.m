//
//  AWGoalsTableView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 30. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWGoalsTableView.h"
#import "AWNotifications.h"
#import "AWAgdaParser.h"

@implementation AWGoalsTableView

-(void)awakeFromNib
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
}

- (void)allGoalsAction:(NSNotification *)notification
{
    self.items = [AWAgdaParser makeArrayOfGoalsWithSuggestions:notification.object];
    [self reloadData];
}



- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    if ([tableColumn.identifier isEqualToString:@"GoalType"]) {
        NSTableCellView *result = [tableView makeViewWithIdentifier:@"GoalType" owner:self];
        
        // Set the stringValue of the cell's text field to the nameArray value at row
        result.textField.stringValue = [self.items objectAtIndex:row];
        
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




-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.items.count;
}

@end
