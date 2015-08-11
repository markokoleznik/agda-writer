//
//  AWAgdaParser.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 4. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWAgdaParser.h"


@implementation AWAgdaParser

-(void) parseResponse:(NSString *)response
{
    
}

/*!
@method Parses actions from Agda response
@param String action, which is response from Agda
@return returns NSDictionary with key as string (operation to perform) and array of string with parameters of operation
 */

+(NSDictionary *)parseAction:(NSString *) action
{
    // ((last . 2) . (agda2-make-case-action '("twice Z = ?" "twice (S x) = ?")))
    
    // delete prefixes on weird responses, so for example
    // ((last . 1) . (agda2-goals-action '(0 1)))
    // should go to
    // (agda2-goals-action '(0 1))
    
    if ([action hasPrefix:@"((last"]) {
        // delete last character and first two ((
        action = [action substringWithRange:NSMakeRange(5, action.length - 5 - 1)];
        int i = 0;
        while (i < action.length) {
            if ([action characterAtIndex:i] == '(') {
                action = [action substringFromIndex:i];
                break;
            }
            i++;
        }
        
        
    }
    
    NSDictionary * dict;
    if (![action hasPrefix:@"(agda2-"]) {
        return nil;
    }
    
    
    // We have agda action.
    action = [action substringWithRange:NSMakeRange(1, action.length - 2)];
    
    NSArray * actions = [[NSArray alloc] init];
    actions = [self executeParser:action];
    if (actions.count > 0) {
        dict = @{actions[0]: [actions subarrayWithRange:NSMakeRange(1, actions.count - 1)]};
    }
    return dict;
}

+(NSArray *) executeParser:(NSString *) action
{
    NSMutableArray * actions = [[NSMutableArray alloc] init];
    int i = 0;
    int j = 0;
    
    while (i < action.length) {
        j = i;
        if ([action characterAtIndex:i] == '"') {
            j++;
            while (j < action.length) {
                if ([action characterAtIndex:j] == '"') {
                    // add substring between quotation marks to array "actions"
                    [actions addObject:[action substringWithRange:NSMakeRange(i, j - i + 1)]];
                    break;
                }
                j++;
            }
            i = j + 2;
        }
        else if (i < action.length - 2 && [[action substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"'("])
        {
            NSInteger numberOfLeftParenthesis = 0;
            while (j < action.length) {
                if ([action characterAtIndex:j] == ')') {
                    numberOfLeftParenthesis--;
                    if (numberOfLeftParenthesis == 0) {
                        // add lisp comments to "actions"
                        [actions addObject:[action substringWithRange:NSMakeRange(i, j - i + 1)]];
                    }
                    
                }
                else if ([action characterAtIndex:j] == '(') {
                    numberOfLeftParenthesis++;
                }
                j++;
            }
            i = j + 2;
        }
        else
        {
            while (j < action.length) {
                if ([action characterAtIndex:j] == ' ' || j + 1 == action.length) {
                    
                    if (j + 1 == action.length) {
                        [actions addObject:[action substringWithRange:NSMakeRange(i, j - i + 1)]];
                        break;
                    }
                    
                    // add substring to "actions"
                    [actions addObject:[action substringWithRange:NSMakeRange(i, j - i)]];
                    break;
                }
                j++;
            }
            i = j + 1;
        }
    }
    return actions;
}

+(NSArray *)makeArrayOfActions:(NSString *)reply
{
    // Array contains NSDictionary objects with key as main action and array of strings as its parameters
    // Example:
    //    (agda2-highlight-load-and-delete-action "/var/folders/c6/1rfd2v_n4f32q66rsjbfqb340000gn/T/agda2-mode2743")
    //    @{@"agda2-highlight-load-and-delete-action" : @[@"/var/folders/c6/1rfd2v_n4f32q66rsjbfqb340000gn/T/agda2-mode2743"]}
    NSMutableArray * actionsWithDictionaries = [[NSMutableArray alloc] init];
    reply = [reply stringByReplacingOccurrencesOfString:@"Agda2> " withString:@""];
    NSArray * actions = [reply componentsSeparatedByString:@"\n"];
    
    
    for (NSString * action in actions) {
        NSDictionary * dict = [self parseAction:action];
        if (dict) {
            [actionsWithDictionaries addObject:dict];
        }
        
    }
    return actionsWithDictionaries;
}

+(NSArray *)makeArrayOfActionsAndDeleteActionFromString:(NSMutableString *)reply
{
    // 1.) step: make array of actions
    NSMutableArray * actionsWithDictionaries = [[NSMutableArray alloc] init];
    NSMutableArray * actions = [[NSMutableArray alloc] init];
    [reply replaceOccurrencesOfString:@"Agda2> " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, reply.length)];
    BOOL insideQuotes = NO;
    int numberOfLeftParenthesis = 0;
    int start = 0;
    int i = 0;
    while (i < reply.length) {
        if ([reply characterAtIndex:i] == '"') {
            if (insideQuotes) {
                insideQuotes = NO;
            }
            else {
                insideQuotes = YES;
            }
        }
        if ([reply characterAtIndex:i] == '(' && !insideQuotes) {
            if (numberOfLeftParenthesis == 0) {
                start = i;
            }
            numberOfLeftParenthesis ++;
        }
        else if ([reply characterAtIndex:i] == ')' && !insideQuotes) {
            numberOfLeftParenthesis --;
            if (numberOfLeftParenthesis == 0) {
                // End parsing
                NSRange rangeOfAction = NSMakeRange(start, i + 1 - start);
                [actions addObject:[reply substringWithRange:rangeOfAction]];
                // delete that part of reply
                [reply deleteCharactersInRange:NSMakeRange(0, i + 1)];
                i = 0;
            }
        }
        i++;
    }
    
    
    // 2.) step: create array of dictionaries {actionName: [arg1, arg2,...]}
    for (NSString * action in actions) {
        NSDictionary * dict = [self parseAction:action];
        if (dict) {
            [actionsWithDictionaries addObject:dict];
        }
    }
    
    return actionsWithDictionaries;
    
}

