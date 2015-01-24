//
//  TestView.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 10. 12. 14.
//  Copyright (c) 2014 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestView : NSView
@property (nonatomic, strong) IBOutlet NSView *view;

-(id)initWithFrame:(NSRect)frameRect;
@end
