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

//********* Actions *********


// Load
+(NSString *)actionLoadWithFilePath:(NSString *)filePath
                      andIncludeDir:(NSString *)includeDir;
// Give
+(NSString *)actionGiveWithFilePath:(NSString *)filePath
                         goalIndex:(NSInteger)goalIndex
                    startCharIndex:(NSInteger)startCharIndex
                          startRow:(NSInteger)startRow
                       startColumn:(NSInteger)startColumn
                      endCharIndex:(NSInteger)endCharIndex
                            endRow:(NSInteger)endRow
                         endColumn:(NSInteger)endColumn
                           content:(NSString *)content;
// Refine
+(NSString *)actionRefineWithFilePath:(NSString *)filePath
                            goalIndex:(NSInteger)goalIndex
                       startCharIndex:(NSInteger)startCharIndex
                             startRow:(NSInteger)startRow
                          startColumn:(NSInteger)startColumn
                         endCharIndex:(NSInteger)endCharIndex
                               endRow:(NSInteger)endRow
                            endColumn:(NSInteger)endColumn
                              content:(NSString *)content;
// Auto
+(NSString *)actionAutoWithFilePath:(NSString *)filePath
                            goalIndex:(NSInteger)goalIndex
                       startCharIndex:(NSInteger)startCharIndex
                             startRow:(NSInteger)startRow
                          startColumn:(NSInteger)startColumn
                         endCharIndex:(NSInteger)endCharIndex
                               endRow:(NSInteger)endRow
                            endColumn:(NSInteger)endColumn
                              content:(NSString *)content;
// Case
+(NSString *)actionCaseWithFilePath:(NSString *)filePath
                          goalIndex:(NSInteger)goalIndex
                     startCharIndex:(NSInteger)startCharIndex
                           startRow:(NSInteger)startRow
                        startColumn:(NSInteger)startColumn
                       endCharIndex:(NSInteger)endCharIndex
                             endRow:(NSInteger)endRow
                          endColumn:(NSInteger)endColumn
                            content:(NSString *)content;
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
@end
