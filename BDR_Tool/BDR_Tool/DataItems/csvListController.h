//
//  csvListController.h
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Feed.h"

NS_ASSUME_NONNULL_BEGIN


@interface csvListController : NSViewController<NSApplicationDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource>
{
 
}
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSMutableArray<Feed *> *feeds;


- (IBAction)btLoadScript:(id)sender;


@end

NS_ASSUME_NONNULL_END
