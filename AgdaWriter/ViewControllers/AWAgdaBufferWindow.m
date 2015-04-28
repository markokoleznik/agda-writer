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


-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBufferDataAvaliable:) name:AWAgdaBufferDataAvaliable object:nil];
}

-(void)agdaBufferDataAvaliable:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *reply = notification.object;
        reply = [reply substringWithRange:NSMakeRange(1, reply.length - 2)];
        reply = [reply stringByAppendingString:@"\n"];
        reply = [reply stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        [self.agdaTextView setString:[[self.agdaTextView.textStorage string] stringByAppendingString:reply]];
    }
}

@end
