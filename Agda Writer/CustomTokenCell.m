//
//  CustomTokenCell.m
//  AgdaWriter
//
//  Created by Marko Koležnik on 2. 05. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "CustomTokenCell.h"
#import "AWNotifications.h"
#import "AWHelper.h"
#import "AWColors.h"

@implementation CustomTokenCell

#define FONT_SCALAR 0.8

-(id)init
{
    self = [super init];
    if (self) {
        defaultFont = [AWHelper defaultFontInAgda];
        // make font smaller by some arbitrary factor
        if (defaultFont) {
            defaultFont = [[NSFontManager sharedFontManager] convertFont:defaultFont toSize:defaultFont.pointSize * FONT_SCALAR];
            
        }
        
    }
    return self;
}

- (id) initWithParentViewController:(id)parentViewController
{
    self = [self init];
    if (self) {
        self.parentViewController = parentViewController;
    }
    
    return self;
}


#pragma mark - NSTextAttachmentCell Overrides

- (NSSize)cellSize
{
    // font name and font size:
//    defaultFont.fontName
//    defaultFont.pointSize
    return NSMakeSize([[self stringValue] sizeWithAttributes:@{NSFontAttributeName:defaultFont}].width + 13.f,
                      [[self stringValue] sizeWithAttributes:@{NSFontAttributeName:defaultFont}].height);
}

- (NSPoint)cellBaselineOffset
{
    return NSMakePoint(-1.f, -1.f);
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self drawWithFrame:cellFrame inView:controlView characterIndex:NSNotFound layoutManager:nil];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex
{
    [self drawWithFrame:cellFrame inView:controlView characterIndex:charIndex layoutManager:nil];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager
{
    NSColor* bgColor = [AWColors unselectedTokenColor];
    NSColor* borderColor = [AWColors borderTokenColor];
    
    NSRect frame = cellFrame;
    CGFloat radius = ceilf([self cellSize].height / 2.f);
    NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 0.5, NSMinY(frame) + 3.5, NSWidth(frame) - 1, NSHeight(frame) - 1) xRadius: radius yRadius: radius];
//    [(highlighted ? [NSColor blueColor] : bgColor) setFill];
    [bgColor setFill];
    [roundedRectanglePath fill];
    [borderColor setStroke];
    [roundedRectanglePath setLineWidth: 1];
    [roundedRectanglePath stroke];
    
    
    
    CGSize size = [[self stringValue] sizeWithAttributes:@{NSFontAttributeName:defaultFont}];
    CGRect textFrame = CGRectMake(cellFrame.origin.x + (cellFrame.size.width - size.width)/2,
                                  cellFrame.origin.y + 2.f,
                                  size.width,
                                  size.height);
    
    [self setUsesSingleLineMode:YES];
    [[self stringValue] drawInRect:textFrame withAttributes:@{NSFontAttributeName:defaultFont, NSForegroundColorAttributeName:[NSColor whiteColor]}];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    highlighted = flag;
    [controlView setNeedsDisplayInRect:cellFrame];
}

- (BOOL)wantsToTrackMouse
{
    return YES;
}

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex
{
    // Hover
    return YES;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag
{
    return [self trackMouse:theEvent inRect:cellFrame ofView:controlView atCharacterIndex:NSNotFound untilMouseUp:flag];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag
{
    [self highlight:flag withFrame:cellFrame inView:controlView];
    [AWNotifications notifySelectAgdaRange:self.title sender:self.parentViewController];
    return YES;
}

@end
