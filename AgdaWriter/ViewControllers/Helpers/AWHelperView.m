//
//  AWHelperView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 24. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWHelperView.h"
#import "AWCustomCell.h"

@interface AWHelperView ()

@end

@implementation AWHelperView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.tableView = [[NSTableView alloc] init];
        
        self.items = [[NSMutableArray alloc] init];
        for (int i = 1; i < 10; i++) {
            NSString * text = [NSString stringWithFormat:@"help%i",i];
            [self.items addObject:text];
        }
//        self.tableView.dataSource = self;
//        self.tableView.delegate = self;

    }
    
    return self;
}
-(void) printTable
{
    NSLog(@"%@", self.tableView);
}
-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 50;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"Number of items: %lu", (unsigned long)[self.items count]);
    NSLog(@"tableView: %@", self.tableView);
    return [self.items count];
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [tableView makeViewWithIdentifier:@"tableColumn" owner:self];
    NSCell *cell = [[NSCell alloc] initTextCell:@"Test"];
    return cell;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
//    AWCustomCell * customCell = [[AWCustomCell alloc] initWithNibName:@"AWCustomCell" bundle:nil];
    NSView * view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:CGColorCreateGenericRGB(1.0, 0, 0, 0.5)];
    [view setWantsLayer:YES];
    [view setLayer:layer];
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
    
    return view;
}

@end
