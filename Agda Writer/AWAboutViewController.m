//
//  AWAboutViewController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 19. 08. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWAboutViewController.h"

@interface AWAboutViewController ()

@end

@implementation AWAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.attributionForMattGemmell setAllowsEditingTextAttributes: YES];
    [self.attributionForMattGemmell setSelectable: YES];
    NSMutableAttributedString * attribution = [[NSMutableAttributedString alloc] initWithString:@"Includes MAAttachedWindow code by "];
    NSURL * url = [NSURL URLWithString:@"http://mattgemmell.com/"];
    [attribution appendAttributedString:[self hyperlinkFromString:@"Matt Gemmell" withURL:url]];
    [attribution appendAttributedString:[[NSAttributedString alloc] initWithString:@"."]];
    [self.attributionForMattGemmell setAttributedStringValue:attribution];

    
    
}

-(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    
    [attrString endEditing];
    
    return attrString;
}

@end
