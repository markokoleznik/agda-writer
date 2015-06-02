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
            while (j < action.length) {
                if ([action characterAtIndex:j] == ')') {
                    // add lisp comments to "actions"
                    [actions addObject:[action substringWithRange:NSMakeRange(i, j - i + 1)]];
                }
                j++;
            }
            i = j + 2;
        }
        else
        {
//            j++;
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
    if (actions.count > 0) {
        dict = @{actions[0]: [actions subarrayWithRange:NSMakeRange(1, actions.count - 1)]};
    }
    return dict;
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
    
    int numberOfLeftParenthesis = 0;
    int start = 0;
    int i = 0;
    while (i < reply.length) {
        if ([reply characterAtIndex:i] == '(') {
            if (numberOfLeftParenthesis == 0) {
                start = i;
            }
            numberOfLeftParenthesis ++;
        }
        else if ([reply characterAtIndex:i] == ')') {
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
            [goalsMutable addObject:subGoalArray[1]];
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
        NSLog(@"selection range: %@, result range: %@", NSStringFromRange(currentSelection),NSStringFromRange([result rangeAtIndex:1]));
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

+(NSRange) goalAtIndex: (NSInteger) index textStorage:(NSTextStorage *)textStorage
{
    NSRange foundRange;
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

@end


