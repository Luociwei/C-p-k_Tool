//
//  MyEexception.h
//  MYAPP
//
//  Created by Zaffer.yang on 3/8/17.
//  Copyright © 2017 Zaffer.yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEexception : NSObject
+ (void)RemindException: (NSString*)Title Information:(NSString*)info;
+ (void)messageBox: (NSString*)Title Information:(NSString*)info;
+ (bool)messageBoxYesNo: (NSString*)prompt;
+(bool)messageBoxYesNo:(NSString *)prompt informativeText:(NSString *)informativeText;
+(NSString *)passwordBox:(NSString *)prompt defaultValue:(NSString *)defaultValue;
@end
