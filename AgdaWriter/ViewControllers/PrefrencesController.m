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

-(void) awakeFromNib
{
    [self fillFontSizes];
    [self fillFontFamilies];
}

- (void) fillFontSizes
{
    for (int i = 8; i < 25; i++) {
        [self.fontsizePopUp addItemWithTitle:[NSString stringWithFormat:@"%i",i]];
    }
    
    [self.fontsizePopUp selectItemWithTitle:@"12"];
}

- (void) fillFontFamilies
{
    NSArray *fontFamilies = [[NSFontManager sharedFontManager] availableFontFamilies];
    for (NSString * fontFamily in fontFamilies) {
        [self.fontFamilyPopUp addItemWithTitle:fontFamily];
    }
    
    [self.fontFamilyPopUp selectItemWithTitle:@"Helvetica"];
}

- (IBAction)fontSizeSelected:(NSPopUpButton *)sender {
    NSNumber * newFontSize = [[NSNumberFormatter new] numberFromString:sender.titleOfSelectedItem];
    [AWNotifications notifyFontSizeChanged:newFontSize];

    
}
- (IBAction)fontFamilySelected:(NSPopUpButton *)sender {
    [AWNotifications notifyFontFamilyChanged:sender.titleOfSelectedItem];
    
}
@end
