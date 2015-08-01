//
//  AWAgdaGoal.h
//  Agda Writer
//
//  Created by Marko Koležnik on 1. 08. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AWAgdaGoalTypeNormalGoal,
    AWAgdaGoalTypeMetaGoal
} AWAgdaGoalType;

@interface AWAgdaGoal : NSObject

@property NSString * goalDescription;
@property NSString * goalIndex;
@property AWAgdaGoalType goalType;

@end
