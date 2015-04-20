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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






@end
