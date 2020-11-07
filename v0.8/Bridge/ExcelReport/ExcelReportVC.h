//
//  ExcelReport.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/7/3.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CWGeneralManager/MyViewController.h>
#import "ReportMode.h"
#import "ItemMode.h"
#import <CWGeneralManager/MyEexception.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ExcelReportVCDelegate< NSObject>

-(void)excelReportVCApplyClick:(ReportMode *)reportMode;

@end


@interface ExcelReportVC : MyViewController
@property(weak)id<ExcelReportVCDelegate>reportDelegate;
@property (nonatomic,strong) NSArray<ItemMode *> *itemOriginalDatas;
@end

NS_ASSUME_NONNULL_END
