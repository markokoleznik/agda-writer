//
//  AWAgdaActions.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 20. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWMainTextView.h"
@interface AWAgdaActions : NSObject


//********* Requests *********
#pragma mark -
#pragma mark Agda requests

// List of Interaction, thanks to banacorn!
// https://github.com/banacorn/agda-mode/wiki/Conversations-between-Agda-&-agda-mode

// TODO:
/*
 compile
 show constraints
 show metas
 show module contents (global)
 show module contents (goal-specific)
 search (?)
 solve all constraints
 infer (global)
 infer (goal-specific)
 compute normal form (global)
 compute normal form (goal-specific)
 load highlighting info
 highlight
 show implicit arguments
 toggle implicit arguments
 context
 helper function (huh ?)
 goal type
 goal type & context
 goal type & context infer
 why in scope (global)
 why in scope (goal-specific)

 
 */

// Load
+(NSString *)actionLoadWithFilePath:(NSString *)filePath;
// Give
+(NSString *)actionGiveWithFilePath:(NSString *)filePath
                               goal:(AgdaGoal *)goal;
// Refine
+(NSString *)actionRefineWithFilePath:(NSString *)filePath
                                 goal:(AgdaGoal *)goal;
// Auto
+(NSString *)actionAutoWithFilePath:(NSString *)filePath
                               goal:(AgdaGoal *)goal;
// Case
+(NSString *)actionCaseWithFilePath:(NSString *)filePath
                               goal:(AgdaGoal *)goal;
// Goal type
+(NSString *)actionGoalTypeWithFilePath:(NSString *)filePath
                              goalIndex:(NSInteger)goalIndex;
// Context
+(NSString *)actionContextWithFilePath:(NSString *)filePath
                             goalIndex:(NSInteger)goalIndex;
// Goal type and context
+(NSString *)actionGoalTypeAndContextWithFilePath:(NSString *)filePath
                                        goalIndex:(NSInteger)goalIndex;
// Goal type and inferred type
+(NSString *)actionGoalTypeAndInferredTypeWithFilePath:(NSString *)filePath
                                             goalIndex:(NSInteger)goalIndex
                                               content:(NSString *)content;
// Version of Agda
+(NSString *)actionShowVersionOfAgdaWithFilePath:(NSString *)filePath;

// Normalize with goal
+(NSString *)actionNormalizeWithGoal:(AgdaGoal *)goal
                            filePath:(NSString *)filePath
                             content:(NSString *)content;


#pragma mark -
#pragma mark Agda Actions
+(void)executeAction:(NSDictionary *)action sender:(id) sender;
+(void)executeArrayOfActions:(NSArray *)actions sender:(id) sender;
@end
