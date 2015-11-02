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
#import "AWHelper.h"

@implementation AWStatusTextView


-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaBuffer:) name:AWAgdaBufferDataAvaliable object:nil];
    
    [self setFont:[NSFont systemFontOfSize:25.0]];
    [self.textStorage setFont:[AWHelper defaultFontInAgda]];
    
}


-(void)agdaBuffer:(NSNotification *)notification
{
    if (self.font.pointSize != 13.0) {
        [self setFont:[NSFont systemFontOfSize:13]];
    }
    
    if (notification.object == self.parentViewController) {
//        NSString *reply = notification.userInfo[@"buffer"];
//        reply = [reply substringWithRange:NSMakeRange(1, reply.length - 2)];
//        reply = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//        if (![reply hasSuffix:@"\n"]) {
//            reply = [reply stringByAppendingString:@"\n"];
//        }
        NSAttributedString *reply = notification.userInfo[@"buffer"];
        NSMutableAttributedString * mutableReply = [[NSMutableAttributedString alloc] initWithAttributedString:reply];
        
//        reply = [mutableReply attributedSubstringFromRange:NSMakeRange(1, mutableReply.length - 2)];
        [mutableReply.mutableString replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableReply.length)];
        [mutableReply.mutableString replaceOccurrencesOfString:@"\\n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableReply.length)];
        
        if ([mutableReply.mutableString hasSuffix:@"\n\n"]) {
        }
        else if ([mutableReply.mutableString hasSuffix:@"\n"]) {
            [mutableReply appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        else {
            [mutableReply appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        }
        
        // parse ranges and return string with attachments
        
        NSMutableAttributedString * attrReply = [AWAgdaParser parseRangesAndAddAttachments:mutableReply parentViewController:self.parentViewController];
        [attrReply addAttributes:@{NSFontAttributeName : [AWHelper defaultFontInAgda]} range:NSMakeRange(0, attrReply.length)];
        

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
