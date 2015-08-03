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
#import "AWHelper.h"


@implementation AWAgdaActions

#pragma mark -
#pragma mark Agda requests
#pragma mark -

+(NSString *)actionLoadWithFilePath:(NSString *)filePath
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_load \"%@\" [\".\", \"%@\"])",filePath, filePath, [AWHelper pathToLibraries]];
}
+(NSString *)actionCompileWithFilePath:(NSString *)filePath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_compile MAlonzo \"%@\" [\".\", \"%@\"])",filePath, filePath, [AWHelper pathToLibraries]];
}
+(NSString *)actionGiveWithFilePath:(NSString *)filePath goal:(AgdaGoal *)goal
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_give %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}
+(NSString *)actionRefineWithFilePath:(NSString *)filePath goal:(AgdaGoal *)goal
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_refine_or_intro False %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}
+(NSString *)actionAutoWithFilePath:(NSString *)filePath goal:(AgdaGoal *)goal
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_auto %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}
+(NSString *)actionCaseWithFilePath:(NSString *)filePath goal:(AgdaGoal *)goal
{
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_make_case %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}


+(NSString *)actionGoalTypeWithFilePath:(NSString *)filePath
                                   goal:(AgdaGoal *)goal
                     normalisationLevel:(AWNormalisationLevel)level {
    // Goal specific
    NSString * normalisation = [self normalisationLevel:level];
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_goal_type %@ %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, normalisation, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
    
}

+(NSString *)actionGoalTypeAndContextWithFilePath:(NSString *)filePath
                                             goal:(AgdaGoal *)goal
                               normalisationLevel:(AWNormalisationLevel)level {
    // Goal specific
    NSString * normalisation = [self normalisationLevel:level];
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_goal_type_context %@ %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, normalisation, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}
+(NSString *)actionGoalTypeAndInfferedContextWithFilePath:(NSString *)filePath
                                                     goal:(AgdaGoal *)goal
                                       normalisationLevel:(AWNormalisationLevel)level {
    NSString * normalisation = [self normalisationLevel:level];
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_goal_type_context_infer %@ %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, normalisation, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}

+(NSString *)actionShowConstraintsWithFilePath:(NSString *)filePath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect Cmd_constraints", filePath];
}

+(NSString *)actionShowMetasWithFilePath:(NSString *)filePath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect Cmd_metas", filePath];
}

+(NSString *)actionShowModuleContentsFilePath:(NSString *)filePath
                                         goal:(AgdaGoal *)goal
                           normalisationLevel:(AWNormalisationLevel)level
                                      content:(NSString *)content {
    NSString * normalisation = [self normalisationLevel:level];
    if (goal) {
        
        return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_show_module_contents %@ %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, normalisation, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, content];
    }
    else {
        return [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect ( Cmd_show_module_contents_toplevel %@ \"%@\" )", filePath, normalisation, content];
    }
    
    
}
+(NSString *)actionImplicitArgumentsWithFilePath:(NSString *)filePath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (ShowImplicitArgs True)", filePath];
}

