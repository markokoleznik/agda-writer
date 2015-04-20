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
        NSLog(@"substring to %i: %@", i, [action substringToIndex:i + 1]);
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
        else if ([[action substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"'("])
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
            j++;
            while (j < action.length) {
                if ([action characterAtIndex:j] == ' ') {
                    
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
    NSLog(@"Dictionary: %@", dict);
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

@end


