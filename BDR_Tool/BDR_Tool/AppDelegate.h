//
//  AppDelegate.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/23.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StartUp.h"
#import "RedisInterface.hpp"
#import "Client.h"
#import "dataTableView.h"
#import "dataPlotView.h"
//#import "loadCsvControl.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    
    IBOutlet NSView *tableViewDetail;
    IBOutlet NSView *plotViewDetail;
    
    NSViewController * tablePanel;
    NSViewController * plotPanel;
    
    StartUp * startPython;

}



@end

