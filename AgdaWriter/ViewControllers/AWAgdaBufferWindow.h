//
//  AWAgdaBufferWindow.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 28. 04. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWAgdaBufferWindow : NSWindow
@property (unsafe_unretained) IBOutlet NSTextView *agdaTextView;

@end
