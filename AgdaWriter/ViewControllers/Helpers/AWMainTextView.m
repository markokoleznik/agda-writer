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
    
    
    
//    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
    
    
}

- (void)timerFireMethod:(NSTimer *)timer
{
//    [self recolorText];
}

- (void) recolorText
{
    [self setTextColor:[NSColor blackColor]];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"//.*" options:0 error:nil];
    [regex enumerateMatchesInString:[self.textStorage string] options:0 range:NSMakeRange(0, self.textStorage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        [self setTextColor:[NSColor colorWithRed:94.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0] range:result.range];
    }];
    

}

- (void)asynchronousTaskWithCompletion:(void (^)(NSArray *))matches;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // Some long running task you want on another thread
        NSMutableArray * mathcesToBeFound = [[NSMutableArray alloc] init];
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"//.*" options:0 error:nil];
        BOOL found = YES;
        NSRange range = NSMakeRange(0, self.textStorage.length);
        while (found) {
            NSTextCheckingResult * result = [regex firstMatchInString:self.textStorage.string options:0 range:range];
            if (!result) {
                found = NO;
                break;
            }
            [mathcesToBeFound addObject:NSStringFromRange(result.range)];
            range = NSMakeRange(result.range.location + result.range.length, self.textStorage.length - result.range.length - result.range.location);
        }
//        [regex enumerateMatchesInString:[self.textStorage string] options:0 range:NSMakeRange(0, self.textStorage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
//         {
//             [self setTextColor:[NSColor colorWithRed:94.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0] range:result.range];
//         }];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (matches) {
                
                matches(mathcesToBeFound);
            }
        });
    });
}

- (void) recolorTextAtStartingIndex:(NSInteger) startingIndex
{
//    NSLog(@"%li, length of storage: %li", startingIndex, self.textStorage.length);
    if (startingIndex > self.textStorage.length - 1) {
        return;
    }
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"//.*" options:0 error:nil];
    
    
    NSTextCheckingResult *result = [regex firstMatchInString:self.textStorage.string options:0 range:NSMakeRange(startingIndex, self.textStorage.length - startingIndex)];
    if (!result) {
        return;
    }
    NSMutableAttributedString * mutableAttrString = [[NSMutableAttributedString alloc] initWithString:[self.textStorage.string substringWithRange:result.range]];
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [NSColor colorWithRed:94.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0],
                                 NSFontAttributeName: [NSFont fontWithName:@"Menlo" size:12]
                                 };
    [mutableAttrString setAttributes:attributes range:NSMakeRange(0, result.range.length)];
    [self.textStorage replaceCharactersInRange:result.range withAttributedString:mutableAttrString];
    
    
    [self recolorTextAtStartingIndex:result.range.location + result.range.length];
    
    
    


    
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
//    [self recolorTextAtStartingIndex:0];
//    [self recolorText];
    NSDate * regexStart = [NSDate date];
    [self asynchronousTaskWithCompletion:^(NSArray * matches) {
        
        NSDate *methodStart = [NSDate date];
        
//        NSLog(@"number of matches %li", matches.count);
        [self setTextColor:[NSColor blackColor]];
        [self.textStorage beginEditing];
        for (NSString * stringRange in matches) {
            NSRange range = NSRangeFromString(stringRange);
//            NSLog(@"location: %li, length: %li", range.location, range.length);
            [self setTextColor:[NSColor colorWithRed:94.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0] range:range];
        }
        [self.textStorage endEditing];
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
//        NSLog(@"regex execution time: %f s, execution time for coloring: %f s", [methodStart timeIntervalSinceDate:regexStart], executionTime);
    }];
}

@end
