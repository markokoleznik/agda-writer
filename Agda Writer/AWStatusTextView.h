//
//  AWStatusTextView.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 3. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWStatusTextView : NSTextView

- (IBAction)clearContet:(id)sender;

@property (nonatomic) id parentViewController;

@end
