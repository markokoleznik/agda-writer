//
//  UnicodeTransformator.m
//  Agda Writer
//
//  Created by Marko Koležnik on 24. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "UnicodeTransformator.h"

@implementation UnicodeTransformator

+ (NSString *)transformToUnicode:(NSString *)input
{
    NSCharacterSet * characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\t ()"];
    NSArray * components = [input componentsSeparatedByCharactersInSet:characterSet];
    NSDictionary * keyBindings = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Key Bindings" withExtension:@"plist"]];
    for (NSString * token in components) {
        NSString * replacementString = [keyBindings objectForKey:token];
        if (replacementString) {
            input = [input stringByReplacingOccurrencesOfString:token withString:replacementString];
        }
    }
    
    return input;
}

@end
