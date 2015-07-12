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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBuffer:) name:AWAgdaBufferDataAvaliable object:nil];
    
    [self.textStorage setAttributes:@{NSFontAttributeName : [NSFont systemFontOfSize:20]} range:NSMakeRange(0, self.string.length)];
}

-(void)agdaBuffer:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *reply = notification.object;
        reply = [reply substringWithRange:NSMakeRange(1, reply.length - 2)];
        reply = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        if (![reply hasSuffix:@"\n"]) {
            reply = [reply stringByAppendingString:@"\n"];
        }
        NSLog(@"REPLY: %@", reply);
        [self.textStorage beginEditing];
        [[self.textStorage mutableString] appendString:reply];
        [self.textStorage setAttributes:@{NSFontAttributeName : [NSFont systemFontOfSize:14]} range:NSMakeRange(0, self.string.length)];
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
