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
//        [NSApplication sharedApplication].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToken:) name:@"AW.addToken" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangedInRangeWithReplacementString:) name:@"textChangedInRangeWithReplacementString" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(placeInsertionPointAtCharIndex:) name:AWPlaceInsertionPointAtCharIndex object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaGaveAction:) name:AWAgdaGaveAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCaseAction:) name:AWAgdaMakeCaseAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightCode:) name:AWAgdaHighlightCode object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearHighlighting:) name:AWAgdaClearHighlighting object:nil];
        
        
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

        
//        [self openLastDocument];
        
        
        mutableSetOfActionNames = [[NSMutableSet alloc] init];
        

    }
    
    
    
}


- (AgdaGoal *)selectedGoal
{
    // User wants to know current goals.
    // Find it and, if possible, create it.
    
    NSInteger numberOfChars = 0;
    NSString * string = self.textStorage.string;
    
    _selectedGoal = nil;
    
    // Get all ranges of goals and look if our current selection is in one of them.
    // From that, we will get goal index
    
    NSDictionary * dict = [AWAgdaParser goalIndexAndRange:self.selectedRange textStorage:self.textStorage];
    if (dict) {
        _selectedGoal = [[AgdaGoal alloc] init];
        NSRange foundRange = NSRangeFromString(dict[@"foundRange"]);
        _selectedGoal.goalIndex = [dict[@"goalIndex"] integerValue];
        _selectedGoal.agdaGoalIndex = [goalsIndexesArray[_selectedGoal.goalIndex][@"goalIndex"] integerValue];
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
                _selectedGoal.content = [_selectedGoal.content stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
//                _selectedGoal.content = [_selectedGoal.content stringByReplacingOccurrencesOfString:@"\\" withString:@"'\\"];
                
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

-(void)paste:(id)sender
{
    [super pasteAsPlainText:sender];
    NSLog(@"Pasting");
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

-(void)keyUp:(NSEvent *)theEvent
{
//    NSLog(@"Key pressed: %@", theEvent);
    if ([theEvent.characters isEqualToString:@" "] || theEvent.keyCode == 36) {
        NSRange rangeOfCurrentWord = [self rangeOfCurrentWord];
        if (rangeOfCurrentWord.location != NSNotFound) {
            NSString * currentWord = [self.string substringWithRange:rangeOfCurrentWord];
            NSDictionary * keyBindings = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Key Bindings" withExtension:@"plist"]];
            NSString * replacementString = [keyBindings objectForKey:currentWord];
            if (replacementString) {
                [self.textStorage replaceCharactersInRange:rangeOfCurrentWord withString:replacementString];
            }
        }
        
        
        
    }
}

-(NSRange) rangeOfCurrentWord
{
    NSRange word = NSMakeRange(NSNotFound, 0);
    
    NSInteger i = self.selectedRange.location - 2;
    NSInteger j = self.selectedRange.location - 2;
    while (i > 0) {
        if ([self.string characterAtIndex:i] == ' ' || [self.string characterAtIndex:i] == '\n') {
            word = NSMakeRange(i + 1, j - i);
            
            break;
            
        }
        else if (i == 1) {
            word = NSMakeRange(0, j + 1);
        }

        i--;
    }
    if (word.location != NSNotFound) {
        NSLog(@"%@", [self.string substringWithRange:word]);
    }
    
    return word;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{

    // Find how many spaces are in previous line.
    if ([replacementString isEqualToString:@"\n"]) {
        BOOL shouldBreak = NO;
        NSInteger numberOfSpaces = 0;
        for (NSInteger i = affectedCharRange.location - 1; i > 0; i--) {
            if ([self.string characterAtIndex:i] == '\n') {
                // we found previous line!
                if (i + 3 < self.textStorage.string.length && [[self.string substringWithRange:NSMakeRange(i + 1, 2)] isEqualToString:@"{-"]) {
                    // begin multiline comment
                    [self.textStorage.mutableString insertString:@"   \n-}" atIndex:i + 3];
                    [self setSelectedRange:NSMakeRange(i + 6, 0)];
                    shouldBreak = YES;
                    break;
                }
                for (NSInteger j = i + 1; j < self.string.length; j++) {
                    if ([self.string characterAtIndex:j] != ' ') {
                        numberOfSpaces = j - i - 1;
//                        NSLog(@"Number of spaces: %li", numberOfSpaces);
                        shouldBreak = YES;
                        break;
                    }
                }
            }
            if (shouldBreak) {
                break;
            }
        }
        [self replaceCharactersInRange:affectedCharRange withString:[self whitespaces:numberOfSpaces]];
        
        
    }
    
    return YES;
}

-(void)setString:(NSString *)string
{
    // Overrride this method to set Attributed string!
    [super setString:string];
    mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.textStorage.string];
    [mutableAttributedString addAttributes:defaultAttributes range:NSMakeRange(0, mutableAttributedString.length)];
    [[self textStorage] setAttributedString:mutableAttributedString];
}



-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    
    return YES;
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
    if (notification.object != self.parentViewController) {
        return;
    }
    if ([notification.userInfo[@"action"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary * action = notification.userInfo[@"action"];
        NSInteger goalIndex = [action[@"goalIndex"] integerValue];
        NSString * content = action[@"content"];
        if ([content hasPrefix:@"\""] && [content hasSuffix:@"\""]) {
            content = [content substringWithRange:NSMakeRange(1, content.length - 2)];
        }
        
        // Replace given goal with content that Agda gave.
        NSLog(@"Agda gave action: goal index: %li, content: %@", goalIndex, content);
        NSInteger i = 0;
        for (NSDictionary * dict in goalsIndexesArray) {
            if ([dict[@"goalIndex"] integerValue] == goalIndex) {
                goalIndex = i;
            }
            i++;
        }
        NSRange rangeOfGoal = [AWAgdaParser goalAtIndex:goalIndex textStorage:self.textStorage];
        if (rangeOfGoal.location + rangeOfGoal.length <= self.string.length) {
            [self.textStorage replaceCharactersInRange:rangeOfGoal withString:content];
        }
        
        
        // Save document!
        if ([self.parentViewController respondsToSelector:@selector(saveDocument:)]) {
            [self.parentViewController saveDocument:self];
        }
        
        
    }
}



-(void) allGoalsAction:(NSNotification *)notification
{
    if (notification.object != self.parentViewController) {
        return;
    }
    if ([notification.userInfo[@"goals"] isKindOfClass:[NSString class]]) {
        
        // save current view

        NSRange selectedRange = [self selectedRange];
        
        // Parse goals
        NSArray * goals = [AWAgdaParser makeArrayOfGoalsWithSuggestions:notification.userInfo[@"goals"]];
        if (goals.count == 0) {
            return;
        }
        
        goalsIndexesArray = [goals copy];
        
        // Add tokens on goals
        int i = 0;
        NSRange searchRange = NSMakeRange(0, self.textStorage.length);
        NSRange foundRange;
        while (searchRange.location < self.textStorage.length) {
            searchRange.length = self.textStorage.length - searchRange.location;
            foundRange = [self.textStorage.string rangeOfString:@" ?" options:NSCaseInsensitiveSearch range:searchRange];
            if (foundRange.location != NSNotFound) {
                // found an occurrence of the substring!
    
                NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:@"{!!}" attributes:nil];
                [self insertText:attrString replacementRange:NSMakeRange(foundRange.location + 1, foundRange.length - 1)];
                
                NSDictionary * goal = [AWAgdaParser goalIndexAndRange:NSMakeRange(foundRange.location + 2, 0) textStorage:self.textStorage];
                
                if (i == 0) {
                    selectedRange = NSRangeFromString(goal[@"foundRange"]);
                    selectedRange = NSMakeRange(selectedRange.location + 2, 0);
                }
                
                
                i++;

                searchRange.location = foundRange.location + foundRange.length;
            } else {
                // no more substring to find
                break;
            }
        }

        [self.textStorage endEditing];
        if (selectedRange.location + selectedRange.length < self.string.length) {
            [self setSelectedRange:selectedRange];
        }
        
        
        
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
    if (notification.object == self.parentViewController) {
        if ([notification.userInfo[@"action"] isKindOfClass:[NSString class]]) {
            NSArray * actions = [AWAgdaParser caseSplitActions:notification.userInfo[@"action"]];
            
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
                    
                    [self replaceQuestionMarksWithGoals];
                    
                    // TODO: reorder goals
                    
                }
            }
        }
    }
}

- (void)replaceQuestionMarksWithGoals
{
    [self asynchronouslyFindRangesOfQuestionMarksWithCompletion:^(NSArray * matches) {
        for (NSInteger i = 0; i < matches.count; i++) {
            NSRange foundRange = NSRangeFromString(matches[i]);
            [self.textStorage replaceCharactersInRange:foundRange withString:@"{!!}"];
        }
    }];
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
    if (notification.object == self.parentViewController) {
        NSArray * array = notification.userInfo[@"actions"];
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

- (void)clearHighlighting:(NSNotification *) notification
{
    if (notification.object == self.parentViewController) {
        [self.layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName] forCharacterRange:NSMakeRange(0, self.string.length)];
    }
    
}






-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