+(NSString *)actionInferWithFilePath:(NSString *)filePath
                                goal:(AgdaGoal *)goal
                  normalisationLevel:(AWNormalisationLevel)level
                             content:(NSString *)content {
    NSString * normalisation = [self normalisationLevel:level];
    if (goal) {
        return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_infer %@ %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, normalisation, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, content];
    }
    else {
        return [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect (Cmd_infer_toplevel %@ \"%@\")", filePath, normalisation, content];
    }
}
+(NSString *)actionComputeNormalFormWithFilePath:(NSString *)filePath
                                            goal:(AgdaGoal *)goal
                                         content:(NSString *)content {
    
    if (goal) {
        return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_compute False %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, content];
    }
    else {
        return [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect (Cmd_compute_toplevel False \"%@\")", filePath, content];
    }

}
+(NSString *)actionToggleImplicitArgumentsWithFilePath:(NSString *)filePath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect ToggleImplicitArgs", filePath];
}
+(NSString *)actionSolveAllConstraints:(NSString *)filePath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_solveAll)", filePath];
}
+(NSString *)actionWhyInScopeWithFilePath:(NSString *)filePath
                                     goal:(AgdaGoal *)goal
                                  content:(NSString *)content {
    if (goal) {
        return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_why_in_scope %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, content];
    }
    else {
        return [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect (Cmd_why_in_scope_toplevel \"%@\")", filePath, content];
    }
}
+(NSString *)actionContextWithFilePath:(NSString *)filePath
                                  goal:(AgdaGoal *)goal
                    normalisationLevel:(AWNormalisationLevel)level {
    NSString * normalisationLevel = [self normalisationLevel:level];
    return [NSString stringWithFormat:@"IOTCM \"%@\" NonInteractive Indirect (Cmd_context %@ %li (Range [Interval (Pn (Just (mkAbsolute  \"%@\")) %li %li %li)(Pn (Just (mkAbsolute \"%@\")) %li %li %li)]) \"%@\" )", filePath, normalisationLevel, goal.agdaGoalIndex, filePath, goal.startCharIndex, goal.startRow, goal.startColumn, filePath, goal.endCharIndex, goal.endRow, goal.endColumn, goal.content];
}
+(NSString *)actionShowVersionWithFilePath:(NSString *)filepath {
    return [NSString stringWithFormat:@"IOTCM \"%@\" None Indirect ( Cmd_show_version )", filepath];
}



#pragma mark -
#pragma mark Agda Actions
#pragma mark -

// https://github.com/banacorn/agda-mode/wiki/List-of-interactions

+(void)executeAction:(NSDictionary *)action sender:(id)sender
{
    for (NSString * key in [action allKeys]) {
        NSArray * actions = [action objectForKey:key];
        
        if ([key isEqualToString:@"agda2-info-action"])
        {
            NSDate * date1 = [NSDate date];
            [self executeInfoAction:actions sender:sender];
            NSLog(@"info action: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-highlight-clear"])
        {
            NSDate * date1 = [NSDate date];
            [self executeHighlightClearAction:actions sender:sender];
            NSLog(@"clear highlighting: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-highlight-load-and-delete-action"])
        {
            NSDate * date1 = [NSDate date];
            [self executeHighlightLoadAndDeleteAction:actions sender:sender];
            NSLog(@"highlighting: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-status-action"])
        {
            NSDate * date1 = [NSDate date];
            [self executeStatusAction:actions];
            NSLog(@"status: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-goals-action"])
        {
            NSDate * date1 = [NSDate date];
            [self executeGoalsAction:actions];
            NSLog(@"goals action: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-give-action"])
        {
            NSDate * date1 = [NSDate date];
            [self executeGiveAction:actions sender:sender];
            NSLog(@"give action: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-make-case-action"])
        {
            NSDate * date1 = [NSDate date];
            [self executeMakeCaseAction:actions sender:sender];
            NSLog(@"make case: %f", [[NSDate date] timeIntervalSinceDate:date1]);
        }
        else if ([key isEqualToString:@"agda2-goto"])
        {
            [self executeGotoAction:actions sender:sender];
        }
        else if ([key isEqualToString:@"agda2-solveAll-action"])
        {
            
        }
        else {
            // TODO: Delete before releasing
            NSLog(@"KEY NOT FOUND: %@", key);
            [NSException raise:@"Key not found!" format:@"Implement key: %@", key];
        }


    }
}

+(NSString *)normalisationLevel:(AWNormalisationLevel)level {
    switch (level) {
        case AWNormalisationLevelInstantiated:
            return @"Instantiated";
        case AWNormalisationLevelNormalised:
            return @"Normalised";
        case AWNormalisationLevelSimplified:
            return @"Simplified";
        default:
            break;
    }
    return nil;
}

