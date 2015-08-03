//
//  AWCommunitacion.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface AWCommunitacion : NSObject {
    
    NSPipe * inputPipe;
    NSPipe * outputPipe;
    
    NSFileHandle * fileReading;
    NSFileHandle * fileWriting;
    
    NSTask * task;
    
    dispatch_queue_t agdaQueue;
    
    NSMutableString * partialAgdaResponse;

}

@property BOOL searchingForAgda;
@property int numberOfNotificationHits;
@property BOOL hasOpenConnectionToAgda;

@property NSViewController * activeViewController;


#pragma mark Init methods
- (id) init;
- (id) initForCommunicatingWithAgda;

#pragma mark Communication methods
- (void) writeData: (NSString * ) message;
- (void) writeDataToAgda:(NSString *) message sender:(NSViewController *)sender;
- (void) searchForAgda;
- (BOOL) isAgdaAvaliableAtPath:(NSString *)path;
- (void) openConnectionToAgda;
- (void) closeConnectionToAgda;
- (void) quitAndRestartConnectionToAgda;


@end
