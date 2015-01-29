//
//  AWMainTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 29. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWMainTextView.h"

@implementation AWMainTextView

-(void)awakeFromNib
{    
    [self setDefaultText];
    [self recolorText];
    
}

- (void) recolorText
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"//.*" options:0 error:nil];
    NSRange range = NSMakeRange(0, [self.textStorage length]);
    [self setTextColor:[NSColor blackColor]];
    [regex enumerateMatchesInString:[self.textStorage string] options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self setTextColor:[NSColor colorWithRed:94.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0] range:result.range];
    }];
}

- (void) setDefaultText
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd. MM. YY."];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    NSString * welcomeString = @"";
    welcomeString = [welcomeString stringByAppendingString:@"//  \n"];
    welcomeString = [welcomeString stringByAppendingFormat:@"//  Created by %@ on %@ \n", NSFullUserName(), dateString];
    welcomeString = [welcomeString stringByAppendingString:@"//  \n"];
    [self setString: welcomeString];

}


- (void) didChangeText
{
    [self recolorText];
}

@end
