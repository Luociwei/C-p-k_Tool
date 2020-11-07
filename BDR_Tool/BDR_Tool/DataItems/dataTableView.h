//
//  dataTableView.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "csvListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface dataTableView : NSViewController<NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate,NSSplitViewDelegate>
{
    csvListController *csvView;
    IBOutlet NSView *csvViewMain;
    IBOutlet NSView *leftViewMain;
}
@property (strong) IBOutlet NSView *viewWindow;
- (IBAction)btLoadCsvData:(id)sender;
- (IBAction)btnSearchCsv:(id)sender;

//@property (weak) IBOutlet NSImageView *cpkImageMap;
//@property (weak) IBOutlet NSImageView *correlationImageMap;
@property (weak) IBOutlet NSView *leftPane;
@property (weak) IBOutlet NSView *rightPanel;
@property (weak) IBOutlet NSSplitView *splitView;



@end

NS_ASSUME_NONNULL_END
