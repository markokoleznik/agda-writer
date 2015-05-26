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
                                                     name:NSFileHandleReadToEndOfFileCompletionNotification
                                                   object:nil];
        
        self.searchingForAgda = NO;
        self.numberOfNotificationHits = 0;
        
    }
    return self;
}

-(id) initForCommunicatingWithAgda
{
    self = [super init];
    if (self) {
        
        // Create new thread
        agdaQueue = dispatch_queue_create("net.koleznik.agdaQueue", NULL);
        
        // Initialize mutable string
        partialAgdaResponse = [[NSMutableString alloc] init];
        
        self.hasOpenConnectionToAgda = NO;
    }
    return self;
}

- (BOOL) isAgdaAvaliableAtPath:(NSString *)path
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    task = [NSTask new];
    task.launchPath = path;
    task.arguments = @[@"--interaction"];
    task.standardInput = outputPipe;
    task.standardOutput = inputPipe;
    
    // Potentialy unsafe code. Wrap it around try/catch block
    @try {
        [task launch];
        // NSTask didn't throw exception. Return YES;
        return YES;
    }
    @catch (NSException *exception) {
        // Exception was thrown. Return NO;
        NSLog(@"Failed to load Agda. Reason: %@", exception.reason);
        return NO;
    }
    @finally {
        // Pass.
    }
    
}


- (void) dataAvailabe:(NSNotification *) notification {
    
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString * reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (self.searchingForAgda) {
        self.numberOfNotificationHits += 1;
    }
    
    if (self.searchingForAgda && self.numberOfNotificationHits >= 2) {
        [AWNotifications notifyPossibleAgdaPathFound:reply];
    }
    else {
        NSArray * actions = [AWAgdaParser makeArrayOfActions:reply];
        [AWNotifications notifyExecuteActions:actions];
        [AWNotifications notifyAgdaReplied:reply];
    }
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
    NSLog(@"launch path: %@", task.launchPath);
    task.arguments = @[@"--interaction"];
    task.standardInput = outputPipe;
    task.standardOutput = inputPipe;
    BOOL exists = [[NSFileManager defaultManager] isExecutableFileAtPath:[task launchPath]];
    if (exists) {
        @try {
            [task launch];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception.reason);
            NSAlert * alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Open Prefreneces..."];
            [alert setMessageText:@"Task can't be launched!\nCheck your path in Settings."];
            [alert setAlertStyle:NSWarningAlertStyle];
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                NSLog(@"Open preferences");
                [AWNotifications notifyOpenPreferences];
            }
        }
        @finally {

        }
        
    }
    else
    {
        // File can't be lauched!
        NSLog(@"File can't be launched!\nLaunch path not accessible.");
        NSAlert * alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Open Prefreneces..."];
        [alert setMessageText:@"Task can't be launched!\nCheck your path in Settings."];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSLog(@"Open preferences");
            [AWNotifications notifyOpenPreferences];
        }
    }
    
}

-(void) searchForAgda
{
    [self openPipes];
    task = [NSTask new];
    // PATH TO AGDA
    task.launchPath = @"/usr/bin/find";
    NSLog(@"launch path: %@", task.launchPath);
    task.arguments = @[NSHomeDirectory(), @"-name", @"agda"];
    task.standardInput = outputPipe;
    task.standardOutput = inputPipe;
    
    @try {
        [task launch];
        self.searchingForAgda = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception.description);
    }
    @finally {
        
    }
    

    
}



- (void) openPipes
{
    inputPipe = [NSPipe pipe];
    outputPipe = [NSPipe pipe];
    
    fileReading = inputPipe.fileHandleForReading;
    [fileReading readToEndOfFileInBackgroundAndNotify];
    fileWriting = outputPipe.fileHandleForWriting;
}

- (void) closePipes
{
    
}

- (void) openConnectionToAgda
{
    // spawn task in a custom thread
    dispatch_queue_t taskQueue = dispatch_queue_create("net.koleznik.AgdaQueue", NULL);
    dispatch_async(taskQueue, ^{
        task = [[NSTask alloc] init];
        // set standard input, output and error. Error outputs will be in our outputs.
        [task setStandardOutput: [NSPipe pipe]];
        [task setStandardInput: [NSPipe pipe]];
        [task setStandardError: [task standardOutput]];
        
        [task setLaunchPath:[AWNotifications agdaLaunchPath]];
//        [task setLaunchPath:@"/Users/markokoleznik/Library/Haskell/bin/agda"];
        [task setArguments:@[@"--interaction"]];
        [[[task standardOutput] fileHandleForReading] waitForDataInBackgroundAndNotify];
        
        // Add observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAgdaResponse:) name:NSFileHandleDataAvailableNotification object:nil];
        
        // when everything is set, launch task

        @try {
            [task launch];
            self.hasOpenConnectionToAgda = YES;
            // Wait until exit; this would block the main thread, but we are on our own thread.
            [task waitUntilExit];
        }
        @catch (NSException *exception) {
            NSLog(@"Exeption launching the task, reason: %@", exception.reason);
            // Open prefrences
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSAlert * alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Open Prefreneces..."];
                [alert setMessageText:@"Task can't be launched!\nCheck your path in Settings."];
                [alert setAlertStyle:NSWarningAlertStyle];
                if ([alert runModal] == NSAlertFirstButtonReturn) {
                    NSLog(@"Open preferences");
                    [AWNotifications notifyOpenPreferences];
                }
            });
            
        }
        @finally {
            
        }

        

    
    });
    
}

- (void) handleAgdaResponse:(NSNotification *) notification
{
    NSData * avaliableData = [[[task standardOutput] fileHandleForReading] availableData];
    NSString * avaliableString = [[NSString alloc] initWithData:avaliableData encoding:NSUTF8StringEncoding];
    dispatch_sync(dispatch_get_main_queue(), ^{
        // Handle avaliable data on main thread
        NSLog(@"%@", avaliableString);
        // Append partial string and perform action if possible
        // if possible, cut this part of the string.
        if (avaliableString) {
            [partialAgdaResponse appendString:avaliableString];
            [AWNotifications notifyAgdaReplied:avaliableString];
            NSArray * actions = [AWAgdaParser makeArrayOfActionsAndDeleteActionFromString:partialAgdaResponse];
            [AWNotifications notifyExecuteActions:actions];
        }
        
        
        
    });
    // we need to register for notifications everytime notification is recieved
    [[[task standardOutput] fileHandleForReading] waitForDataInBackgroundAndNotify];
}


- (void) writeDataToAgda:(NSString *) message
{
    // Don't forget to append newline character at the end of message (if it has none)
    // \n aka newline reacts as hitting enter in terminal. It flushes all the writing buffer. No need for closing the pipes.
    // All messages to agda should end with '\n', since we are in interactive mode!
    
    if (![message hasSuffix:@"\n"]) {
        message = [message stringByAppendingString:@"\n"];
    }
    if (!self.hasOpenConnectionToAgda) {
        [self openConnectionToAgda];
    }
    // Add output to buffer!
    [AWNotifications notifyAgdaReplied:message];
    [[[task standardInput] fileHandleForWriting] writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeData: (NSString * ) message
{
    [self openPipes];
    [self startTask];
    [fileWriting writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [fileWriting closeFile];
}


#pragma mark -
-(void)dealloc
{
    // Remove self as observer and terminate task if it's still running
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([task isRunning]) {
        [task terminate];
    }
}



@end
