//
//  SExpressionParser.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SExpression.h"

@interface SExpressionParser : NSObject

- (NSString *) expand: (NSString *) input;
- (SExpression *) treeWithExpandedSExpression: (NSString *)input tree: (SExpression *)inputTree;

@end
