//
//  AWAgdaActions.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 20. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWAgdaActions.h"


@implementation AWAgdaActions

#pragma mark -
#pragma mark Agda requests
#pragma mark -

+(NSString *)actionLoadWithFilePath:(NSString *)filePath andIncludeDir:(NSString *)includeDir
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_load \"%@\" [\".\", \"%@\"])",filePath, filePath, includeDir];
}
+(NSString *)actionGiveWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex startCharIndex:(NSInteger)startCharIndex startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn endCharIndex:(NSInteger)endCharIndex endRow:(NSInteger)endRow endColumn:(NSInteger)endColumn content:(NSString *)content
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_give %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goalIndex, filePath, startCharIndex, startRow, startColumn, filePath, endCharIndex, endRow, endColumn, content];
}
+(NSString *)actionRefineWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex startCharIndex:(NSInteger)startCharIndex startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn endCharIndex:(NSInteger)endCharIndex endRow:(NSInteger)endRow endColumn:(NSInteger)endColumn content:(NSString *)content
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_refine_or_intro False %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goalIndex, filePath, startCharIndex, startRow, startColumn, filePath, endCharIndex, endRow, endColumn, content];
}
+(NSString *)actionAutoWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex startCharIndex:(NSInteger)startCharIndex startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn endCharIndex:(NSInteger)endCharIndex endRow:(NSInteger)endRow endColumn:(NSInteger)endColumn content:(NSString *)content
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_auto %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goalIndex, filePath, startCharIndex, startRow, startColumn, filePath, endCharIndex, endRow, endColumn, content];
}
+(NSString *)actionCaseWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex startCharIndex:(NSInteger)startCharIndex startRow:(NSInteger)startRow startColumn:(NSInteger)startColumn endCharIndex:(NSInteger)endCharIndex endRow:(NSInteger)endRow endColumn:(NSInteger)endColumn content:(NSString *)content
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_make_case %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goalIndex, filePath, startCharIndex, startRow, startColumn, filePath, endCharIndex, endRow, endColumn, content];
}
+(NSString *)actionGoalTypeWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_goal_type Simplified %li noRange "" )", filePath, goalIndex];
}
+(NSString *)actionContextWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_context Simplified %li noRange "" )", filePath, goalIndex];
}
+(NSString *)actionGoalTypeAndContextWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_goal_type_context Simplified %li noRange "" )", filePath, goalIndex];
}
+(NSString *)actionGoalTypeAndInferredTypeWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex content:(NSString *)content
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_goal_type_context_infer Simplified %li noRange \"%@\" )", filePath, goalIndex, content];
}


#pragma mark -
#pragma mark Agda Actions
#pragma mark -

+(void)executeAction:(NSDictionary *)action
{
    for (NSString * key in [action allKeys]) {
        NSArray * actions = [action objectForKey:key];
        
        if ([key isEqualToString:@"agda2-info-action"])
        {
            [self executeInfoAction:actions];
        }
        else if ([key isEqualToString:@"agda2-highlight-clear"])
        {
            [self executeHighlightClearAction:actions];
        }
        else if ([key isEqualToString:@"agda2-highlight-load-and-delete-action"])
        {
            [self executeHighlightLoadAndDeleteAction:actions];
        }
        else if ([key isEqualToString:@"agda2-status-action"])
        {
            [self executeStatusAction:actions];
        }
        else if ([key isEqualToString:@"agda2-goals-action"])
        {
            [self executeGoalsAction:actions];
        }


    }
}
+(void)executeArrayOfActions:(NSArray *)actions
{
    for (NSDictionary * action in actions) {
        [self executeAction:action];
    }
}
#pragma mark -
+(void)executeInfoAction:(NSArray *)actions
{
    
}
+(void)executeHighlightClearAction:(NSArray *)actions
{
    
}
+(void)executeHighlightLoadAndDeleteAction:(NSArray *)actions
{
    /*
     
     "Like `agda2-highlight-load', but deletes FILE when done.
     And highlighting is only updated if `agda2-highlight-in-progress'
     is non-nil."
     
     After higlighting those temp files should be deleted.
     
     @param: filepath to the file that needs to be deleted
     
     */
    
    // NOTE: no highlighting yes, just delete the file
    
    NSError * error;
    NSString * filePath = [actions objectAtIndex:0];
    filePath = [filePath substringWithRange:NSMakeRange(1, filePath.length - 2)];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"Error deleting file at %@ \nReason: %@", filePath, error.description);
    }
}
+(void)executeStatusAction:(NSArray *)actions
{
    
}
+(void)executeGoalsAction:(NSArray *)actions
{
    
}


@end
