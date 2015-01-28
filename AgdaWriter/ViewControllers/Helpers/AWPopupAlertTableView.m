//
//  AWPopupAlertTableView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 28. 01. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWPopupAlertTableView.h"
#import "AWNotifications.h"

@implementation AWPopupAlertTableView

- (void)keyDown:(NSEvent *)theEvent
{

    NSString *characters = [theEvent characters];
    
    switch ([characters characterAtIndex:0])
    {
        case NSEnterCharacter:
            
            break;
        case NSNewlineCharacter:
            break;
        case NSCarriageReturnCharacter:
            [AWNotifications notifyKeyReturnPressed: AWEnterPressed];
            break;
        default: break;
    }
    
    switch ([theEvent keyCode]) {
        case 53:
            [AWNotifications notifyKeyReturnPressed:AWEscapePressed];
            break;
            
        default:
            break;
    }
    
    [super keyDown:theEvent];
    
}

@end
