//
//  AWHighlighting.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 12. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AWHighlighting : NSObject

extern NSString * const keyword;
extern NSString * const symbol;
extern NSString * const datatypeOperator;
extern NSString * const primitivetype;
extern NSString * const function;
extern NSString * const inductiveConstructor;
extern NSString * const comment;
extern NSString * const module;
extern NSString * const datatype;
extern NSString * const functionOperator;
extern NSString * const inductiveconstructorOperator;
extern NSString * const bound;





+ (void) highlightCodeAtRange:(NSRange) range actionName: (NSString *) actionName textView: (NSTextView *)textView;

@end
