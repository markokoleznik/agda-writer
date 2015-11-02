//
//  AWAgdaActions.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 20. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWMainTextView.h"

typedef enum : NSUInteger {
    AWNormalisationLevelInstantiated,
    AWNormalisationLevelSimplified,
    AWNormalisationLevelNormalised,
    AWNormalisationLevelNone
} AWNormalisationLevel;



@interface AWAgdaActions : NSObject


//********* Requests *********
#pragma mark -
#pragma mark Agda requests

// List of Interaction, thanks to banacorn!
// https://github.com/banacorn/agda-mode/wiki/Conversations-between-Agda-&-agda-mode



// Load
+(NSString *)actionLoadWithFilePath:(NSString *)filePath;
// Compile
+(NSString *)actionCompileWithFilePath:(NSString *)filePath;
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

+(NSString *)actionGoalTypeWithFilePath:(NSString *)filePath
                                   goal:(AgdaGoal *)goal
                     normalisationLevel:(AWNormalisationLevel)level;

+(NSString *)actionGoalTypeAndContextWithFilePath:(NSString *)filePath
                                   goal:(AgdaGoal *)goal
                     normalisationLevel:(AWNormalisationLevel)level;

+(NSString *)actionGoalTypeAndInfferedContextWithFilePath:(NSString *)filePath
                                   goal:(AgdaGoal *)goal
                     normalisationLevel:(AWNormalisationLevel)level;

+(NSString *)actionShowConstraintsWithFilePath:(NSString *)filePath;

+(NSString *)actionShowMetasWithFilePath:(NSString *)filePath;

+(NSString *)actionShowModuleContentsFilePath:(NSString *)filePath
                                         goal:(AgdaGoal *)goal
                           normalisationLevel:(AWNormalisationLevel)level
                                      content:(NSString *)content;

+(NSString *)actionImplicitArgumentsWithFilePath:(NSString *)filePath;

+(NSString *)actionInferWithFilePath:(NSString *)filePath
                                goal:(AgdaGoal *)goal
                  normalisationLevel:(AWNormalisationLevel)level
                             content:(NSString *)content;

+(NSString *)actionComputeNormalFormWithFilePath:(NSString *)filePath
                                goal:(AgdaGoal *)goal
                             content:(NSString *)content;

+(NSString *)actionToggleImplicitArgumentsWithFilePath:(NSString *)filePath;

+(NSString *)actionSolveAllConstraints:(NSString *)filePath;

+(NSString *)actionWhyInScopeWithFilePath:(NSString *)filePath
                                     goal:(AgdaGoal *)goal
                                  content:(NSString *)content;

+(NSString *)actionContextWithFilePath:(NSString *)filePath
                                  goal:(AgdaGoal *)goal
                    normalisationLevel:(AWNormalisationLevel)level;

+(NSString *)actionShowVersionWithFilePath:(NSString *)filepath;


#pragma mark -
#pragma mark Agda Actions
+(void)executeAction:(NSDictionary *)action sender:(id) sender;
+(void)executeArrayOfActions:(NSArray *)actions sender:(id) sender;
@end
