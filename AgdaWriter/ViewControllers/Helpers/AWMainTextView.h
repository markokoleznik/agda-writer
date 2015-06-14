//
//  AWMainTextView.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 29. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//goalIndex: index of the goal
//startCharIndex: character index of the starting position
//startRow: row of the starting position
//startColumn: column of the starting position
//endCharIndex: character index of the ending position
//endRow: row of the ending position
//endColumn: column of the ending position
//content: contents you wanna give


@interface AgdaGoal : NSObject

@property NSInteger goalIndex;
@property NSInteger startCharIndex;
@property NSInteger startRow;
@property NSInteger startColumn;
@property NSInteger endCharIndex;
@property NSInteger endRow;
@property NSInteger endColumn;
@property NSInteger numberOfEmptySpaces;
@property NSRange rangeOfCurrentLine;
@property NSString * content;

@end



@interface AWMainTextView : NSTextView <NSTextViewDelegate, NSApplicationDelegate> {
    BOOL initialize;
    NSDictionary * defaultAttributes;
    NSDictionary * goalsAttributes;
    NSMutableAttributedString * mutableAttributedString;
    NSMutableArray * goalsArray;
    
}

@property (nonatomic) AgdaGoal * selectedGoal;
@property (nonatomic) AgdaGoal * lastSelectedGoal;

- (IBAction)save:(id)sender;



@end
