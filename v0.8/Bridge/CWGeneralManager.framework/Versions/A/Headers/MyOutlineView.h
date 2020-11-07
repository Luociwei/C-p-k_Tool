//
//  MyOutlineView.h
//  CPK_Tool
//
//  Created by ciwei luo on 2020/6/27.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
FOUNDATION_EXPORT NSString*  kDragOutlineViewTypeName;
//static NSString* const kDragOutlineViewTypeName = @"kDragOutlineViewTypeName";
NS_ASSUME_NONNULL_BEGIN

@interface MyOutlineView : NSOutlineView
@property(nonatomic,weak)NSMenu *treeMenu;
@end

NS_ASSUME_NONNULL_END
