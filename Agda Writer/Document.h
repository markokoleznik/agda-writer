//
//  Document.h
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument

@property (strong) NSTextView * mainTextView;
@property NSString * contentString;
@property NSURL * filePath;

@end

