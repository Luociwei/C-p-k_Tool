//
//  ExcelReportMode.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/7/3.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ReportModeType) {
    
    ReportModeTypeExcel=0,
    ReportModeTypeKeynote=1,
    ReportModeTypeOneItem=2,
};


NS_ASSUME_NONNULL_BEGIN

@interface ReportMode : NSObject
@property (nonatomic,copy)NSString *lsl;
@property (nonatomic,copy)NSString *usl;
@property (nonatomic,copy)NSString *exportType;
@property (nonatomic,copy)NSString *generatePlot;
@property (nonatomic,copy)NSString *user;
@property (nonatomic,copy)NSString *build;
@property (nonatomic,copy)NSString *project;
@property (nonatomic)ReportModeType reportType;
@property (nonatomic,readonly,copy)NSString *reportTypeString;

+(instancetype)defaultOneItemReportMode;
@end

NS_ASSUME_NONNULL_END

