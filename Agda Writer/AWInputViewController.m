//
//  AWInputViewController.m
//  Agda Writer
//
//  Created by Marko Koležnik on 21. 07. 15.
//  Copyright (c) 2015 koleznik.net. All rights reserved.
//

#import "AWInputViewController.h"
#import "UnicodeTransformator.h"
#import "AWHelper.h"

@interface AWInputViewController ()

@end

@class MAAttachedWindow;

@implementation AWInputViewController {
    AWInputViewType _type;
    BOOL _isGlobal;
    NSRect _rect;
    BOOL _autoCompleteTriggered;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputTextField.delegate = self;
    [self.inputTextField setFont:[AWHelper defaultFontInAgda]];
    
    _autoCompleteTriggered = NO;
    
    
    if (_isGlobal) {
        self.point = NSMakePoint(200, 220);
        
        switch (_type) {
            case AWInputViewTypeComputeNormalForm:
                [self.inputTitle setStringValue:@"Compute normal form (global):"];
                break;
            case AWInputViewTypeInfer:
                [self.inputTitle setStringValue:@"Infer (global):"];
                break;
            case AWInputViewTypeShowModuleContents:
                [self.inputTitle setStringValue:@"Show Module Contents (global):"];
                break;
            case AWInputViewTypeWhyInScope:
                [self.inputTitle setStringValue:@"Why in scope? (global):"];
                break;
            default:
                break;
        }
    }
    else {
        
        
        NSPoint point = NSMakePoint(_rect.origin.x + _rect.size.width/2, _rect.origin.y + _rect.size.height/2);
        self.point = point;
        NSRect frame = self.view.frame;
        [self.view setFrame:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width*2/3, frame.size.width*1/3)];
        switch (_type) {
            case AWInputViewTypeComputeNormalForm:
                [self.inputTitle setStringValue:@"Compute normal form (goal specific):"];
                break;
            case AWInputViewTypeInfer:
                [self.inputTitle setStringValue:@"Infer (goal specific):"];
                break;
            case AWInputViewTypeShowModuleContents:
                [self.inputTitle setStringValue:@"Show Module Contents (goal specific):"];
                break;
            case AWInputViewTypeWhyInScope:
                [self.inputTitle setStringValue:@"Why in scope? (goal specific):"];
                break;
                
            default:
                break;
        }
    }
    
    
    
    // Do view setup here.
}

- (id)initWithInputType: (AWInputViewType)inputType global: (BOOL)isGlobal rect:(NSRect)rect;
{
    self = [self initWithNibName:@"AWInputViewController" bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:
         @"NSWindowDidResignKeyNotification" object:nil];
        
        
        
        _type = inputType;
        _isGlobal = isGlobal;
        _rect = rect;
        
        
        
        
    }
    return self;
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    if (_autoCompleteTriggered) {
        return;
    }
    else {
        _autoCompleteTriggered = YES;
        [[[obj userInfo] objectForKey:@"NSFieldEditor"] complete:nil];
        
    }
    
}



-(void)keyUp:(NSEvent *)theEvent
{
    [super keyUp:theEvent];

    if (_autoCompleteTriggered) {
        _autoCompleteTriggered = NO;
    }
    if (theEvent.keyCode == 53) {
        // escape pressed, close window
        [self.delegate closeWindow];
    }
    else if (theEvent.keyCode == 49) {
        // space was pressed
        NSString * unicodeText = [UnicodeTransformator transformToUnicode:self.inputTextField.stringValue];
        if (![unicodeText isEqualToString:self.inputTextField.stringValue]) {
            self.inputTextField.stringValue = unicodeText;
        }
    }
}


-(NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    NSString * partialWord = [self.inputTextField.stringValue substringWithRange:charRange];
    if (charRange.location == 0) {
        return @[];
    }
    // Don't harass user if he writes '='
    if ([partialWord isEqualToString:@"="] ||
        [partialWord isEqualToString:@"_"]) {
        return @[];
    }
    NSDictionary * keyBindings = [AWHelper keyBindings];
    
    
    NSMutableArray * mutableArray = [[NSMutableArray alloc] init];
    NSArray * filteredArray = [keyBindings.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString * name = (NSString *)evaluatedObject;
        if ([name hasPrefix:@"\\"]) {
            name = [name substringFromIndex:1];
        }
        return [name hasPrefix:partialWord];
    }]];
    
    for (NSString * name in filteredArray) {
        if ([name hasPrefix:@"\\"]) {
            [mutableArray addObject:[name substringFromIndex:1]];
        }
        else {
            [mutableArray addObject:name];
        }
    }
    
    [mutableArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * name1 = (NSString *)obj1;
        NSString * name2 = (NSString *)obj2;
        if ([name1 hasPrefix:@"\\"]) {
            name1 = [name1 substringFromIndex:1];
        }
        if ([name2 hasPrefix:@"\\"]) {
            name2 = [name2 substringFromIndex:1];
        }
        return [name1 compare:name2];
    }];
    
    if (filteredArray.count == 1 && [filteredArray[0] isEqualToString:partialWord]) {
        return @[];
    }
    return mutableArray;
}


-(void)windowDidResignKey:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[MAAttachedWindow class]]) {
        [self.delegate closeWindow];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    [self.delegate inputDidEndEditing:self.inputTextField.stringValue withType:_type normalisationLevel:self.normalisationLevel];
    
}


@end
