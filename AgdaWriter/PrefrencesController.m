//
//  PrefrencesController.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "PrefrencesController.h"
#import "AWNotifications.h"

@implementation PrefrencesController

- (IBAction)fontSizeSelected:(NSPopUpButton *)sender {
    NSNumber * newFontSize = [[NSNumberFormatter new] numberFromString:sender.titleOfSelectedItem];
    [AWNotifications notifyFontSizeChanged:newFontSize];

    
}
@end
