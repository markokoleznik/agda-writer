//
//  AWAgdaBufferWindow.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 28. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWAgdaBufferWindow.h"
#import "AWNotifications.h"

@implementation AWAgdaBufferWindow

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBufferDataAvaliable:) name:AWAgdaReplied object:nil];
}


-(void)agdaBufferDataAvaliable:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *reply = notification.object;
        [self.agdaTextView.textStorage beginEditing];
        [[self.agdaTextView.textStorage mutableString] appendString:reply];
        [self.agdaTextView.textStorage endEditing];
    }
}

@end
