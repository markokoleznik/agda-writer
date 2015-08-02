//
//  AWInputViewController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWInputViewController.h"
#import "UnicodeTransformator.h"
#import "AWHelper.h"

@interface AWInputViewController ()

@end

@class MAAttachedWindow;

@implementation AWInputViewController {
    AWInputViewType type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputTextField.delegate = self;
    [self.inputTextField setFont:[AWHelper defaultFontInAgda]];
    // Do view setup here.
}

- (id)initWithInputType: (AWInputViewType)inputType global: (BOOL)isGlobal rect:(NSRect)rect;
{
    self = [self initWithNibName:@"AWInputViewController" bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:
         @"NSWindowDidResignKeyNotification" object:nil];
        
        
        
        type = inputType;
        
        if (isGlobal) {
            self.point = NSMakePoint(200, 220);
        }
        else {
            
            
            NSPoint point = NSMakePoint(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
            self.point = point;
            NSRect frame = self.view.frame;
            [self.view setFrame:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width*2/3, frame.size.width*1/3)];
            switch (inputType) {
                case AWInputViewTypeComputeNormalForm:
                    [self.inputTitle setStringValue:@"Compute normal form (goal specific):"];
                    break;
                case AWInputViewTypeInfer:
                    break;
                case AWInputViewTypeShowModuleContents:
                    break;
                    
                default:
                    break;
            }
            [self.inputTitle setStringValue:@"Compute normal form (goal specific):"];
        }
        
        
        
        
    }
    return self;
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
    [self.delegate inputDidEndEditing:self.inputTextField.stringValue withType:type];
    
}


@end
