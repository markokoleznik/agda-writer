//
//  PreferencesKeyBindingsController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 25. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "PreferencesKeyBindingsController.h"
#import "AWHelper.h"

@interface PreferencesKeyBindingsController ()

@end

@implementation PreferencesKeyBindingsController {
    NSMutableDictionary * items;
    NSMutableArray * sortedKeys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Load items from Key Bindings.plist
    
    items = [[NSMutableDictionary alloc] initWithDictionary:[AWHelper keyBindings]];
//    [items enumerateKeysAndObjectsWithOptions: usingBlock:^(id key, id obj, BOOL *stop) {
//        
//    }];
    
    [self sortDictionaryByKeys];
    
    
    
}

- (IBAction)addBinding:(id)sender {
    [sortedKeys addObject:@""];
    [self.keyBindingsTableView reloadData];
//    [self.keyBindingsTableView scrollToEndOfDocument:nil];
    [self.keyBindingsTableView editColumn:0 row:sortedKeys.count - 1 withEvent:nil select:YES];
}

- (IBAction)removeBinding:(id)sender {
    
    NSInteger selectedRow = [self.keyBindingsTableView selectedRow];
    if (selectedRow != -1) {
        NSString * key = sortedKeys[selectedRow];
        [sortedKeys removeObjectAtIndex:selectedRow];
        [items removeObjectForKey:key];
        [AWHelper saveKeyBindings:items];
        [self.keyBindingsTableView reloadData];
        if (selectedRow > 0) {
            NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:selectedRow - 1];
            [self.keyBindingsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
        }
        
    }

}

- (void) sortDictionaryByKeys {
    
    sortedKeys = [[NSMutableArray alloc] initWithArray:[items.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * name1 = (NSString *)obj1;
        NSString * name2 = (NSString *)obj2;
        if ([name1 hasPrefix:@"\\"]) {
            name1 = [name1 substringFromIndex:1];
        }
        if ([name2 hasPrefix:@"\\"]) {
            name2 = [name2 substringFromIndex:1];
        }
        return [name1 compare:name2];
    }]];
    
}


-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * key = sortedKeys[row];
    if (!key) {
        if ([tableColumn.identifier isEqualToString:@"columnKey"]) {
            return @"";
        }
        else if ([tableColumn.identifier isEqualToString:@"columnValue"]) {
            return @"";
        }
    }
    if ([tableColumn.identifier isEqualToString:@"columnKey"]) {
        
        
        return key;
    }
    else if ([tableColumn.identifier isEqualToString:@"columnValue"])
    {
        
        return items[key];
        
    }
    
    return nil;

}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"columnKey"]) {
        if (items[object] && ![object isEqualToString:@""]) {
            // Key already exist, show warning!
            NSAlert * alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Done"];
            [alert setMessageText:@"Key already exists!\nPlease set unique key."];
            [alert setAlertStyle:NSWarningAlertStyle];
            if ([alert runModal] == NSAlertFirstButtonReturn) {
            }
        }
        else {
            if (items[sortedKeys[row]]) {
                //change, first save new value
                NSString * oldValue = items[sortedKeys[row]];
                [items removeObjectForKey:sortedKeys[row]];
                [items setObject:oldValue forKey:object];
                [AWHelper saveKeyBindings:items];
                
            }
            [sortedKeys replaceObjectAtIndex:row withObject:object];
            
        }

        
        
    }
    else if ([tableColumn.identifier isEqualToString:@"columnValue"]) {
        if (![sortedKeys[row] isEqualToString:@""]) {
            // key is set, ok
            if (![object isEqualToString:@""]) {
                [items setObject:object forKey:sortedKeys[row]];
                [AWHelper saveKeyBindings:items];
            }
            else {
                NSAlert * alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Done"];
                [alert setMessageText:@"Value can't be empty."];
                [alert setAlertStyle:NSWarningAlertStyle];
                if ([alert runModal] == NSAlertFirstButtonReturn) {
                }
            }
            
            
        }
        else {
            NSAlert * alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Done"];
            [alert setMessageText:@"Please set unique key first."];
            [alert setAlertStyle:NSWarningAlertStyle];
            if ([alert runModal] == NSAlertFirstButtonReturn) {
            }
        }
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return sortedKeys.count;

}


@end
