//
//  AWAgdaParser.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 4. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "CustomTokenCell.h"

@interface AWAgdaParser : NSObject

-(void) parseResponse:(NSString *)response;
+(NSDictionary *)parseAction:(NSString *) action;
+(NSArray *)makeArrayOfActions:(NSString *)reply;
+(NSArray *)makeArrayOfGoalsWithSuggestions:(NSString *)goals;
+(NSArray *)makeArrayOfActionsAndDeleteActionFromString:(NSMutableString *)reply;
+(NSDictionary *)goalIndexAndRange:(NSRange)currentSelection textStorage:(NSTextStorage *)textStorage;
+(NSRange) goalAtIndex: (NSInteger) index textStorage:(NSTextStorage *)textStorage;
+(NSArray *) allGoalsWithRanges:(NSTextStorage *) textStorage;
+(NSArray *) caseSplitActions:(NSString *)reply;
/** Parses highlighting.
 @param  NSString               Response from Agda (read from disk)
 @return NSArray                Array contains objects of type NSDictionary. Form: @{type : @[range]}
 */
+(NSArray *) parseHighlighting:(NSString *)highlighting;
+ (NSRange) rangeFromLineNumber:(NSUInteger)lineNumber
                   andLineRange:(NSRange) lineRange
                         string:(NSString *)string;
+(NSInteger) parseGotoAction:(NSString *)reply;

+ (NSMutableAttributedString *) parseRangesAndAddAttachments:(NSAttributedString *)reply parentViewController:(id)parentViewController;
@end
