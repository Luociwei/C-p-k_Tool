//
//  MyEexception.m
//  MYAPP
//
//  Created by Zaffer.yang on 3/8/17.
//  Copyright © 2017 Zaffer.yang. All rights reserved.
//

#import "MyEexception.h"
#import <Cocoa/Cocoa.h>

@implementation MyEexception
// just remind the user, there are some error infomation.
+ (void)RemindException: (NSString*)Title Information:(NSString*)info{
    NSAlert* alert = [[NSAlert alloc]init];
    [alert setMessageText:Title];
    [alert addButtonWithTitle:@"OK"];
    [alert setInformativeText:info];
    [alert runModal];
}

// just remind the user.
+ (void)messageBox: (NSString*)Title Information:(NSString*)info{
    NSAlert* alert = [[NSAlert alloc]init];
    [alert setMessageText:Title];
    [alert setInformativeText:info];
    [alert runModal];
}

// just remind the user.
+(bool)messageBoxYesNo:(NSString *)prompt {
    //NSAlert *alert = [NSAlert alertWithMessageText: prompt
    //                                 defaultButton:@"OK"
    //                               alternateButton:@"Cancel"
    //                                   otherButton:nil
    //                     informativeTextWithFormat:@""];
    NSAlert *alert = [[NSAlert alloc]init];
    [alert setInformativeText:@""]; //sub text
    [alert setMessageText:prompt];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];

    NSInteger button = [alert runModal];
    
    return (button == NSAlertFirstButtonReturn);
}

+(bool)messageBoxYesNo:(NSString *)prompt informativeText:(NSString *)informativeText{
    //NSAlert *alert = [NSAlert alertWithMessageText: prompt
    //                                 defaultButton:@"OK"
    //                               alternateButton:@"Cancel"
    //                                   otherButton:nil
    //                     informativeTextWithFormat:@""];
    NSAlert *alert = [[NSAlert alloc]init];
    [alert setInformativeText:informativeText]; //sub text
    [alert setMessageText:prompt];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    
    NSInteger button = [alert runModal];
    
    return (button == NSAlertFirstButtonReturn);
}

+(NSString *)passwordBox:(NSString *)prompt defaultValue:(NSString *)defaultValue {
    //NSAlert *alert = [NSAlert alertWithMessageText: prompt
    //                                 defaultButton:@"OK"
    //                               alternateButton:@"Cancel"
    //                                   otherButton:nil
    //                     informativeTextWithFormat:@""];
    NSAlert *alert = [[NSAlert alloc]init];
    [alert setInformativeText:@"Enter Password:"];
    [alert setMessageText:prompt];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [input validateEditing];
        return [input stringValue];
    } else {
        return nil;
    }
}

@end
