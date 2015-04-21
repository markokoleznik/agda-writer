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
//    NSLog(@"%@", self.description);
    if (!initialize) {
        [self openLastDocument];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangedInRangeWithReplacementString:) name:@"textChangedInRangeWithReplacementString" object:nil];
        
        
        initialize = YES;
    }
    
    
}

- (void) openLastDocument
{
    NSUserDefaults *ud = [[NSUserDefaults alloc] init];
    NSString * path = [ud objectForKey:@"currentFile"];
    if (path) {
        
        NSString * fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if (fileContent) {
            [self setString:fileContent];
        }
        
    }
}

- (void)saveCurrentWork
{
    // TODO: error handling
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * fullPath = [ud objectForKey:@"currentFile"];
    NSError * error;
    NSString *content = [[self textStorage] string];
    if (content) {
        [content writeToFile:fullPath
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:&error];
        if (error) {
            NSLog(@"Error saving file. Reason: %@", error.description);
        }
    }
    

}

- (IBAction)save:(id)sender
{
    [self saveCurrentWork];
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

- (void) textChangedInRangeWithReplacementString:(NSNotification *) notification
{
    NSDictionary * dictionary = notification.object;
    NSRange range = [dictionary[@"range"] rangeValue];
    NSString * replacementString = dictionary[@"replacementString"];
    NSLog(@"range: (%li, %li), replacementString: %@", range.location, range.location + range.length, replacementString);
    
    if ([replacementString isEqualToString:@"/"]) {
        NSDate * regexStart = [NSDate date];
        [self asynchronouslyFindRangesOfCommentsWithCompletion:^(NSArray * matches) {
            
            NSDate *methodStart = [NSDate date];
            
            NSLog(@"number of matches %li", matches.count);
            [self setTextColor:[NSColor blackColor]];
            [self.textStorage beginEditing];
            
            for (NSTextCheckingResult * result in matches) {
                [self setTextColor:[NSColor colorWithRed:94.0/255.0 green:126.0/255.0 blue:28.0/255.0 alpha:1.0] range:result.range];
            }
            
            [self.textStorage endEditing];
            NSDate *methodFinish = [NSDate date];
            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
            NSLog(@"regex execution time: %f s, execution time for coloring: %f s", [methodStart timeIntervalSinceDate:regexStart], executionTime);
        }];
    }
    
    
    
}

- (void)asynchronouslyFindRangesOfCommentsWithCompletion:(void (^)(NSArray *))matches;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // Asynchronously find all ranges with regex
        // Regex pattern: //.*
        // Finds all strings that begins with // and returns its range to the end of the line.
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"//.*" options:0 error:nil];
        NSArray * results = [regex matchesInString:self.textStorage.string options:0 range:NSMakeRange(0, self.textStorage.length)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (matches) {
                
                matches(results);
            }
        });
    });
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
