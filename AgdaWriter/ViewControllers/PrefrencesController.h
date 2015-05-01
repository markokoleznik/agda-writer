//
//  PrefrencesController.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AWCommunitacion.h"

typedef enum : NSUInteger {
    TabViewFonts = 0,
    TabViewPaths = 1
} TabViews;

@interface PrefrencesController : NSWindow <NSTabViewDelegate, NSTextDelegate>
{
    AWCommunitacion * agdaCommunication;
}
@property (weak) IBOutlet NSTabView *preferencesTabView;

#pragma mark -
#pragma mark Fonts View

@property (weak) IBOutlet NSPopUpButton *fontSizePopUpButton;
- (IBAction)fontSizeAction:(NSPopUpButton *)sender;

@property (weak) IBOutlet NSPopUpButton *fontFamilyPopUpButton;
- (IBAction)fontFamilyAction:(NSPopUpButton *)sender;

#pragma mark -
#pragma mark Path View

@property (weak) IBOutlet NSTextField *pathToAgdaTextField;
- (IBAction)pathToAgdaSelected:(NSTextField *)sender;

@property (weak) IBOutlet NSButton *browsePathButton;
- (IBAction)browsePathAction:(NSButton *)sender;
@property (weak) IBOutlet NSProgressIndicator *searchForAgdaIndicator;
@property (weak) IBOutlet NSImageView *okSign;




@end
