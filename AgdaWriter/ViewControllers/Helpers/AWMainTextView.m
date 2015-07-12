//
//  AWMainTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 29. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWMainTextView.h"
#import "AWNotifications.h"
#import "CustomTokenCell.h"
#import "AWAgdaParser.h"
#import "AWHelper.h"
#import "AWHighlighting.h"

@implementation AgdaGoal


@end

@implementation AWMainTextView

-(void)awakeFromNib
{
//    NSLog(@"%@", self.description);
    if (!initialize) {
        [self toggleAutomaticDashSubstitution:NO];
        [self toggleContinuousSpellChecking:NO];
        
        [self setContinuousSpellCheckingEnabled:NO];
        self.delegate = self;
        [NSApplication sharedApplication].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToken:) name:@"AW.addToken" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangedInRangeWithReplacementString:) name:@"textChangedInRangeWithReplacementString" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(placeInsertionPointAtCharIndex:) name:AWPlaceInsertionPointAtCharIndex object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaGaveAction:) name:AWAgdaGaveAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCaseAction:) name:AWAgdaMakeCaseAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightCode:) name:AWAgdaHighlightCode object:nil];
        
        
        initialize = YES;
        
        mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.textStorage.string];
        // Set Attributes for attributed string
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        defaultAttributes = @{
                              NSForegroundColorAttributeName : [NSColor blackColor],
                              NSFontAttributeName : [NSFont fontWithName:[ud objectForKey:FONT_FAMILY_KEY] size:[[ud objectForKey:FONT_SIZE_KEY] doubleValue]],
                              NSBackgroundColorAttributeName : [NSColor whiteColor]
                              };
        
        goalsAttributes = @{
                            NSForegroundColorAttributeName : [NSColor blueColor],
                            NSBackgroundColorAttributeName : [NSColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5],
                            };
        
        [mutableAttributedString addAttributes:defaultAttributes range:NSMakeRange(0, mutableAttributedString.length)];
        goalsArray = [NSMutableArray new];
        
        [self openLastDocument];
        
        
        mutableSetOfActionNames = [[NSMutableSet alloc] init];
        

    }
    
    
    
}

- (AgdaGoal *)selectedGoal
{
    // User wants to know current goals.
    // Find it and, if possible, create it.
    
    NSInteger numberOfChars = 0;
    NSString * string = self.textStorage.string;
    
    // Get all ranges of goals and look if our current selection is in one of them.
    // From that, we will get goal index
    
    NSDictionary * dict = [AWAgdaParser goalIndexAndRange:self.selectedRange textStorage:self.textStorage];
    if (dict) {
        _selectedGoal = [[AgdaGoal alloc] init];
        NSRange foundRange = NSRangeFromString(dict[@"foundRange"]);
        _selectedGoal.goalIndex = [dict[@"goalIndex"] integerValue];
        _selectedGoal.startCharIndex = foundRange.location;
        _selectedGoal.endCharIndex = foundRange.location + foundRange.length;
        
        NSArray * lines = [string componentsSeparatedByString:@"\n"];
        for (NSInteger i = 0; i < lines.count; i++) {
            NSString * line = lines[i];
            if (numberOfChars + line.length >= foundRange.location + foundRange.length) {
                _selectedGoal.startRow = i + 1;
                _selectedGoal.endRow = i + 1;
                _selectedGoal.startColumn = foundRange.location - numberOfChars;
                _selectedGoal.endColumn = foundRange.location + foundRange.length - numberOfChars;
                _selectedGoal.content = [string substringWithRange:NSMakeRange(foundRange.location + 2, foundRange.length - 4)];
                
                // Compute number of empty spaces in this line
                // i.e. where code begins, indentation if you prefer :)
                NSInteger numberOfWhiteSpaces = 0;
                for (NSInteger j = 0; j < line.length; j++) {
                    if ([line characterAtIndex:j] != ' ') {
                        numberOfWhiteSpaces = j + 1;
                        _selectedGoal.numberOfEmptySpaces = j;
                        _selectedGoal.rangeOfCurrentLine = NSMakeRange(numberOfChars, line.length);
                        break;
                    }
                }
                
                return _selectedGoal;
            }
            
            numberOfChars += line.length + 1;
        }
    }
    
    return _selectedGoal;
}

- (void)insertAttachmentCell:(NSTextAttachmentCell *)cell toTextView:(NSTextView *)textView
{
    NSTextAttachment *attachment = [NSTextAttachment new];
    [attachment setAttachmentCell:cell];
    [textView insertText:[NSAttributedString attributedStringWithAttachment:attachment]];
}


