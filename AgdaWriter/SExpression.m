//
//  SExpression.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "SExpression.h"

@implementation SExpression

- (id) initWithValue:(NSString *) value
{
    self = [super init];
    if (self) {
        self.value = value;
    }
    return self;
}

- (void) insertLeft: (SExpression *)left
{
    self.left = left;
}

- (void) insertRight: (SExpression *) right
{
    self.right = right;
}
@end
