//
//  AWOutputTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWOutputTextView.h"
#import "AWNotifications.h"

@implementation AWOutputTextView

-(void)awakeFromNib
{
    // Add observer for Agda replies:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaReplied:) name:AWAgdaReplied object:nil];
}

- (void)agdaReplied:(NSNotification *)notification
{
    NSString *reply = notification.object;
    NSLog(@"Agda replied: \n%@", reply);
    
    [self setString:[[self.textStorage string] stringByAppendingString:reply]];
    
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
