//
//  Agda_Writer_Parser_Tests.m
//  Agda Writer Parser Tests
//
//  Created by Marko Koležnik on 18. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AWAgdaParser.h"

@interface Agda_Writer_Parser_Tests : XCTestCase
@property NSString * testPassedDescription;
@property NSString * testFailedDescription;
@property NSString * dictionariesNotEqualDescription;
@end

@implementation Agda_Writer_Parser_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.testPassedDescription = @"Test passed.";
    self.testFailedDescription = @"Test failed. Reason: ";
    self.dictionariesNotEqualDescription = @"Dictionaries are not equal!";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark-
#pragma mark Responses

- (void) testAgdaResponse1 {
    NSString * agdaResponse = @"(agda2-status-action \"\")";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-status-action" : @[@"\"\""]};
    
    // Check for equal dictionaries (have dictionaries same keys and corresponding values?
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse2 {
    NSString * agdaResponse = @"(agda2-info-action \"*Type-checking*\" \"\" nil)";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-info-action" : @[@"\"*Type-checking*\"", @"\"\"", @"nil"]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse3 {
    NSString * agdaResponse = @"(agda2-info-action \"*Type-checking*\" \"Finished Foo.\n\" t)";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-info-action" : @[@"\"*Type-checking*\"", @"\"Finished Foo.\n\"", @"t"]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse4 {
    NSString * agdaResponse = @"(agda2-status-action \"\")";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-status-action" : @[@"\"\""]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse5 {
    NSString * agdaResponse = @"(agda2-info-action \"*All Goals*\" \"?0 : bool\n?1 : bool\n\" nil)";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-info-action" : @[@"\"*All Goals*\"", @"\"?0 : bool\n?1 : bool\n\"", @"nil"]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse6 {
    NSString * agdaResponse = @"((last . 1) . (agda2-goals-action '(0 1)))";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-goals-action" : @[@"'(0 1)"]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse7 {
    NSString * agdaResponse = @"(agda2-highlight-clear)";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-highlight-clear" : @[]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse8 {
    NSString * agdaResponse = @"(agda2-info-action \"*Type-checking*\" \"Checking Foo (/Users/markokoleznik/Documents/os_x_development/agda-writer/foo.agda).\n\" t)";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-info-action" : @[@"\"*Type-checking*\"", @"\"Checking Foo (/Users/markokoleznik/Documents/os_x_development/agda-writer/foo.agda).\n\"", @"t"]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse9 {
    NSString * agdaResponse = @"(agda2-info-action \"*Agda Version*\" \"Agda version 2.4.2.2\" nil)";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-info-action" : @[@"\"*Agda Version*\"", @"\"Agda version 2.4.2.2\"", @"nil"]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}
- (void) testAgdaResponse10 {
    NSString * agdaResponse = @"(agda2-give-action 0 \"x\")";
    NSDictionary * parsedObj = [AWAgdaParser parseAction:agdaResponse];
    NSDictionary * expectedObj = @{@"agda2-give-action" : @[@"0", @"\"x\""]};
    
    [parsedObj isEqualToDictionary:expectedObj] ? XCTAssertTrue(self.testPassedDescription) : XCTAssertFalse([self.testFailedDescription stringByAppendingString:self.dictionariesNotEqualDescription]);
}

@end
