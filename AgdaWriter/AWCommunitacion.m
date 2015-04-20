//
//  AWCommunitacion.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWCommunitacion.h"
#import "AWNotifications.h"
#import "AWAgdaParser.h"

@implementation AWCommunitacion


-(id) init
{
    self = [super init];
    if (self) {
        
        [self openPipes];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataAvailabe:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:nil];
        [self startTask];

    }
    return self;
}


- (void) dataAvailabe:(NSNotification *) notification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [NSThread sleepForTimeInterval:0.1];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *data = [fileReading availableData];
            NSString * reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            reply = [reply stringByAppendingString:@"\n------\n"];
            
            NSArray * actions = [AWAgdaParser makeArrayOfActions:reply];
            [AWNotifications notifyExecuteActions:actions];
            [AWNotifications notifyAgdaReplied:reply];
        });
    });
}


- (void) stopTask
{
    [task terminate];
}

- (void) startTask
{
    task = [NSTask new];
    // PATH TO AGDA
    task.launchPath = [AWNotifications agdaLaunchPath];
    task.arguments = @[@"--interaction"];
    task.standardInput = outputPipe;
    task.standardOutput = inputPipe;
    [task launch];
}

- (void) openPipes
{
//    [[NSProcessInfo processInfo] processIdentifier];
    inputPipe = [NSPipe pipe];
    outputPipe = [NSPipe pipe];
    fileReading = inputPipe.fileHandleForReading;
    [fileReading waitForDataInBackgroundAndNotify];
    
    fileWriting = outputPipe.fileHandleForWriting;
}

- (void) closePipes
{
    
}

- (void) writeData: (NSString * ) message
{
//    [self stopTask];
    [self openPipes];
    [self startTask];
    [fileWriting writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [fileWriting closeFile];
}


#pragma mark -
#pragma mark Agda actions

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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






@end
