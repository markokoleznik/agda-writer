//
//  AWMainSplitView.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 6. 02. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWMainSplitView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AWMainSplitView

-(void)awakeFromNib
{
    collapsed = NO;
    defaultWidth = [self positionOfDividerAtIndex:0];
    
}

- (IBAction)collapse:(id)sender
{
//    if (collapsed) {
//        [self setPosition:defaultWidth ofDividerAtIndex:0 animated:YES];
//        collapsed = NO;
//    }
//    else
//    {
//        defaultWidth = [self positionOfDividerAtIndex:0];
//        [self setPosition:[self maxPossiblePositionOfDividerAtIndex:0] ofDividerAtIndex:0 animated:YES];
//        collapsed = YES;
//    }
}


- (CGFloat)positionOfDividerAtIndex:(NSInteger)dividerIndex {
    // It looks like NSSplitView relies on its subviews being ordered left->right or top->bottom so we can too.
    // It also raises w/ array bounds exception if you use its API with dividerIndex > count of subviews.
    while (dividerIndex >= 0 && [self isSubviewCollapsed:[[self subviews] objectAtIndex:dividerIndex]])
        dividerIndex--;
    if (dividerIndex < 0)
        return 0.0f;
    
    NSRect priorViewFrame = [[[self subviews] objectAtIndex:dividerIndex] frame];
    return [self isVertical] ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame);
}


//- (void)animateDividerToPosition:(CGFloat)dividerPosition
//{
//    NSView *view0 = [[self subviews] objectAtIndex:0];
//    NSView *view1 = [[self subviews] objectAtIndex:1];
//    NSRect view0Rect = [view0 frame];
//    NSRect view1Rect = [view1 frame];
//    NSRect overalRect = [self frame];
//    CGFloat dividerThickness = [self dividerThickness];
//    
//    if ([self isVertical]) {
//        view0Rect.size.width = dividerPosition;
//        view1Rect.origin.x = dividerPosition + dividerThickness;
//        view1Rect.size.width = overalRect.size.width - view0Rect.size.width - dividerThickness;
//    } else {
//        view0Rect.size.height = dividerPosition;
//        view1Rect.origin.y = dividerPosition + dividerThickness;
//        view1Rect.size.height = overalRect.size.height - view0Rect.size.height - dividerThickness;
//    }
//    
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:2.3];
//    [[view0 animator] setFrame: view0Rect];
//    [[view1 animator] setFrame: view1Rect];
//    [NSAnimationContext endGrouping];    
//}

- (BOOL) setPositions:(NSArray *)newPositions ofDividersAtIndexes:(NSArray *)indexes {
    NSUInteger numberOfSubviews = self.subviews.count;
    
    // indexes and newPositions arrays must have the same object count
    if (indexes.count == newPositions.count == NO) return NO;
    // trying to move too many dividers
    if (indexes.count < numberOfSubviews == NO) return NO;
    
    NSRect newRect[numberOfSubviews];
    
    for (NSUInteger i = 0; i < numberOfSubviews; i++)
        newRect[i] = [[self.subviews objectAtIndex:i] frame];
    
    for (NSNumber *indexObject in indexes) {
        NSInteger index = [indexObject integerValue];
        CGFloat  newPosition = [[newPositions objectAtIndex:[indexes indexOfObject:indexObject]] doubleValue];
        if (self.isVertical) {
            CGFloat oldMaxXOfRightHandView = NSMaxX(newRect[index + 1]);
            newRect[index].size.width = newPosition - NSMinX(newRect[index]);
            CGFloat dividerAdjustment = (newPosition < NSWidth(self.bounds)) ? self.dividerThickness : 0.0;
            newRect[index + 1].origin.x = newPosition + dividerAdjustment;
            newRect[index + 1].size.width = oldMaxXOfRightHandView - newPosition - dividerAdjustment;
        } else {
            CGFloat oldMaxYOfBottomView = NSMaxY(newRect[index + 1]);
            newRect[index].size.height = newPosition - NSMinY(newRect[index]);
            CGFloat dividerAdjustment = (newPosition < NSHeight(self.bounds)) ? self.dividerThickness : 0.0;
            newRect[index + 1].origin.y = newPosition + dividerAdjustment;
            newRect[index + 1].size.height = oldMaxYOfBottomView - newPosition - dividerAdjustment;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(splitView:splitViewIsAnimating:)])
        [((id <NSSplitViewAnimatableDelegate>)self.delegate) splitView:self splitViewIsAnimating:YES];
    
    [CATransaction begin]; {
        [CATransaction setAnimationDuration:0.40]; // was 0.25
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [CATransaction setCompletionBlock:^{
            
            if ([self.delegate respondsToSelector:@selector(splitView:splitViewIsAnimating:)])
                [((id <NSSplitViewAnimatableDelegate>)self.delegate) splitView:self splitViewIsAnimating:NO];
            
        }];
        
        for (NSUInteger i = 0; i < numberOfSubviews; i++) {
            [[[self.subviews objectAtIndex:i] animator] setFrame:newRect[i]];
        }
    } [CATransaction commit];
    return YES;
}

- (BOOL) setPosition:(CGFloat)position ofDividerAtIndex:(NSInteger)dividerIndex animated:(BOOL) animated {
    if (!animated) [self setPosition:position ofDividerAtIndex:dividerIndex];
    else {
        NSUInteger numberOfSubviews = self.subviews.count;
        if (dividerIndex >= numberOfSubviews) return NO;
        [self setPositions:@[@(position)] ofDividersAtIndexes:@[@(dividerIndex)]];
    }
    return YES;
}
    
    
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        context.duration = 5.0f;
//        CGFloat maxPosition = [self maxPossiblePositionOfDividerAtIndex:0];
//        [[self animator] setPosition:maxPosition ofDividerAtIndex:0];
//    } completionHandler:^{
//        [[self animator] setPosition:[self minPossiblePositionOfDividerAtIndex:0] + 100 ofDividerAtIndex:0];
//    }];


@end
