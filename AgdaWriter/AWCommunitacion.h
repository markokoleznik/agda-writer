//
//  AWCommunitacion.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AWCommunitacion : NSObject {
    
    NSPipe * inputPipe;
    NSPipe * outputPipe;
    
    NSFileHandle * fileReading;
    NSFileHandle * fileWriting;
    
    NSTask * task;
    
}

- (id) init;

- (void) writeData: (NSString * ) message;

-(void) searchForAgda;

@end
