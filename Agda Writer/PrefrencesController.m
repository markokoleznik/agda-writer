//
//  PrefrencesController.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "PrefrencesController.h"
#import "AWNotifications.h"

#import "AWAgdaActions.h"

@implementation PrefrencesController


-(void)viewDidLoad
{
    self.preferencesTabView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPathView) name:AWOpenPreferences object:nil];
    
    [self fillFontSizes];
    [self fillFontFamilies];
    [self.searchForAgdaIndicator setHidden:YES];
    [[self.searchForAgdaIndicator animator] startAnimation:nil];
    [self prepareData];
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
    [self hideOKSignAndSpinningWheel];
    NSLog(@"Path to agda selected");
    if ([self isAgdaAvaliableAtPath:sender.stringValue]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AWPossibleAgdaPathFound object:nil];
        [self.pathToAgdaTextField setStringValue:sender.stringValue];
        [AWNotifications setAgdaLaunchPath:sender.stringValue];
        // Show OK sign
        [self.searchForAgdaIndicator setHidden:YES];
        [self showOKsign];
        return;
    }
    else {
        [self showAlertMessage];
    }
    
    
}
- (IBAction)browsePathAction:(NSButton *)sender {
    [self hideOKSignAndSpinningWheel];
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setShowsHiddenFiles:YES];
    [panel setAllowedFileTypes:@[@""]];
    if ([panel runModal] != NSFileHandlingPanelOKButton) {
        return;
    }
    NSURL * selectedFileURL = [[panel URLs] lastObject];
    NSString * selectedFilePath = [selectedFileURL path];
    
    if ([self isAgdaAvaliableAtPath:selectedFilePath]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AWPossibleAgdaPathFound object:nil];
        [self.pathToAgdaTextField setStringValue:selectedFilePath];
        [AWNotifications setAgdaLaunchPath:selectedFilePath];
        // Show OK sign
        [self.searchForAgdaIndicator setHidden:YES];
        [self showOKsign];
        return;
    }
    else {
        [self showAlertMessage];
    }

    
}


- (void) showAlertMessage
{
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Find automatically"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"It seems that path to Agda isn't set correctly.\nFind automatically?"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSModalResponse returnCode = [alert runModal];
    switch (returnCode) {
        case NSAlertFirstButtonReturn:
            // Automatically
            [self tryToFindAgda];
            break;
        case NSAlertSecondButtonReturn:
            // Cancel button pressed, do nothing.
            break;
            
        default:
            break;
    }
}

-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    // Disable ok sign and progress indicator
    [self.searchForAgdaIndicator setHidden:YES];
    [self.okSign setHidden:YES];

    switch ([tabView indexOfTabViewItem:tabViewItem]) {
        case TabViewFonts:
            NSLog(@"Did select Fonts tab");
            [self hideOKSignAndSpinningWheel];
            break;
            
        case TabViewPaths:
            NSLog(@"Did select Paths tab");

            // Try to find agda
            if (![AWNotifications agdaLaunchPath]) {
                
                [self tryToFindAgda];
            }
            else
            {
                [self.pathToAgdaTextField setStringValue:[AWNotifications agdaLaunchPath]];
                if (![self isAgdaAvaliableAtPath:[AWNotifications agdaLaunchPath]]) {
                    // Ask to find it automaticaly
                    [self showAlertMessage];
                    
                }
            }
            break;
            
        default:
            break;
    }
}



- (void) tryToFindAgda
{
    // My path to agda
    // /Users/markokoleznik/Library/Haskell/bin/agda
    [self.searchForAgdaIndicator setHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(possibleAgdaPathsFound:) name:AWPossibleAgdaPathFound object:nil];
    agdaCommunication = [[AWCommunitacion alloc] init];
    [agdaCommunication searchForAgda];
}

-(void)possibleAgdaPathsFound:(NSNotification *)notification
{
    NSLog(@"possible path: %@", notification.object);
    NSString * reply = notification.object;
    NSArray * possiblePaths = [reply componentsSeparatedByString:@"\n"];
    
    if (possiblePaths && possiblePaths.count > 0) {
        for (NSString * possiblePath in possiblePaths) {
            if ([possiblePath hasPrefix:NSHomeDirectory()]) {
                // Test if Agda is executable at path
                
                if ([self isAgdaAvaliableAtPath:possiblePath]) {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:AWPossibleAgdaPathFound object:nil];
                    [self.pathToAgdaTextField setStringValue:possiblePath];
                    [AWNotifications setAgdaLaunchPath:possiblePath];
                    // Show OK sign
                    [self.searchForAgdaIndicator setHidden:YES];
                    [self showOKsign];
                    return;
                }
            }
        }
    }
    // Agda not found.
    [self.searchForAgdaIndicator setHidden:YES];
    [self.pathToAgdaTextField setPlaceholderString:@"Agda not found! Please browse it manually"];
    
    
}



-(void) hideOKSignAndSpinningWheel
{
    [self.okSign setHidden:YES];
    [self.searchForAgdaIndicator setHidden:YES];
}

-(BOOL)isAgdaAvaliableAtPath:(NSString *)path
{
    AWCommunitacion * agdaComm = [[AWCommunitacion alloc] init];
    return [agdaComm isAgdaAvaliableAtPath:path];
    
}

-(void)showOKsign
{
    [self.okSign setHidden:NO];
    [self.searchForAgdaIndicator setHidden:YES];
}

-(void)openPathView
{
//    [self makeKeyAndOrderFront:nil];
    [self.preferencesTabView selectTabViewItemAtIndex:TabViewPaths];
}

-(void)prepareData
{
    themes = @[@{@"name" : @"Default"},
               @{@"name" : @"Dracula"}];
    
    samples = @[
                @{@"name" : @"Comment", @"color" : [NSColor redColor], @"identifier" : @"comment"},
                @{@"name" : @"Custom types", @"color" : [NSColor greenColor]}
                ];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ([tableView.identifier isEqualToString:@"Samples"]) {
        return samples.count;
    }
    else if ([tableView.identifier isEqualToString:@"Themes"]) {
        return themes.count;
    }
    return 0;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    if ([tableView.identifier isEqualToString:@"Samples"]) {
        NSTableCellView * result = [tableView makeViewWithIdentifier:@"SampleCell" owner:self];
        NSDictionary * dict = (NSDictionary *)samples[row];
        NSAttributedString * attrValue = [[NSAttributedString alloc] initWithString:dict[@"name"] attributes:@{NSForegroundColorAttributeName: dict[@"color"]}];
        [result.textField setAttributedStringValue:attrValue];
        return result;
    }
    else if ([tableView.identifier isEqualToString:@"Themes"]) {
        NSTableCellView * result = [tableView makeViewWithIdentifier:@"ThemeCell" owner:self];
        NSDictionary * dict = (NSDictionary *)themes[row];
        result.textField.stringValue = dict[@"name"];
        return result;
    }
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView * tableView = notification.object;
//    NSInteger selectedRow = tableView.selectedRow;
    if ([tableView.identifier isEqualToString:@"Samples"]) {
        NSLog(@"User pressed samples");
    }
    else if ([tableView.identifier isEqualToString:@"Themes"]) {
        NSLog(@"User pressed Themes");
    }
}




















-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