+(NSArray *)makeArrayOfGoalsWithSuggestions:(NSString *)goals
{
    NSMutableArray * goalsMutable = [[NSMutableArray alloc] init];
    goals = [goals stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray * goalsArray = [goals componentsSeparatedByString:@"\\n"];
    for (NSString * goal in goalsArray) {
        NSArray * subGoalArray = [goal componentsSeparatedByString:@" : "];
        if (subGoalArray.count >= 2) {
            NSString * goalIndex = subGoalArray[0];
            if ([goalIndex characterAtIndex:0] == '?') {
                goalIndex = [goalIndex substringFromIndex:1];
                NSDictionary * dict = @{@"goalIndex" : @([goalIndex integerValue]),
                                        @"goalType" : goal};
                [goalsMutable addObject:dict];
            }
            else {
                NSDictionary * dict = @{@"goalIndex" : @"nil",
                                        @"goalType" : goal};
                [goalsMutable addObject:dict];
            }
            
        }
    }
    return goalsMutable;
}

// Regex to find all the goals:
// (?=(\{!(?:[^!]|\{![^!]*!\})*!\}))
// By stribizhev
// http://stackoverflow.com/questions/30574174/find-range-of-goals-that-arent-in-comments-with-regex

+(NSDictionary *)goalIndexAndRange:(NSRange)currentSelection textStorage:(NSTextStorage *)textStorage
{
    NSDictionary * dict;
    NSString * regexPattern = @"(?=(\\{!(?:[^!]|\\{![^!]*!\\})*!\\}))";
    NSError * error;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSRange fullRange = NSMakeRange(0, textStorage.string.length);
    NSArray * matches = [regex matchesInString:textStorage.string options:0 range:fullRange];
    NSInteger goalIndex = 0;
    for (NSTextCheckingResult * result in matches) {
        if (currentSelection.location > [result rangeAtIndex:1].location && (currentSelection.location + currentSelection.length) < ([result rangeAtIndex:1].location + [result rangeAtIndex:1].length)) {
            // we found appropriate result
            // Convert NSRange to string
            
            dict = @{@"goalIndex" : @(goalIndex),
                     @"foundRange" : NSStringFromRange([result rangeAtIndex:1])};
            return dict;
        }
        goalIndex ++;
    }
    return dict;
}

+(NSArray *) allGoalsWithRanges:(NSTextStorage *) textStorage
{
    NSMutableArray * goals;
    NSString * regexPattern = @"(?=(\\{!(?:[^!]|\\{![^!]*!\\})*!\\}))";
    NSError * error;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSRange fullRange = NSMakeRange(0, textStorage.string.length);
    NSArray * matches = [regex matchesInString:textStorage.string options:0 range:fullRange];
    if (matches) {
        goals = [[NSMutableArray alloc] initWithCapacity:matches.count];
    }
    for (NSTextCheckingResult * result in matches) {
        [goals addObject:NSStringFromRange([result rangeAtIndex:1])];
    }
    return goals;
}


+(NSRange) goalAtIndex: (NSInteger) index textStorage:(NSTextStorage *)textStorage
{
    NSRange foundRange = NSMakeRange(NSNotFound, 0);
    // We'll use Regular Expressions to find goals range.
    NSString * regexPattern = @"(?=(\\{!(?:[^!]|\\{![^!]*!\\})*!\\}))";
    NSError * error;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray * matches = [regex matchesInString:textStorage.string options:0 range:NSMakeRange(0, textStorage.length)];
    
    if (matches.count > index) {
        NSTextCheckingResult * result = [matches objectAtIndex:index];
        foundRange = [result rangeAtIndex:1];
    }
    
    return foundRange;
}

+(NSArray *) caseSplitActions:(NSString *)reply
{
    NSMutableArray * actions = [[NSMutableArray alloc] init];
    if ([reply hasPrefix:@"'("] && [reply hasSuffix:@")"]) {
        reply = [reply substringWithRange:NSMakeRange(2, reply.length - 3)];
//        NSLog(@"substring: %@", reply);
        NSArray * actionsWithQuotes = [reply componentsSeparatedByString:@"\" \""];
        for (NSString * action in actionsWithQuotes) {
            NSString * parsedAction = action;
            if ([action hasPrefix:@"\""]) {
                parsedAction = [parsedAction substringFromIndex:1];
            }
            if ([action hasSuffix:@"\""]) {
                parsedAction = [parsedAction substringToIndex:parsedAction.length - 1];
            }
            
//            parsedAction = [parsedAction stringByAppendingString:@"\n"];
            
            [actions addObject:parsedAction];
        }
        
    }
    return actions;
}

+(NSArray *)parseDirectHighligting:(NSArray *)highlighting
{
    return @[];
}


+(NSArray *) parseHighlighting:(NSString *)highlighting
{
    /*
        We receive "highlighting" in this form:
        ((si1 ei1 (type1) nil path) (si2 ei2 (type2) path) ...)
        where:
        siN     start of range N
        eiN     end of range N
        typeN   type, for exaple "word", "symbol", "operator" ...
        path    is the path of a file
    */
    
    // ditch first two and the last two parenthesis
    if ([highlighting hasPrefix:@"(("] && [highlighting hasSuffix:@"))"]) {
        highlighting = [highlighting substringWithRange:NSMakeRange(2, highlighting.length - 4)];
    }
    NSMutableArray * result = [[NSMutableArray alloc] init];
    // create array of
    // siK eiK (typeK) path
    // note: those are now without parenthesis
    NSArray * matches = [highlighting componentsSeparatedByString:@") ("];
    
    
    for (NSString * line in matches) {
        
        NSDictionary * dict = [self parsedLineOfHighligting:line];
        if (dict) {
            [result addObject:dict];
        }
    }

    return result;
}

+ (NSDictionary *)parsedLineOfHighligting:(NSString *)line
{
    NSDictionary * dict;
    
    // first find a type
    NSRange rangeOfType = NSMakeRange(NSNotFound, 0);
    for (NSInteger i = 1; i < line.length; i++) {
        if ([line characterAtIndex:i] == '(') {
            rangeOfType.location = i + 1;
        }
        else if ([line characterAtIndex:i] == ')') {
            rangeOfType.length = i - rangeOfType.location;
            break;
        }
    }
    NSString * typeName;
    if (rangeOfType.location == NSNotFound) {
        // fall back if range isn't found... Just in case! :)
        return nil;
    }
    typeName = [line substringWithRange:rangeOfType];
    // delete that type from string
    NSString const * lineCopy = [NSString stringWithFormat:@"%@%@", [line substringToIndex:rangeOfType.location - 2], [line substringFromIndex:rangeOfType.location + rangeOfType.length + 1]];
    
    // get those components:
    // @[siK, eik, path]
    NSArray * components = [lineCopy componentsSeparatedByString:@" "];
    if (components.count > 2) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *startNumber = [f numberFromString:components[0]];
        NSNumber *endNumber = [f numberFromString:components[1]];
        NSRange range = NSMakeRange([startNumber integerValue], [endNumber integerValue] - [startNumber integerValue]);
        
        dict = @{typeName : @[NSStringFromRange(range)]};
        
    }
    
    return dict;
}

