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
    
    BOOL shouldHighlightText;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
    shouldHighlightText = YES;
    
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


-(void)selectRow:(NSInteger)row highlightGoal:(BOOL)highlight
{
    shouldHighlightText = highlight;
    [self.goalsTable scrollRowToVisible:row];
    [self.goalsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView * tableView = notification.object;
    if (items.count > tableView.selectedRow) {
//        NSLog(@"User pressed goal number: %li, name: %@", tableView.selectedRow, items[tableView.selectedRow]);
        
        // Find all goals (ranges of goals) and show pressed goal.
        NSRange selectedGoal = [AWAgdaParser goalAtIndex:tableView.selectedRow textStorage:self.mainTextView.textStorage];
        // Show pressed goal
        if (selectedGoal.location != NSNotFound) {
            if (shouldHighlightText) {
                [self.mainTextView scrollRangeToVisible:selectedGoal];
                [self.mainTextView showFindIndicatorForRange:selectedGoal];
                if (3 <= (selectedGoal.length - 3)) {
                    [self.mainTextView setSelectedRange:NSMakeRange(selectedGoal.location + 3, selectedGoal.length - 6)];
                }
                else {
                    [self.mainTextView setSelectedRange:NSMakeRange(selectedGoal.location + 2, selectedGoal.length - 4)];
                }
                
                
            }
        }
        else {
            NSString * content = items[tableView.selectedRow];
            NSString * regexPattern = @"[0-9]*,[0-9]*-[0-9]*";
            NSError * error;
            NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
            NSArray * matches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
            if (matches.count == 1) {
                NSTextCheckingResult * result = matches[0];
                
                NSString * substring = [content substringWithRange:result.range];
                NSArray * components = [substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",-"]];
                if (components.count == 3) {
                    NSInteger lineNumber = [components[0] integerValue];
                    NSInteger startRange = [components[1] integerValue];
                    NSInteger endRange = [components[2] integerValue];

                    NSRange lineRange = NSMakeRange(startRange, endRange - startRange);
                    NSRange actualRange = [AWAgdaParser rangeFromLineNumber:lineNumber andLineRange:lineRange string:self.mainTextView.string];
                    if (actualRange.location != NSNotFound) {
                        [self.mainTextView scrollRangeToVisible:actualRange];
                        [self.mainTextView showFindIndicatorForRange:actualRange];
                        [self.mainTextView setSelectedRange:actualRange];
                    }
                }
            }
        }
        shouldHighlightText = YES;
        
        [self.mainTextView.window makeFirstResponder:self.mainTextView];
    }
    else
    {
//        NSLog(@"Index %li out of bounds for array of length %li",tableView.selectedRow, items.count);
    }
    
    
}

@end
