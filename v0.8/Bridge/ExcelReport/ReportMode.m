//
//  ExcelReportMode.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/7/3.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "ReportMode.h"

@implementation ReportMode
-(void)setReportType:(ReportModeType)reportType{
    _reportType = reportType;//    //excel-report  //keynote-report   one_item_plot
    if (reportType == ReportModeTypeExcel) {
        _reportTypeString = @"excel-report";
    }else if (reportType == ReportModeTypeKeynote){
        _reportTypeString = @"keynote-report";
    }else if (reportType == ReportModeTypeOneItem){
        _reportTypeString = @"one_item_plot";
    }
}
+(instancetype)defaultOneItemReportMode{
    ReportMode *mode = [[self alloc]init];
    mode.usl = @"9999999";
    mode.lsl = @"1.33";
    mode.project = @"";
    mode.user = @"";
    mode.build = @"";
    mode.generatePlot = @"";
    mode.exportType = @"";
    mode.reportType = ReportModeTypeOneItem;
    return mode;
}

//+(instancetype)defaultReportMode{
//    KeynoteReportMode *mode = [[KeynoteReportMode alloc]init];
//    mode.usl = @"9999999";
//    mode.lsl = @"1.33";
//
//    mode.reportType = ReportModeTypeOneItem;
//    return mode;
//}

@end
