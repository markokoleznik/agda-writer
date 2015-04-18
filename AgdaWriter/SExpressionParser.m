//
//  SExpressionParser.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "SExpressionParser.h"

@implementation SExpressionParser

- (NSString *) addParenthesis:(NSString *)input
{
    NSMutableString * mutableInput = [[NSMutableString alloc] init];
    NSInteger i = mutableInput.length - 1;
    while (i > 0) {
        
    }
    return nil;
}

- (SExpression *) treeWithExpandedSExpression: (NSString *)input tree: (SExpression *)inputTree
{
    if (input.length == 0) {
        return inputTree;
    }
    
    
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@" \\. " options:0 error:nil];
    NSTextCheckingResult * result = [regex firstMatchInString:input options:0 range:NSMakeRange(0, input.length)];
    
    if (!result) {
        NSString * value = [input substringWithRange:NSMakeRange(1, input.length - 2)];
        inputTree.left = [[SExpression alloc] initWithValue:value];
        return inputTree;
    }
    NSString * leftSubstring = [input substringWithRange:NSMakeRange(1, result.range.location - 1)];
    inputTree.left = [[SExpression alloc] initWithValue:leftSubstring];
    NSString * rightSubstring = [input substringWithRange:NSMakeRange(result.range.location + result.range.length, input.length - result.range.location - result.range.length - 1)];
    inputTree.right = [[SExpression alloc] initWithValue:rightSubstring];
    inputTree.right = [self treeWithExpandedSExpression:rightSubstring tree:inputTree.right];
    

    
    
    return inputTree;
}


// input : (a b)
// output: (a . (b . nil))

- (NSString *) expand: (NSString *) input
{
    
    
    NSMutableString * inputCopy = [[NSMutableString alloc] initWithString:input];
    NSInteger i = 0;
    BOOL skip = NO;
    while (i < inputCopy.length) {
        
        if ([inputCopy characterAtIndex:i] == ' ' && !skip)
        {
            if (i + 3 < inputCopy.length && [[inputCopy substringWithRange:NSMakeRange(i, 3)] isEqualToString:@" . "]) {
                i = i + 3;
                continue;
            }
            
            [inputCopy insertString:@". (" atIndex:i + 1];
            NSInteger j = i;
            while (j < inputCopy.length) {
                if ([inputCopy characterAtIndex:j] == ')') {

                    if (j > 6 && [[inputCopy substringWithRange:NSMakeRange(j - 6, 6)] isEqualToString:@" . nil"])
                    {
                        [inputCopy insertString:@")" atIndex:j];
                        i = i + 3;
                        break;
                    }
                    [inputCopy insertString:@" . nil)" atIndex:j];
                    i = i + 3;
                    break;
                }
                j++;
            }
            
        }
        else if ([inputCopy characterAtIndex:i] == '"')
        {
            if (skip) {
                skip = NO;
            }
            else
            {
                skip = YES;
            }
            
        }
        else if ([inputCopy characterAtIndex:i] == '\''){
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"'\(([^)]+))" options:0 error:nil];
            NSTextCheckingResult * result = [regex firstMatchInString:inputCopy options:0 range:NSMakeRange(i, inputCopy.length - i)];
            i = i + result.range.length + 1;
            
        }
        
        i++;
    }
    return inputCopy;
}

@end
