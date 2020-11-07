//
//  MyTableView.h
//  CPK_Tool
//
//  Created by ciwei luo on 2020/6/19.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ExtendedTableViewDelegate< NSObject>

-(void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row location:(NSPoint)location;
-(void)tableViewKeyMove:(NSTableView *)tableView ;
@end

@interface MyTableView : NSTableView
 @property(weak)id<ExtendedTableViewDelegate>extendedDelegate; 
@end

NS_ASSUME_NONNULL_END
