//
//  AWInputViewController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWInputViewController.h"
#import "UnicodeTransformator.h"

@interface AWInputViewController ()

@end

@class MAAttachedWindow;

@implementation AWInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:
     @"NSWindowDidResignKeyNotification" object:nil];
    
    self.inputTextField.delegate = self;
    // Do view setup here.
}

-(void)keyUp:(NSEvent *)theEvent
{
    [super keyUp:theEvent];
    if (theEvent.keyCode == 53) {
        // escape pressed, close window
        [self.delegate closeWindow];
    }
    else if (theEvent.keyCode == 49) {
        // space was pressed
        NSString * unicodeText = [UnicodeTransformator transformToUnicode:self.inputTextField.stringValue];
        if (![unicodeText isEqualToString:self.inputTextField.stringValue]) {
            self.inputTextField.stringValue = unicodeText;
        }
    }
}


-(NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    return @[];
}


-(void)windowDidResignKey:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[MAAttachedWindow class]]) {
        [self.delegate closeWindow];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    [self.delegate normalizeInputDidEndEditing:self.inputTextField.stringValue];
    
}


@end
