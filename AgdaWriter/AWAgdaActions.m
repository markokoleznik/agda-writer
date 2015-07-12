//
//  AWAgdaActions.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 20. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWAgdaActions.h"
#import "AWNotifications.h"
#import "AWToastWindow.h"
#import "AWAgdaParser.h"


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
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_goal_type Simplified %li noRange \"\" )", filePath, goalIndex];
}
+(NSString *)actionContextWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_context Simplified %li noRange \"\" )", filePath, goalIndex];
}
+(NSString *)actionGoalTypeAndContextWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_goal_type_context Simplified %li noRange \"\" )", filePath, goalIndex];
}
+(NSString *)actionGoalTypeAndInferredTypeWithFilePath:(NSString *)filePath goalIndex:(NSInteger)goalIndex content:(NSString *)content
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ( Cmd_goal_type_context_infer Simplified %li noRange \"%@\" )", filePath, goalIndex, content];
}
+(NSString *)actionShowVersionOfAgdaWithFilePath:(NSString *)filePath
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect ( Cmd_show_version )", filePath];
}


#pragma mark -
#pragma mark Agda Actions
#pragma mark -

// https://github.com/banacorn/agda-mode/wiki/List-of-interactions

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
        else if ([key isEqualToString:@"agda2-give-action"])
        {
            [self executeGiveAction:actions];
        }
        else if ([key isEqualToString:@"agda2-make-case-action"])
        {
            [self executeMakeCaseAction:actions];
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
    /*
     "Insert TEXT into the Agda info buffer and display it.
     NAME is displayed in the buffer's mode line.
     If APPEND is non-nil, then TEXT is appended at the end of the
     buffer, and point placed after this text.
     If APPEND is nil, then any previous text is removed before TEXT
     is inserted, and point is placed before this text."
     
     (agda2-info-action "*Type-checking*" "Finished Foo.\n" t)
     
    */
    if (actions.count > 2) {
        if ([actions[0] isEqualToString:@"\"*Agda Version*\""]) {
            [AWNotifications notifyAgdaVersion:actions[1]];
            
        }
        else if ([actions[0] isEqualToString:@"\"*All Goals*\""]) {
            [AWNotifications notifyAllGoals:actions[1]];
        }
        else if ([actions[0] isEqualToString:@"\"*Type-checking*\""]) {
            if ([actions[1] hasPrefix:@"\"Finished"]) {
                // Checking succesfull
                AWToastWindow * toastWindow = [[AWToastWindow alloc] initWithToastType:ToastTypeLoadSuccessful];
                [toastWindow show];
            }
            
            [AWNotifications notifyAgdaBufferDataAvaliable:actions[1]];
        }
        else if ([actions[0] isEqualToString:@"\"*Error*\""])
        {
            // In case of an error, show load failed.
            AWToastWindow * toastWindow = [[AWToastWindow alloc] initWithToastType:ToastTypeLoadFailed];
            [toastWindow show];
        }
        else if ([actions[0] isEqualToString:@"\"*Current Goal*\""])
        {
            // Current goal
        }
        else
        {
            
        }
        NSString * bufferDescription = actions[1];
        [AWNotifications notifyAgdaBufferDataAvaliable:bufferDescription];
    }
}

+(void)executeMakeCaseAction:(NSArray *)actions
{
    if (actions.count > 0) {
        [AWNotifications notifyMakeCaseAction:actions[0]];
    }
    
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
    
    // NOTE: no highlighting yet, just delete the file
    
    NSError * errorDeleting;
    NSError * errorReading;
    
    NSString * filePath = [actions objectAtIndex:0];
    filePath = [filePath substringWithRange:NSMakeRange(1, filePath.length - 2)];
    NSString * fileContents = [NSString stringWithContentsOfFile:filePath
                              encoding:NSUTF8StringEncoding error:&errorReading];
    if (errorReading) {
        NSLog(@"Error reading file");
    }
    else
    {
        NSArray * actions = [AWAgdaParser parseHighlighting:fileContents];
        [AWNotifications notifyHighlightCode:actions];
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&errorDeleting];
    if (errorDeleting) {
        NSLog(@"Error deleting file at %@ \nReason: %@", filePath, errorDeleting.description);
    }
}



+(void)executeStatusAction:(NSArray *)actions
{
    
}
+(void)executeGoalsAction:(NSArray *)actions
{
    /*
     
     "Annotates the goals in the current buffer with text properties.
     GOALS is a list of the buffer's goal numbers, in the order in
     which they appear in the buffer. Note that this function should
     be run /after/ syntax highlighting information has been loaded,
     because the two highlighting mechanisms interact in unfortunate
     ways."
     
     
    */
    if (actions.count > 0) {
        
    }
}
+(void)executeGiveAction:(NSArray *)actions
{
    /*
     
     "Update the goal OLD-G with the expression in it."
     
     */
    if (actions.count > 1) {
        [AWNotifications notifyAgdaGaveAction:[actions[0] integerValue] content:actions[1]];
    }
}


@end
