//
//  AWToastWindow.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 23. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    ToastTypeLoadSuccessful,
    ToastTypeLoadFailed,
    ToastTypeSuccess,
    ToastTypeFailed
} ToastType;


@interface AWToastWindow : NSWindow

- (id)initWithToastType:(ToastType)toastType;
- (void)show;
@end
