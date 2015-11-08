//
//  Document.m
//  Agda Writer
//
//  Created by Marko Koležnik on 15. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "Document.h"

@interface Document ()

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    NSWindowController * windowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"];
    
    // Set represented object, so we can access this class in window controller.
    windowController.contentViewController.representedObject = self;
    [self addWindowController:windowController];
}

-(void)saveDocument:(id)sender
{
    [super saveDocument:sender];
}

-(void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo
{
//    NSLog(@"URL: %@", url);
    self.filePath = url;
    
    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}


-(BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
//    NSLog(@"%@", [self.mainTextView string]);
//    NSLog(@"URL: %@", url);

    NSError * error;
    BOOL success = [self.mainTextView.string writeToURL:url atomically:NO encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error saving file, reason: %@", error.description);
    }
    return success;
}


-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    
    NSLog(@"reading from: %@", url);
    self.filePath = url;
    return [super readFromURL:url ofType:typeName error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {

    if (data) {
        self.contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (self.contentString) {
            return YES;
        }
    }
    
    return NO;

}

@end
