//
//  AWInputViewController.h
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"

@protocol AWInputDelegate <NSObject>
@required
-(void)normalizeInputDidEndEditing:(NSString *)content;

@optional
-(void)closeWindow;

@end

@interface AWInputViewController : NSViewController <NSTextFieldDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSTextField *inputTitle;
@property (weak) IBOutlet NSTextField *inputTextField;
@property (nonatomic) id <AWInputDelegate> delegate;

@end
