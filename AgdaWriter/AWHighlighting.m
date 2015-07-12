//
//  AWHighlighting.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 12. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWHighlighting.h"

// All types are here:
// https://github.com/agda/agda/blob/master/src/data/emacs-mode/agda2-highlight.el#L385

//`bound'                  Bound variables.
//`coinductiveconstructor' Coinductive constructors.
//`datatype'               Data types.
//`dotted'                 Dotted patterns.
//`error'                  Errors.
//`field'                  Record fields.
//`function'               Functions.
//`incompletepattern'      Incomplete patterns.
//`inductiveconstructor'   Inductive constructors.
//`keyword'                Keywords.
//`module'                 Module names.
//`number'                 Numbers.
//`operator'               Operators.
//`postulate'              Postulates.
//`primitive'              Primitive functions.
//`primitivetype'          Primitive types (like Set and Prop).
//`macro'                  Macros.
//`record'                 Record types.
//`string'                 Strings.
//`symbol'                 Symbols like forall, =, ->, etc.
//`terminationproblem'     Termination problems.
//`typechecks'             Code which is being type-checked.
//`unsolvedconstraint'     Unsolved constraints, not connected to meta
//variables.
//`unsolvedmeta'           Unsolved meta variables.
//`comment'                Comments.")



NSString * const bound = @"bound";
NSString * const coinductiveconstructor = @"coinductiveconstructor";
NSString * const datatype = @"datatype";
NSString * const dotted = @"dotted";
NSString * const error = @"error";
NSString * const field = @"field";
NSString * const function = @"function";
NSString * const incompletepattern = @"incompletepattern";
NSString * const inductiveconstructor = @"inductiveconstructor";
NSString * const keyword = @"keyword";
NSString * const module = @"module";
NSString * const number = @"number";
NSString * const postulate = @"postulate";
NSString * const primitive = @"primitive";
NSString * const primitivetype = @"primitivetype";
NSString * const macro = @"macro";
NSString * const record = @"record";
NSString * const string = @"string";
NSString * const symbol = @"symbol";
NSString * const terminationproblem = @"terminationproblem";
NSString * const typechecks = @"typechecks";
NSString * const unsolvedconstraint = @"unsolvedconstraint";
NSString * const unsolvedmeta = @"unsolvedmeta";
NSString * const comment = @"comment";

NSString * const datatypeOperator = @"datatype operator";
NSString * const inductiveConstructor = @"inductiveconstructor";
NSString * const functionOperator = @"function operator";
NSString * const inductiveconstructorOperator = @"inductiveconstructor operator";





@implementation AWHighlighting

+ (void) highlightCodeAtRange:(NSRange) range actionName: (NSString *) actionName textView: (NSTextView *)textView
{
    range = NSMakeRange(range.location - 1, range.length);
    NSColor * color;
    if ([actionName isEqualToString:keyword]) {
        color = [NSColor orangeColor];
    }
    else if ([actionName isEqualToString:symbol]) {
        color = [NSColor redColor];
        
    }
    else if ([actionName isEqualToString:datatypeOperator]) {
        color = [NSColor blueColor];
    }
    else if ([actionName isEqualToString:primitivetype]) {
        color = [NSColor yellowColor];
    }
    else if ([actionName isEqualToString:function]) {
        color = [NSColor darkGrayColor];
    }
    else if ([actionName isEqualToString:inductiveConstructor]) {
        color = [NSColor purpleColor];
    }
    else if ([actionName isEqualToString:comment]) {
        color = [NSColor greenColor];
        
    }
    else if ([actionName isEqualToString:unsolvedmeta]) {
        color = [NSColor cyanColor];
    }
    if (color) {
        [textView.layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName] forCharacterRange:range];
    }
    
}

@end
