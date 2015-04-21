//
//  AWContainerStatusTextView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWContainerStatusTextView.h"
#import "AWColors.h"
#import "AWNotifications.h"

@implementation AWContainerStatusTextView

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f ;
    
    [self.layer setBackgroundColor:[AWColors defaultBackgroundColor]];
    
    [self.layer setBorderColor:[AWColors defaultSeparatorColor]];
    
}



@end
