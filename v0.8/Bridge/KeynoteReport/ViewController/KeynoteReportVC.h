//
//  ReportVC.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/24.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CWGeneralManager/MyViewController.h>
#import "ReportMode.h"
#import "ItemMode.h"
#import <CWGeneralManager/MyEexception.h>
NS_ASSUME_NONNULL_BEGIN


@protocol ReportVCDelegate< NSObject>

-(void)reportVCApplyClick:(ReportMode *)reportMode;

@end


@interface KeynoteReportVC : MyViewController
@property(weak)id<ReportVCDelegate>reportDelegate;
//@property (nonatomic,strong) NSArray<ItemMode *> *itemOriginalDatas;
@end

NS_ASSUME_NONNULL_END
