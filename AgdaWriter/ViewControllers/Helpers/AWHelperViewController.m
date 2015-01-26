//
//  AWHelperView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWHelperViewController.h"
#import "AWCustomCell.h"

@interface AWHelperViewController ()

@end



@implementation AWHelperViewController



-(id) initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        items = [[NSMutableArray alloc] init];
        for (int i = 1; i < 10; i++) {
            NSString * text = [NSString stringWithFormat:@"help%i",i];
            [items addObject:text];
        }

    }
    return self;
}

//-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        
//        items = [[NSMutableArray alloc] init];
//        for (int i = 1; i < 10; i++) {
//            NSString * text = [NSString stringWithFormat:@"help%i",i];
//            [items addObject:text];
//        }
//
//    }
//    
//    return self;
//}

-(void)awakeFromNib
{
    items = [[NSMutableArray alloc] init];
    for (int i = 1; i < 10; i++) {
        NSString * text = [NSString stringWithFormat:@"help%i",i];
        [items addObject:text];
    }

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
//        [cellView.imageView setImage:flag[@"image"]];
        return cellView;
    }
    return nil;


//    AWCustomCell * customCell = [[AWCustomCell alloc] initWithNibName:@"AWCustomCell" bundle:nil];
//    NSView * view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
//    CALayer *layer = [CALayer layer];
//    [layer setBackgroundColor:CGColorCreateGenericRGB(1.0, 0, 0, 0.5)];
//    [view setWantsLayer:YES];
//    [view setLayer:layer];
//    [customCell.textLabel setStringValue:[self.items objectAtIndex:row]];
//    AWCustomCell * customView = [[AWCustomCell alloc] initWithFrame:NSMakeRect(0, 0, 150, 50)];
//    [customView.textLabel setBackgroundColor:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0]];
//    [customView.textLabel setBordered:NO];
////    [customView setWantsLayer:YES];
////    [customView setLayer:layer];
//    NSLog(@"Object at row: %li", (long)row);
//    for (int i = 0; i < [self.items count]; i++) {
//        NSLog(@"object at row: %i, value: %@", i, [self.items objectAtIndex:i]);
//    }
//    
//    [customView.textLabel setStringValue:[self.items objectAtIndex:row]];
    
//    return view;
}

@end
