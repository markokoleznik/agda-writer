//
//  AWInputViewController.h
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"

typedef enum : NSUInteger {
    AWInputViewTypeShowModuleContents,
    AWInputViewTypeInfer,
    AWInputViewTypeComputeNormalForm
} AWInputViewType;

@protocol AWInputDelegate <NSObject>
@required
-(void)inputDidEndEditing:(NSString *)content withType:(AWInputViewType)type;

@optional
-(void)closeWindow;

@end

@interface AWInputViewController : NSViewController <NSTextFieldDelegate, NSWindowDelegate>

- (id)initWithInputType: (AWInputViewType)inputType global: (BOOL)isGlobal rect:(NSRect)rect;

@property (weak) IBOutlet NSTextField *inputTitle;
@property (weak) IBOutlet NSTextField *inputTextField;
@property (nonatomic) id <AWInputDelegate> delegate;

@property NSPoint point;

@end