+ (NSRange) rangeFromLineNumber:(NSUInteger)lineNumber
                   andLineRange:(NSRange) lineRange
                         string:(NSString *)string {
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    NSInteger numberOfChars = 0;
    NSArray * lines = [string componentsSeparatedByString:@"\n"];
    NSInteger i = 0;
    for (NSString * line in lines) {
        if (i + 1 == lineNumber) {
            range = NSMakeRange(numberOfChars + lineRange.location - 1, lineRange.length);
            return range;
        }
        numberOfChars += line.length + 1;
        i++;
    }
    
    return range;
}

+(NSInteger) parseGotoAction:(NSString *)reply {
    NSInteger index;
    
    if ([reply hasSuffix:@")"]) {
        NSArray * components = [reply componentsSeparatedByString:@" . "];
        NSString * lastComponent = components[components.count - 1];
        lastComponent = [lastComponent substringToIndex:lastComponent.length - 1];
        return [lastComponent integerValue];
    }
    
    return index;
}

+ (NSMutableAttributedString *)parseRangesAndAddAttachments:(NSAttributedString *)reply parentViewController:(id)parentViewController;
{
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithAttributedString:reply];
    
    
    NSString * regexPattern = @"[0-9]*,[0-9]*-[0-9]*";
    NSError * error;
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray * matches = [regex matchesInString:[reply string] options:0 range:NSMakeRange(0, reply.length)];
    
    // replace all "ranges" with cell attachments.
    
    for (NSTextCheckingResult * result in [matches reverseObjectEnumerator]) {
        
        NSTextAttachment * attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
        NSMutableAttributedString * text = [NSMutableAttributedString new];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        CustomTokenCell * tokenCell = [[CustomTokenCell alloc] init];
        tokenCell.parentViewController = parentViewController;
        NSString * substringOfRange = [[reply attributedSubstringFromRange:result.range] string];
        [tokenCell setTitle:substringOfRange];
        [attachment setAttachmentCell:tokenCell];
        [text appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        [attrString replaceCharactersInRange:result.range withAttributedString:text];
        
    }
    
    
    return attrString;
}

@end
