//
//  AWHighlighting.h
//  AgdaWriter
//
//  Created by Marko Koležnik on 12. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AWHighlighting : NSObject


+ (void) highlightCodeAtRange:(NSRange) range actionName: (NSString *) actionName textView: (NSTextView *)textView;

@end
