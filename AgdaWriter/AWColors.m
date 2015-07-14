//
//  AWColors.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#define COLOR_MAX_VALUE 255.0

#import "AWColors.h"


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


#define darkRedColor [NSColor colorWithRed:160.0/COLOR_MAX_VALUE green:16.0/COLOR_MAX_VALUE blue:26.0/COLOR_MAX_VALUE alpha:1.0]
#define orangeColor [NSColor colorWithRed:192.0/COLOR_MAX_VALUE green:81.0/COLOR_MAX_VALUE blue:6.0/COLOR_MAX_VALUE alpha:1.0]
#define purpleColor [NSColor colorWithRed:172.0/COLOR_MAX_VALUE green:2.0/COLOR_MAX_VALUE blue:128.0/COLOR_MAX_VALUE alpha:1.0]
#define blueColor [NSColor colorWithRed:0.0/COLOR_MAX_VALUE green:1.0/COLOR_MAX_VALUE blue:193.0/COLOR_MAX_VALUE alpha:1.0]
#define darkGreyColor [NSColor colorWithRed:49.0/COLOR_MAX_VALUE green:49.0/COLOR_MAX_VALUE blue:49.0/COLOR_MAX_VALUE alpha:1.0]
#define greenColor [NSColor colorWithRed:20.0/COLOR_MAX_VALUE green:124.0/COLOR_MAX_VALUE blue:0.0/COLOR_MAX_VALUE alpha:1.0]
#define errorColor [NSColor redColor]
#define defaultColor [NSColor darkGrayColor]
#define pinkColor [NSColor colorWithRed:231.0/COLOR_MAX_VALUE green:0.0/COLOR_MAX_VALUE blue:118.0/COLOR_MAX_VALUE alpha:1.0]
#define yellowColor [NSColor yellowColor]

NSString * const AWbound = @"bound";
NSString * const AWcoinductiveconstructor = @"coinductiveconstructor";
NSString * const AWdatatype = @"datatype";
NSString * const AWdotted = @"dotted";
NSString * const AWerror = @"error";
NSString * const AWfield = @"field";
NSString * const AWfunction = @"function";
NSString * const AWincompletepattern = @"incompletepattern";
NSString * const AWinductiveconstructor = @"inductiveconstructor";
NSString * const AWkeyword = @"keyword";
NSString * const AWmodule = @"module";
NSString * const AWnumber = @"number";
NSString * const AWpostulate = @"postulate";
NSString * const AWprimitive = @"primitive";
NSString * const AWprimitivetype = @"primitivetype";
NSString * const AWmacro = @"macro";
NSString * const AWrecord = @"record";
NSString * const AWstring = @"string";
NSString * const AWsymbol = @"symbol";
NSString * const AWterminationproblem = @"terminationproblem";
NSString * const AWtypechecks = @"typechecks";
NSString * const AWunsolvedconstraint = @"unsolvedconstraint";
NSString * const AWunsolvedmeta = @"unsolvedmeta";
NSString * const AWcomment = @"comment";

NSString * const AWdatatypeOperator = @"datatype operator";
NSString * const AWfunctionOperator = @"function operator";
NSString * const AWinductiveconstructorOperator = @"inductiveconstructor operator";

@implementation AWColors

+ (CGColorRef) defaultBackgroundColor
{
    return CGColorCreateGenericRGB(239.0/255.0, 239.0/255.0, 239.0/255.0, 1);
}

+ (CGColorRef) defaultSeparatorColor
{
    return CGColorCreateGenericRGB(176.0/255.0, 176.0/255.0, 176.0/255.0, 1);
}

+ (NSColor *) unselectedTokenColor
{
    return [NSColor colorWithCalibratedRed:0/COLOR_MAX_VALUE green:64.0/COLOR_MAX_VALUE blue:153.0/COLOR_MAX_VALUE alpha:1.0];
}

+ (NSColor *) borderTokenColor
{
    return [NSColor colorWithCalibratedRed:110.f/255.f green:116.f/255.f blue:114.f/255.f alpha:1.f];
}

+ (NSColor *) highlightColorForType:(NSString *)type
{
    
    NSColor * color;
    
    if ([type isEqualToString:AWcomment]) {
        color = darkRedColor;
    }
    else if ([type isEqualToString:AWbound]) {
        color = darkGreyColor;
    }
    else if ([type isEqualToString:AWcoinductiveconstructor]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWdatatype]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWdatatypeOperator]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWdotted]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWerror]) {
        color = errorColor;
    }
    else if ([type isEqualToString:AWfield]) {
        color = pinkColor;
    }
    else if ([type isEqualToString:AWfunction]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWfunctionOperator]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWincompletepattern]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWinductiveconstructor]) {
        color = greenColor;
    }
    else if ([type isEqualToString:AWinductiveconstructorOperator]) {
        color = greenColor;
    }
    else if ([type isEqualToString:AWkeyword]) {
        color = orangeColor;
    }
    else if ([type isEqualToString:AWmacro]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWmodule]) {
        color = purpleColor;
    }
    else if ([type isEqualToString:AWnumber]) {
        color = purpleColor;
    }
    else if ([type isEqualToString:AWpostulate]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWprimitive]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWprimitivetype]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWrecord]) {
        color = blueColor;
    }
    else if ([type isEqualToString:AWstring]) {
        color = darkRedColor;
    }
    else if ([type isEqualToString:AWsymbol]) {
        color = [NSColor darkGrayColor];
    }
    else if ([type isEqualToString:AWterminationproblem]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWtypechecks]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWunsolvedconstraint]) {
        color = defaultColor;
    }
    else if ([type isEqualToString:AWunsolvedmeta]) {
        color = darkGreyColor;
    }
    else {
        color = defaultColor;
    }
    
    return color;
}

@end