+(void)executeArrayOfActions:(NSArray *)actions sender:(id)sender
{
    for (NSDictionary * action in actions) {
        [self executeAction:action sender:sender];
    }
}
#pragma mark -
+(void)executeInfoAction:(NSArray *)actions sender:(id)sender
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
    
    BOOL shouldSendNotification = YES;
    NSColor * actionNameColor = [NSColor blueColor];
    
    if (actions.count > 2) {
        if ([actions[0] isEqualToString:@"\"*Agda Version*\""]) {
            [AWNotifications notifyAgdaVersion:actions[1]];
            
        }
        else if ([actions[0] isEqualToString:@"\"*All Goals*\""]) {
            [AWNotifications notifyAllGoals:actions[1] sender:sender];
            shouldSendNotification = NO;
        }
        else if ([actions[0] isEqualToString:@"\"*Type-checking*\""]) {
            if ([actions[1] hasPrefix:@"\"Finished"]) {
                // Checking succesfull
                AWToastWindow * toastWindow = [[AWToastWindow alloc] initWithToastType:ToastTypeLoadSuccessful];
                [toastWindow show];
            }
        }
        else if ([actions[0] isEqualToString:@"\"*Error*\""])
        {
            // In case of an error, show load failed.
            AWToastWindow * toastWindow = [[AWToastWindow alloc] initWithToastType:ToastTypeFailed];
            [toastWindow show];
            actionNameColor = [NSColor redColor];
        }
        else if ([actions[0] isEqualToString:@"\"*Current Goal*\""])
        {
            // Current goal
        }
        else if ([actions[0] isEqualToString:@"\"*Constraints*\""])
        {
            //TODO: implement
        }
        else if ([actions[0] isEqualToString:@"\"*Goal type etc.*\""])
        {
            //TODO: implement*Context*
        }
        else if ([actions[0] isEqualToString:@"\"*Context*\""])
        {

        }
        else
        {
            NSLog(@"INFO ACTION NOT FOUND! : %@", actions[0]);
//            [NSException raise:@"Info action not found!" format:@"Not found: %@", actions[0]];
        }
        
        if (shouldSendNotification) {
            NSMutableAttributedString * actionName = [[NSMutableAttributedString alloc] initWithString:actions[0] attributes:@{NSForegroundColorAttributeName : actionNameColor,
                NSFontAttributeName : [AWHelper defaultFontInAgda]}];
            NSString * string = [NSString stringWithFormat:@"\n%@", actions[1]];
            [actionName appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
            [AWNotifications notifyAgdaBufferDataAvaliable:actionName sender:sender];
        }
        
        
        
    }
}

+(void)executeMakeCaseAction:(NSArray *)actions sender:(id)sender
{
    if (actions.count > 0) {
        [AWNotifications notifyMakeCaseAction:actions[0] sender:sender];
    }
    
}

+(void)executeHighlightClearAction:(NSArray *)actions sender:(id)sender
{
    [AWNotifications notifyClearHighlightingWithSender:sender];
}
+(void)executeHighlightLoadAndDeleteAction:(NSArray *)actions sender:(id)sender
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
        [AWNotifications notifyHighlightCode:actions sender:sender];
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&errorDeleting];
    if (errorDeleting) {
        NSLog(@"Error deleting file at %@ \nReason: %@", filePath, errorDeleting.description);
    }
}



+(void)executeStatusAction:(NSArray *)actions
{
    
}

+(void)executeGotoAction:(NSArray *)actions sender:(id)sender {
    if (actions.count == 1) {
        NSInteger index = [AWAgdaParser parseGotoAction:actions[0]];
        [AWNotifications notifyAgdaGotoIndex:index sender:sender];
        
    }
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
+(void)executeGiveAction:(NSArray *)actions sender:(id)sender
{
    /*
     
     "Update the goal OLD-G with the expression in it."
     
     */
    if (actions.count > 1) {
        [AWNotifications notifyAgdaGaveAction:[actions[0] integerValue] content:actions[1] sender:sender];
    }
}


@end
