//
//  AWAgdaParser.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 4. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AWAgdaParser : NSObject

-(void) parseResponse:(NSString *)response;
+(NSDictionary *)parseAction:(NSString *) action;
+(NSArray *)makeArrayOfActions:(NSString *)reply;
+(NSArray *)makeArrayOfGoalsWithSuggestions:(NSString *)goals;
+(NSArray *)makeArrayOfActionsAndDeleteActionFromString:(NSMutableString *)reply;
+(NSDictionary *)goalIndexAndRange:(NSRange)currentSelection textStorage:(NSTextStorage *)textStorage;
+(NSRange) goalAtIndex: (NSInteger) index textStorage:(NSTextStorage *)textStorage;
+(NSArray *) allGoalsWithRanges:(NSTextStorage *) textStorage;
@end