-(void)textViewDidChangeSelection:(NSNotification *)notification
{
//    NSLog(@"%@", notification.userInfo);
    
//    NSRange range = [notification.userInfo[@"NSOldSelectedCharacterRange"] rangeValue];
//    NSLog(@"Selected range: (%li, %li)", range.location, range.length);
    
}


-(void)setString:(NSString *)string
{
    // Overrride this method to set Attributed string!
    [super setString:string];
    mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.textStorage.string];
    [mutableAttributedString addAttributes:defaultAttributes range:NSMakeRange(0, mutableAttributedString.length)];
    [[self textStorage] setAttributedString:mutableAttributedString];
}

- (void) openLastDocument
{
    NSUserDefaults *ud = [[NSUserDefaults alloc] init];
    NSString * path = [ud objectForKey:@"currentFile"];
    if (path) {
        NSError * error;
        NSString * fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"Error occoured when opening document: %@", error.description);
            return;
        }
        // double check if fileContent is initialized.
        if (fileContent) {
            [self setString:fileContent];
            [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL URLWithString:path]];
        }
        
    }
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    
    return YES;
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

- (void)asynchronouslyFindRangesOfQuestionMarksWithCompletion:(void (^)(NSArray *))matches;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // Asynchronously find all ranges with regex
        // Regex pattern: //.*
        // Finds all strings that begins with // and returns its range to the end of the line.
        NSMutableArray * results = [NSMutableArray new];
        
        NSRange searchRange = NSMakeRange(0, self.textStorage.length);
        NSRange foundRange;
        while (searchRange.location < self.textStorage.length) {
            searchRange.length = self.textStorage.length - searchRange.location;
            foundRange = [self.textStorage.string rangeOfString:@" ?" options:NSCaseInsensitiveSearch range:searchRange];
            if (foundRange.location != NSNotFound) {
                // found an occurrence of the substring! do stuff here
                
                
                searchRange.location = foundRange.location + foundRange.length;
            } else {
                // no more substring to find
                break;
            }
        }
        
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
    welcomeString = [welcomeString stringByAppendingString:@"--  \n"];
    welcomeString = [welcomeString stringByAppendingFormat:@"--  Created by %@ on %@ \n", NSFullUserName(), dateString];
    welcomeString = [welcomeString stringByAppendingString:@"--  \n"];
    [self setString: welcomeString];
    
    

}

- (NSRange) replaceQuestionMarkInRange:(NSRange)range WithType:(NSString *)type
{
    [self replaceCharactersInRange:range withString:type];
    [mutableAttributedString replaceCharactersInRange:range withString:type];
    
    NSRange newRange = NSMakeRange(range.location, type.length);
    return newRange;
}



- (void) agdaGaveAction:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * action = notification.object;
        NSInteger goalIndex = [action[@"goalIndex"] integerValue];
        NSString * content = action[@"content"];
        if ([content hasPrefix:@"\""] && [content hasSuffix:@"\""]) {
            content = [content substringWithRange:NSMakeRange(1, content.length - 2)];
        }
        
        // Replace given goal with content that Agda gave.
        NSLog(@"Agda gave action: goal index: %li, content: %@", goalIndex, content);
        NSRange rangeOfGoal = [AWAgdaParser goalAtIndex:goalIndex textStorage:self.textStorage];
        [self.textStorage replaceCharactersInRange:rangeOfGoal withString:content];
    }
}

