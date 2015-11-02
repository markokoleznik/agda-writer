//
//  AWInputWindow.h
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWInputWindow : NSWindow <NSTextFieldDelegate>
-(id)init;
-(void)show;
@end
