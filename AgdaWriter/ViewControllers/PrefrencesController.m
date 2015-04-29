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
    self.preferencesTabView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPathView) name:AWOpenPreferences object:nil];
    
    [self fillFontSizes];
    [self fillFontFamilies];
    [self.searchForAgdaIndicator setHidden:YES];
//    [[self.searchForAgdaIndicator animator] startAnimation:nil];
}

- (void) fillFontSizes
{
    for (int i = 8; i <= 25; i++) {
        [self.fontSizePopUpButton addItemWithTitle:[NSString stringWithFormat:@"%i",i]];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *fontSize = (NSNumber *)[ud objectForKey:FONT_SIZE_KEY];
    [self.fontSizePopUpButton selectItemWithTitle:[NSString stringWithFormat:@"%i", [fontSize intValue]]];
}

- (void) fillFontFamilies
{
    NSArray *fontFamilies = [[NSFontManager sharedFontManager] availableFontFamilies];
    for (NSString * fontFamily in fontFamilies) {
        [self.fontFamilyPopUpButton addItemWithTitle:fontFamily];
    }
    
    [self.fontFamilyPopUpButton selectItemWithTitle:@"Helvetica"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *fontFamily = (NSString *)[ud stringForKey:FONT_FAMILY_KEY];
    [self.fontFamilyPopUpButton selectItemWithTitle:fontFamily];
}
#pragma mark -
#pragma mark Fonts View
- (IBAction)fontSizeAction:(NSPopUpButton *)sender {
    NSNumber * newFontSize = [[NSNumberFormatter new] numberFromString:sender.titleOfSelectedItem];
    [AWNotifications notifyFontSizeChanged:newFontSize];

}
- (IBAction)fontFamilyAction:(NSPopUpButton *)sender {
    [AWNotifications notifyFontFamilyChanged:sender.titleOfSelectedItem];
    
}


#pragma mark -
#pragma mark Path View

- (IBAction)pathToAgdaSelected:(NSTextField *)sender {
    NSLog(@"Path to agda selected");
}
- (IBAction)browsePathAction:(NSButton *)sender {

    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    if ([panel runModal] != NSFileHandlingPanelOKButton) {
        return;
    }
    NSURL * selectedFileURL = [[panel URLs] lastObject];
    NSString * selectedFilePath = [selectedFileURL path];
    [self testAgda:selectedFilePath];
    
}


-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    // Disable ok sign and progress indicator
    [self.searchForAgdaIndicator setHidden:YES];
    [self.okSign setHidden:YES];

    switch ([tabView indexOfTabViewItem:tabViewItem]) {
        case TabViewFonts:
            NSLog(@"Did select Fonts tab");
            break;
            
        case TabViewPaths:
            NSLog(@"Did select Paths tab");
            // Load spinning wheel
            // Try to find agda
            [self tryToFindAgda];
            break;
            
        default:
            break;
    }
}

- (void) testAgda:(NSString *) filePathToAgda
{
    // Test if agda exist
    BOOL isAgdaAvaliable = [[NSFileManager defaultManager] isExecutableFileAtPath:filePathToAgda];
    if (isAgdaAvaliable) {
        // We found Agda!
        
        // Set filePath to self.pathToAgdaTextField
        [self.pathToAgdaTextField setStringValue:filePathToAgda];
        
        // update User defaults
        [AWNotifications setAgdaLaunchPath:filePathToAgda];
        
        // animate spinning wheel
        [self.searchForAgdaIndicator setHidden:NO];
        [self.searchForAgdaIndicator.animator startAnimation:nil];
        
        [self performSelector:@selector(showOKsign) withObject:nil afterDelay:0.5];
        
    }
    else
    {
        // Agda not found.
        [self.pathToAgdaTextField setPlaceholderString:@"Please search for Agda executable"];
    }

}

- (void) tryToFindAgda
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if (!paths || paths.count < 1) {
        // We didn't find user Library folder. Abort.
        return;
    }
    // My path to agda
    // /Users/markokoleznik/Library/Haskell/bin/agda
    NSString * userDirectory = [paths objectAtIndex:0];
    NSString * filePathToAgda = [userDirectory stringByAppendingPathComponent:@"Haskell/bin/agda"];
    [self testAgda:filePathToAgda];
    
}
-(void)showOKsign
{
    [self.okSign setHidden:NO];
    [self.searchForAgdaIndicator setHidden:YES];
}

-(void)openPathView
{
    [self makeKeyAndOrderFront:nil];
    [self.preferencesTabView selectTabViewItemAtIndex:TabViewPaths];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
