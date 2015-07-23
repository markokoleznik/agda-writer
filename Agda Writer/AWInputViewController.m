//
//  AWInputViewController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWInputViewController.h"

@interface AWInputViewController ()

@end



@implementation AWInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
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
//    NSLog(@"%@",theEvent);
}

-(NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    return nil;
}

-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    [self.delegate normalizeInputDidEndEditing:self.inputTextField.stringValue];
    
}


@end
