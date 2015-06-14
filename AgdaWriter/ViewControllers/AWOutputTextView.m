//
//  AWOutputTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWOutputTextView.h"
#import "AWNotifications.h"
#import "AWAgdaParser.h"

@implementation AWOutputTextView

-(void)awakeFromNib
{
    // Add observer for Agda replies:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];

}

- (void)allGoalsAction:(NSNotification *)notification
{
    
    NSString *reply = notification.object;
    NSArray * goals = [AWAgdaParser makeArrayOfGoalsWithSuggestions:notification.object];
    NSMutableAttributedString * replyAttributed = [[NSMutableAttributedString alloc] initWithString:[reply stringByAppendingString:@"\n"]];
    [self.textStorage beginEditing];
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    for (NSString * goal in goals) {
        
        [self.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:[goal stringByAppendingString:@"\n"]]];
    }
//    [self.textStorage setAttributedString:replyAttributed];
    [self.textStorage endEditing];
    [self scrollToEndOfDocument:nil];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)clearContet:(id)sender
{
    [self setString:@""];
}

@end
