//
//  PrefrencesController.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefrencesController : NSWindow
@property (weak) IBOutlet NSPopUpButton *fontsizePopUp;
- (IBAction)fontSizeSelected:(NSPopUpButton *)sender;

@end
