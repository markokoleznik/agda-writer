//
//  AWStatusTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWStatusTextView.h"
#import "AWNotifications.h"

@implementation AWStatusTextView

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBufferDataAvaliable:) name:AWAgdaBufferDataAvaliable object:nil];
    
    [self.textStorage setFont:[NSFont systemFontOfSize:16.0]];
    
}

-(void)agdaBufferDataAvaliable:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *reply = notification.object;
        reply = [reply substringWithRange:NSMakeRange(1, reply.length - 2)];
        reply = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        if (![reply hasSuffix:@"\n"]) {
            reply = [reply stringByAppendingString:@"\n"];
        }
        [self.textStorage beginEditing];
        [[self.textStorage mutableString] appendString:reply];
        [self.textStorage endEditing];
        [self scrollToEndOfDocument:nil];
    }
}

- (IBAction)clearContet:(id)sender
{
    [self setString:@""];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
