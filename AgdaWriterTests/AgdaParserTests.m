//
//  AgdaParserTests.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 20. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AWAgdaParser.h"

@interface AgdaParserTests : XCTestCase

@end

@implementation AgdaParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark-
#pragma mark Responses

- (void) testAgdaResponses1 {
    NSString * agdaResponse = @"(agda2-status-action \"\")";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-status-action" : @[@"\"\""]};
    
    // Check for equal keys
    if ([parsedObj isEqualToDictionary:expectedObj]) {
        XCTAssertTrue(@"Test Passed");
    }
    else {
        XCTAssertFalse(@"Dictionaries are not equal!");
    }
}
- (void) testAgdaResponses2 {
//    NSString * agdaResponse = @"(agda2-info-action \"*Type-checking*\" \"\" nil)";
//    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
//    NSDictionary * expectedObj = @{@"agda2-status-action" : @[@"\"\""]};
//    
//    // Check for equal keys
//    if ([parsedObj isEqualToDictionary:expectedObj]) {
//        XCTAssertTrue(@"Test Passed");
//    }
//    else
//    {
//        XCTAssertFalse(@"Dictionaries are not equal!");
//    }
}

@end