-(void) allGoalsAction:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        // Parse goals
        NSArray * goals = [AWAgdaParser makeArrayOfGoalsWithSuggestions:notification.object];
        
        // Add tokens on goals
        int i = 0;
        NSRange searchRange = NSMakeRange(0, self.textStorage.length);
        NSRange foundRange;
        while (searchRange.location < self.textStorage.length) {
            searchRange.length = self.textStorage.length - searchRange.location;
            foundRange = [self.textStorage.string rangeOfString:@" ?" options:NSCaseInsensitiveSearch range:searchRange];
            if (foundRange.location != NSNotFound) {
                // found an occurrence of the substring!

//                [self addTokenAtRange:foundRange withGoalName:[goals objectAtIndex:i]];
//                NSDictionary * attributes = @{NSBackgroundColorAttributeName : [NSColor lightGrayColor]};
    
                NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:@"{!!}" attributes:nil];
                [self insertText:attrString replacementRange:NSMakeRange(foundRange.location + 1, foundRange.length - 1)];
                
                NSDictionary * goal = [AWAgdaParser goalIndexAndRange:NSMakeRange(foundRange.location + 2, 0) textStorage:self.textStorage];
                NSInteger index = [goal[@"goalIndex"] integerValue];
                
                NSDictionary * goal2 = goals[index];
                NSInteger goalIndex = [goal2[@"goalIndex"] integerValue];
                NSString * goalType = goal2[@"goalType"];
                [self.textStorage replaceCharactersInRange:NSRangeFromString(goal[@"foundRange"]) withString:[NSString stringWithFormat:@"{!%li: %@!}", goalIndex, goalType]];
                
                i++;

                searchRange.location = foundRange.location + foundRange.length;
            } else {
                // no more substring to find
                break;
            }
        }
        
        // reorder goals
        NSArray * allRangesOfGoals = [AWAgdaParser allGoalsWithRanges:self.textStorage];
        [self.textStorage beginEditing];
        for (NSInteger j = allRangesOfGoals.count - 1; j > 0; j--) {
            NSRange rangeOfGoal = NSRangeFromString(allRangesOfGoals[j]);
            if (goals.count > j) {
                NSDictionary * goal = goals[j];
                [self.textStorage replaceCharactersInRange:rangeOfGoal withString:[NSString stringWithFormat:@"{!%li: %@!}", [goal[@"goalIndex"] integerValue], goal[@"goalType"]]];
            }
            
        }
        [self.textStorage endEditing];
        
        
    }
}

-(NSString *) whitespaces:(NSInteger) n {
    NSMutableString * whiteSpaces = [NSMutableString new];
    for (NSInteger i = 0; i < n; i++) {
        [whiteSpaces appendString:@" "];
    }
    return whiteSpaces;
}

-(void)makeCaseAction:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSArray * actions = [AWAgdaParser caseSplitActions:notification.object];
        
        if (actions.count > 0) {
            AgdaGoal * currentGoal = self.lastSelectedGoal;
            if (currentGoal) {
                // Replace old line with new one
                [self.textStorage replaceCharactersInRange:currentGoal.rangeOfCurrentLine withString:@""];
                
                NSMutableString * caseActionString = [NSMutableString new];
                for (NSInteger i = 0; i < actions.count; i++) {
                    [caseActionString appendString:[self whitespaces:currentGoal.numberOfEmptySpaces]];
                    [caseActionString appendString:actions[i]];
                    [caseActionString appendString:@"\n"];
                }
                // Delete last "newline"
                [caseActionString deleteCharactersInRange:NSMakeRange(caseActionString.length - 1, 1)];
                [self.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:caseActionString attributes:@{NSFontAttributeName: [AWHelper defaultFontInAgda]}] atIndex:currentGoal.rangeOfCurrentLine.location];
               
            }
            
            

        }
        
        
    }
}

-(void) addTokenAtRange:(NSRange)range withGoalName:(NSString *)goalName
{
    NSTextAttachment * attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
    NSMutableAttributedString * text = [NSMutableAttributedString new];
    CustomTokenCell * tokenCell = [[CustomTokenCell alloc] init];
    [tokenCell setTitle:goalName];
    
    [attachment setAttachmentCell:tokenCell];
    [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [self insertText:text replacementRange: NSMakeRange(range.location + 1, range.length - 1)];

}

- (void) addToken:(NSNotification *)notification
{
    // Test only!
    NSTextAttachment * attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
    CustomTokenCell * tokenCell = [[CustomTokenCell alloc] init];
    [tokenCell setTitle:@"Here is some token!"];
    [attachment setAttachmentCell:tokenCell];
    [self insertText:[NSAttributedString attributedStringWithAttachment:attachment]];
}

- (void) placeInsertionPointAtCharIndex:(NSNotification *) notification
{
    [self setSelectedRange:NSMakeRange([notification.object integerValue] + 1, 0)];
}

- (void) highlightCode:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSArray class]]) {
        NSArray * array = notification.object;
        for (NSDictionary * dict in array) {
            NSString * actionName = dict.allKeys[0];
//            NSLog(@"action name: %@", actionName);
//            [mutableSetOfActionNames addObject:actionName];
            NSArray * args = dict[actionName];
            if (args.count > 0) {
                NSRange range = NSRangeFromString(args[0]);
                [AWHighlighting highlightCodeAtRange:range actionName:actionName textView:self];
            }
        }
//        NSLog(@"%@", mutableSetOfActionNames);
    }
}




-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
