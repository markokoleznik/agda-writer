//
//  SExpression.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, Atom) {
    SE_STRING,
    SE_NIL,
    SE_NUMBER,
    SE_TRUE,
    SE_FALSE
};


@interface SExpression : NSObject
@property NSString * value;
@property SExpression * left;
@property SExpression * right;

- (id) initWithValue:(NSString *) value;

@end
