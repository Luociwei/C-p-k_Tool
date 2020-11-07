//
//  AppDelegate.m
//  SC_CPK
//
//  Created by ciwei luo on 2020/3/31.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "AppDelegate.h"
#import <CWGeneralManager/CWFileManager.h>
#import <CWGeneralManager/NSString+Extension.h>
@interface AppDelegate ()

@end

@implementation AppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
    
 
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)windowWillClose:(NSNotification *)notification {
    
    NSWindow *window =notification.object;
    NSString *title = window.title;
    if ([title.uppercaseString containsString:@"BRIDGE"]) {
        NSString *deskPath = [NSString cw_getDesktopPath];
        NSString *plotDir =[deskPath stringByAppendingPathComponent:@"CPK_Log/plot/"];
        NSString *tempDir =[deskPath stringByAppendingPathComponent:@"CPK_Log/temp/"];
        NSString *fail_plotDir =[deskPath stringByAppendingPathComponent:@"CPK_Log/fail_plot/"];
        
        [CWFileManager cw_removeItemAtPath:plotDir];
        [CWFileManager cw_removeItemAtPath:tempDir];
        
//        NSString *logCmd = @"ps -ef |grep -i python |grep -i start.py |grep -v grep|awk '{print $2}' | xargs kill -9";
//        system([logCmd UTF8String]); //杀掉cpk_test.py 进程
        [CWFileManager cw_removeItemAtPath:fail_plotDir];
        [NSApp terminate:nil];
    }
    
}

@end
