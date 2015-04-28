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
    NSLog(@"Prefrences Controller is awake");
    [self fillFontSizes];
    [self fillFontFamilies];
}

- (void) fillFontSizes
{
    for (int i = 8; i <= 25; i++) {
        [self.fontsizePopUp addItemWithTitle:[NSString stringWithFormat:@"%i",i]];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *fontSize = (NSNumber *)[ud objectForKey:FONT_SIZE_KEY];
    [self.fontsizePopUp selectItemWithTitle:[NSString stringWithFormat:@"%i", [fontSize intValue]]];
}

- (void) fillFontFamilies
{
    NSArray *fontFamilies = [[NSFontManager sharedFontManager] availableFontFamilies];
    for (NSString * fontFamily in fontFamilies) {
        [self.fontFamilyPopUp addItemWithTitle:fontFamily];
    }
    
    [self.fontFamilyPopUp selectItemWithTitle:@"Helvetica"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *fontFamily = (NSString *)[ud stringForKey:FONT_FAMILY_KEY];
    [self.fontFamilyPopUp selectItemWithTitle:fontFamily];
}

- (IBAction)fontSizeSelected:(NSPopUpButton *)sender {
    NSNumber * newFontSize = [[NSNumberFormatter new] numberFromString:sender.titleOfSelectedItem];
    [AWNotifications notifyFontSizeChanged:newFontSize];

    
}
- (IBAction)fontFamilySelected:(NSPopUpButton *)sender {
    [AWNotifications notifyFontFamilyChanged:sender.titleOfSelectedItem];
    
}
@end
