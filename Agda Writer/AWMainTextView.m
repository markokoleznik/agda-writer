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

@implementation AWMainTextView {
    BOOL autocompleteTriggered;
}


-(void)awakeFromNib
{
    if (!initialize) {
//        self.textView.automaticQuoteSubstitutionEnabled = NO;
//        self.textView.automaticDashSubstitutionEnabled = NO;
//        self.textView.automaticTextReplacementEnabled = NO;
        [self setAutomaticQuoteSubstitutionEnabled:NO];
        [self setAutomaticDashSubstitutionEnabled:NO];
        [self toggleAutomaticDashSubstitution:NO];
        [self toggleContinuousSpellChecking:NO];
        [self setContinuousSpellCheckingEnabled:NO];
        self.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allGoalsAction:) name:AWAllGoals object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(placeInsertionPointAtCharIndex:) name:AWPlaceInsertionPointAtCharIndex object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaGaveAction:) name:AWAgdaGaveAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCaseAction:) name:AWAgdaMakeCaseAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightCode:) name:AWAgdaHighlightCode object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearHighlighting:) name:AWAgdaClearHighlighting object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(agdaGotoIndex:) name:AWAgdaGoto object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectAgdaRange:) name:AWSelectAgdaRange object:nil];
        
        
        initialize = YES;
        [self setTypingAttributes:@{NSFontAttributeName : [AWHelper defaultFontInAgda]}];
        mutableSetOfActionNames = [[NSMutableSet alloc] init];
        
        [self setTextContainerInset:NSMakeSize( 0.0, 5.0 )];
        
        

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
        _selectedGoal.rangeOfContent = NSMakeRange(NSNotFound, 0);
        NSRange foundRange = NSRangeFromString(dict[@"foundRange"]);
        _selectedGoal.goalIndex = [dict[@"goalIndex"] integerValue];
        _selectedGoal.agdaGoalIndex = [goalsIndexesArray[_selectedGoal.goalIndex][@"goalIndex"] integerValue];
        _selectedGoal.startCharIndex = foundRange.location + 3;
        _selectedGoal.endCharIndex = foundRange.location + foundRange.length - 1;
        
        NSArray * lines = [string componentsSeparatedByString:@"\n"];
        for (NSInteger i = 0; i < lines.count; i++) {
            NSString * line = lines[i];
            if (numberOfChars + line.length >= foundRange.location) {
                _selectedGoal.startRow = i + 1;
                // Where is end row?
                // sum all of the new lines.
                _selectedGoal.endRow = i + 1;
                _selectedGoal.startColumn = foundRange.location - numberOfChars + 3;
                _selectedGoal.endColumn = foundRange.location + foundRange.length - numberOfChars - 1;
                _selectedGoal.rangeOfContent = NSMakeRange(foundRange.location + 2, foundRange.length - 4);
                _selectedGoal.content = [string substringWithRange:_selectedGoal.rangeOfContent];
                
                NSArray * contentSeparatedWithNewLines = [_selectedGoal.content componentsSeparatedByString:@"\n"];
                if (contentSeparatedWithNewLines.count > 1) {
                    _selectedGoal.endRow = (i + 1) + (contentSeparatedWithNewLines.count - 1);
                    NSString * lastComponent = contentSeparatedWithNewLines[contentSeparatedWithNewLines.count - 1];
                    _selectedGoal.endColumn = lastComponent.length;
                }
                
                _selectedGoal.content = [_selectedGoal.content
                                         stringByReplacingOccurrencesOfString:@"\\"
                                         withString:@"\\\\"];
                _selectedGoal.content = [_selectedGoal.content stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                
                // Compute number of empty spaces in this line
                // i.e. where code begins, indentation if you prefer :)
                for (NSInteger j = 0; j < line.length; j++) {
                    if ([line characterAtIndex:j] != ' ') {
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
}


- (void) transformLastWordToUnicode
{
    NSRange rangeOfCurrentWord = [self rangeOfCurrentWord];

    if (rangeOfCurrentWord.location != NSNotFound) {
        NSString * currentWord = [self.string substringWithRange:rangeOfCurrentWord];
//        NSLog(@"Current word: %@", currentWord);
        NSDictionary * keyBindings = [AWHelper keyBindings];
        NSString * replacementString = [keyBindings objectForKey:currentWord];
        if (replacementString) {
            
            BOOL shouldReplace = [self shouldChangeTextInRange:rangeOfCurrentWord replacementString:replacementString];
            if (shouldReplace) {
                [self setTypingAttributes:@{NSFontAttributeName : [AWHelper defaultFontInAgda]}];
                [self replaceCharactersInRange:rangeOfCurrentWord withString:replacementString];
                
            }
            
        }
    }
    
}

-(NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex
{
    NSMutableArray * itemsToRemove = [[NSMutableArray alloc] init];
    for (NSMenuItem * item in menu.itemArray) {
        if ([item.title isEqualToString:@"Cut"] ||
            [item.title isEqualToString:@"Copy"] ||
            [item.title isEqualToString:@"Paste"] ||
            [item.title isEqualToString:@"SearchWithGoogle"]) {
        }
        else {
            [itemsToRemove addObject:item];
        }
    }
    for (NSMenuItem * itemToRemove in itemsToRemove) {
        [menu removeItem:itemToRemove];
    }
    return menu;
}

-(BOOL)shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    if ([replacementString isEqualToString:@"—"]) {
        [self setAutomaticDashSubstitutionEnabled:NO];
        return NO;
    }
    return [super shouldChangeTextInRange:affectedCharRange replacementString:replacementString];
}

-(void)keyUp:(NSEvent *)theEvent
{
//    NSLog(@"Key pressed: %@", theEvent);
    [super keyUp:theEvent];
    if (([theEvent.characters isEqualToString:@" "])) {
        [self transformLastWordToUnicode];
        return;
        
    }
    else if (theEvent.keyCode == 51 || [@[@123, @124, @125, @126, @53] containsObject:[NSNumber numberWithInteger:theEvent.keyCode]]) {
        // delete, up, down, left, right
        return;
    }
    else if (theEvent.keyCode == 36 || theEvent.keyCode == 48) {
        // enter or tab is pressed
        [self transformLastWordToUnicode];
        
    }
    if (!autocompleteTriggered) {
        [self performSelector:@selector(complete:) withObject:nil afterDelay:[AWHelper delayForAutocomplete]];
        autocompleteTriggered = YES;
    }
    
}



-(void)applyUnicodeTransformation
{

    NSMutableArray * words = [[NSMutableArray alloc] init];
    
    NSArray * lines = [self.string componentsSeparatedByString:@"\n"];
    for (NSString * line in lines) {
        [words addObjectsFromArray:[line componentsSeparatedByString:@" "]];
    }
    NSDictionary * keyBindings = [AWHelper keyBindings];
    for (NSString * word in words) {
        NSString * replacementString = [keyBindings objectForKey:word];
        if (replacementString) {
            self.string = [self.string stringByReplacingOccurrencesOfString:word withString:replacementString];
        }
    }
}



-(void)complete:(id)sender
{
    [super complete:sender];
    autocompleteTriggered = NO;
}



-(NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    NSString * partialWord = [self.string substringWithRange:charRange];
    if (charRange.location == 0) {
        return @[];
    }
    // Don't harass user if he writes '='
    if ([partialWord isEqualToString:@"="] ||
        [partialWord isEqualToString:@"_"]) {
        return @[];
    }
    if (charRange.location - 1 > 0 && [self.string characterAtIndex:charRange.location - 1] == '\\') {
        partialWord = [self.string substringWithRange:NSMakeRange(charRange.location - 1, charRange.length + 1)];
    }
    NSDictionary * keyBindings = [AWHelper keyBindings];
    
    
    NSMutableArray * mutableArray = [[NSMutableArray alloc] init];
    NSArray * filteredArray = [keyBindings.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString * name = (NSString *)evaluatedObject;
        return [name hasPrefix:partialWord];
    }]];
    
    for (NSString * name in filteredArray) {
        if ([name hasPrefix:@"\\"]) {
            [mutableArray addObject:[name substringFromIndex:1]];
        }
        else {
            [mutableArray addObject:name];
        }
    }
    
    [mutableArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * name1 = (NSString *)obj1;
        NSString * name2 = (NSString *)obj2;
        if ([name1 hasPrefix:@"\\"]) {
            name1 = [name1 substringFromIndex:1];
        }
        if ([name2 hasPrefix:@"\\"]) {
            name2 = [name2 substringFromIndex:1];
        }
        return [name1 compare:name2];
    }];
    
    if (filteredArray.count == 1 && [filteredArray[0] isEqualToString:partialWord]) {
        return @[];
    }
    
//    NSLog(@"elapsed time: %f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
    
    return mutableArray;
}

-(NSRange) rangeOfCurrentWord
{
    NSRange word = NSMakeRange(NSNotFound, 0);
    
    NSInteger i = self.selectedRange.location - 1;
    NSInteger j = self.selectedRange.location - 1;
    while (i > 0) {
        
        
        
        if (i == j && ([self.string characterAtIndex:i] == ' ' || [self.string characterAtIndex:i] == '\n' || [[self.string substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"\t"])) {
            i--;
            j--;
            continue;
        }
        if ([self.string characterAtIndex:i] == ' ' || [self.string characterAtIndex:i] == '\n' || [[self.string substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"\t"]) {
            word = NSMakeRange(i + 1, j - i);
            
            break;
            
        }
        else if (i == 1) {
            word = NSMakeRange(0, j + 1);
        }

        i--;
    }
    if (word.location != NSNotFound) {
        if (word.length > 1 && [self.string characterAtIndex:word.location] == '(') {
            word = NSMakeRange(word.location + 1, word.length - 1);
        }
        if (word.length > 1 && [self.string characterAtIndex:word.location + word.length - 1] == ')') {
            word = NSMakeRange(word.location, word.length - 1);
        }
//        NSLog(@"%@", [self.string substringWithRange:word]);
    }
    
    return word;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    if (affectedCharRange.location > 0) {
        NSRange newRange = NSMakeRange(affectedCharRange.location - 1, 1);
        NSString * substring = [self.string substringWithRange:newRange];
        if ([substring isEqualToString:@"_"] || [substring isEqualToString:@"^"]) {
            // underscore action
            substring = [substring stringByAppendingString:replacementString];
            if (substring.length == 2) {
                BOOL foundAction = [self transformToSubscriptCharacter:substring atRange:newRange];
                if (foundAction) {
                    return NO;
                }
            }
            
        }
    }

    // Find how many spaces are in previous line.
    if ([replacementString isEqualToString:@"\n"]) {
        if (self.string.length > affectedCharRange.location + affectedCharRange.length) {
            if ([self.string characterAtIndex:affectedCharRange.location] != '\n') {
                return YES;
            }
        }
        BOOL shouldBreak = NO;
        NSInteger numberOfSpaces = 0;
        for (NSInteger i = affectedCharRange.location - 1; i > 0; i--) {
            if ([self.string characterAtIndex:i] == '\n' || i == 0) {
                // we found previous line!
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
        if ([self shouldChangeTextInRange:affectedCharRange replacementString:[self whitespaces:numberOfSpaces]]) {
            [self replaceCharactersInRange:affectedCharRange withString:[self whitespaces:numberOfSpaces]];
            
        }
        
    }
//
//    if (affectedCharRange.location > 1) {
//        
//    }
    
    return YES;
}

- (BOOL) transformToSubscriptCharacter:(NSString *)action atRange:(NSRange)range
{
    NSDictionary * keyBindings = [AWHelper keyBindings];
    NSString * replacementString = [keyBindings objectForKey:action];
    if (replacementString) {
        BOOL shouldReplace = [self shouldChangeTextInRange:range replacementString:replacementString];
        if (shouldReplace) {
            [self replaceCharactersInRange:range withString:replacementString];
            return YES;
        }
        
    }
    return NO;
}

-(void)textViewDidChangeSelection:(NSNotification *)notification
{
    AgdaGoal * goal = self.selectedGoal;
    if (goal) {
        NSLog(@"User is inside of a goal.");
        [self.mainTextViewDelegate highlightSelectedGoalAtRow:goal.goalIndex];
    }
    if (!goal) {
        [self.mainTextViewDelegate highlightSelectedGoalAtRow:-1];
    }
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
        content = [content stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
        
        // Replace given goal with content that Agda gave.
//        NSLog(@"Agda gave action: goal index: %li, content: %@", goalIndex, content);
        NSInteger i = 0;
        for (NSDictionary * dict in goalsIndexesArray) {
            if ([dict[@"goalIndex"] integerValue] == goalIndex) {
                goalIndex = i;
                break;
            }
            i++;
        }
        NSRange rangeOfGoal = [AWAgdaParser goalAtIndex:goalIndex textStorage:self.textStorage];
        if (rangeOfGoal.location + rangeOfGoal.length <= self.string.length) {
            if ([self shouldChangeTextInRange:rangeOfGoal replacementString:content]) {

                [self.textStorage replaceCharactersInRange:rangeOfGoal withString:content];
            }
            
        }
        
        
        // Save document!
        // HACK: Force save document after 1 second.
        // This prevents UI to "freeze" when saving.
        if ([self.parentViewController respondsToSelector:@selector(saveDocument:)]) {
            [self.parentViewController performSelector:@selector(saveDocument:) withObject:nil afterDelay:1.0];
        }
    }
}

-(void)selectAgdaRange:(NSNotification *)notification {
    if (notification.object != self.parentViewController) {
        return;
    }
    NSDictionary * dict = notification.userInfo;
    NSString * agdaRange = dict[@"agdaRange"];
    NSArray * components = [agdaRange componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",-"]];
    if (components.count == 3) {
        NSInteger lineNumber = [components[0] integerValue];
        NSInteger startRange = [components[1] integerValue];
        NSInteger endRange = [components[2] integerValue];
        NSRange lineRange = NSMakeRange(startRange, endRange - startRange);
    
        NSRange actualRange = [AWAgdaParser rangeFromLineNumber:lineNumber andLineRange:lineRange   string:self.string];
        
        [self.window makeFirstResponder:self];
        
        if (self.string.length > actualRange.location + actualRange.length) {
            [self scrollRangeToVisible:actualRange];
            [self showFindIndicatorForRange:actualRange];
            [self setSelectedRange:actualRange];
        }
        
        
    }
}


-(void)agdaGotoIndex:(NSNotification *)notification {
    if (notification.object != self.parentViewController) {
        return;
    }
    if ([notification.userInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = notification.userInfo;
        NSInteger index = [dict[@"index"] integerValue];
        [self scrollRangeToVisible:NSMakeRange(index - 1, 0)];
        [self setSelectedRange:NSMakeRange(index - 1, 0)];
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
    

                if ([self shouldChangeTextInRange:NSMakeRange(foundRange.location + 1, foundRange.length - 1) replacementString:@"{!!}"]) {
                    [self replaceCharactersInRange:NSMakeRange(foundRange.location + 1, foundRange.length - 1) withString:@"{!!}"];
                }
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
                    if ([self shouldChangeTextInRange:currentGoal.rangeOfCurrentLine replacementString:@""]) {
                        [self replaceCharactersInRange:currentGoal.rangeOfCurrentLine withString:@""];
                    }
                    
                    
                    
                    NSMutableString * caseActionString = [NSMutableString new];
                    for (NSInteger i = 0; i < actions.count; i++) {
                        [caseActionString appendString:[self whitespaces:currentGoal.numberOfEmptySpaces]];
                        [caseActionString appendString:actions[i]];
                        [caseActionString appendString:@"\n"];
                    }
                    // Delete last "newline"
                    
                    [caseActionString deleteCharactersInRange:NSMakeRange(caseActionString.length - 1, 1)];
                    
//                    [self.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:caseActionString attributes:@{NSFontAttributeName: [AWHelper defaultFontInAgda]}] atIndex:currentGoal.rangeOfCurrentLine.location];
                    if ([self shouldChangeTextInRange:NSMakeRange(currentGoal.rangeOfCurrentLine.location, 0) replacementString:caseActionString]) {
                        [self replaceCharactersInRange:NSMakeRange(currentGoal.rangeOfCurrentLine.location, 0) withString:caseActionString];
                    }

                    [self replaceQuestionMarksWithGoals];
                    
                    
                }
            }
        }
    }
//    if ([self.parentViewController respondsToSelector:@selector(saveDocument:)]) {
//        [self.parentViewController performSelector:@selector(saveDocument:)];
//    }
}

- (void)replaceQuestionMarksWithGoals
{
    [self asynchronouslyFindRangesOfQuestionMarksWithCompletion:^(NSArray * matches) {
        for (NSInteger i = 0; i < matches.count; i++) {
            NSRange foundRange = NSRangeFromString(matches[i]);
            if ([self shouldChangeTextInRange:foundRange replacementString:@"{!!}"]) {
                [self replaceCharactersInRange:foundRange withString:@"{!!}"];
            }
            
        }
    }];
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
            NSArray * args = dict[actionName];
            if (args.count > 0) {
                NSRange range = NSRangeFromString(args[0]);
                [AWHighlighting highlightCodeAtRange:range actionName:actionName textView:self];
            }
        }
    }

}

- (void)clearHighlighting:(NSNotification *) notification
{
    if (notification.object == self.parentViewController) {
        [self clearHighligting];
    }
    
}

- (void) clearHighligting
{
    [self.layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName] forCharacterRange:NSMakeRange(0, self.string.length)];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
