//
//  UnicodeTransformator.h
//  Agda Writer
//
//  Created by Marko Koležnik on 24. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnicodeTransformator : NSObject

+ (NSString *)transformToUnicode:(NSString *)input;

@end
