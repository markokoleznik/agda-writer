//
//  AWStatusTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWStatusTextView.h"
#import "AWNotifications.h"
#import "AWAgdaParser.h"

@implementation AWStatusTextView


-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBuffer:) name:AWAgdaBufferDataAvaliable object:nil];
    
    [self setFont:[NSFont systemFontOfSize:25.0]];
    
}


-(void)agdaBuffer:(NSNotification *)notification
{
    if (self.font.pointSize != 13.0) {
        [self setFont:[NSFont systemFontOfSize:13]];
    }
    
    if (notification.object == self.parentViewController) {
        NSString *reply = notification.userInfo[@"buffer"];
        reply = [reply substringWithRange:NSMakeRange(1, reply.length - 2)];
        reply = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        if (![reply hasSuffix:@"\n"]) {
            reply = [reply stringByAppendingString:@"\n"];
        }
        
        // parse ranges and return string with attachments
        
        NSAttributedString * attrReply = [AWAgdaParser parseRangesAndAddAttachments:reply parentViewController:self.parentViewController];
        
        
        [self.textStorage beginEditing];
        [self.textStorage appendAttributedString:attrReply];
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
