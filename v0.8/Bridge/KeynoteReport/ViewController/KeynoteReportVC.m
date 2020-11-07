
//
//  ReportVC.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/24.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "KeynoteReportVC.h"

@interface KeynoteReportVC ()
@property (weak) IBOutlet NSTextField *cpkLslView;
@property (weak) IBOutlet NSTextField *cpkUslView;

@property (weak) IBOutlet NSTextField *binsView;
@property (weak) IBOutlet NSSegmentedControl *reportTypeView;


@end

@implementation KeynoteReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

}

- (IBAction)btnClickApply:(NSButton *)sender {
    
//    __block BOOL checkApply = NO;
//    [self.itemOriginalDatas enumerateObjectsUsingBlock:^(ItemMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.isNotApply) {
//            checkApply = YES;
//            *stop = YES;
//        }
//    }];
//    if (checkApply) {
//        //        [MyEexception messageBoxYesNo:@"Erorr" Information:@"you have updated new limit,but not apply"];
//        BOOL is_exit = [MyEexception messageBoxYesNo:@"Erorr" informativeText:@"you have updated new limit,but not apply.if continue,please click yes."];
//        if (!is_exit) {
//            return;
//        }
//    }
    
    if (self.reportDelegate && [self.reportDelegate respondsToSelector:@selector(reportVCApplyClick:)]) {
        ReportMode *reportMode = [ReportMode new];
        reportMode.lsl = [self getDefaultVaule:self.cpkLslView];
        reportMode.usl = [self getDefaultVaule:self.cpkUslView];
        reportMode.user = @"";
        reportMode.build = @"";
        reportMode.generatePlot = @"";
        reportMode.exportType = @"";
        reportMode.project = @"";
        reportMode.reportType = ReportModeTypeKeynote;
       
        [self.reportDelegate reportVCApplyClick:reportMode];
        
    }else{
//        ReportMode *reportMode = [ReportMode new];
//        reportMode.lsl = [self getDefaultVaule:self.cpkLslView];
//        reportMode.usl = [self getDefaultVaule:self.cpkUslView];
//        reportMode.bins = [self getDefaultVaule:self.binsView];
//
//        reportMode.reportType = self.reportTypeView.selectedSegment ? ReportModeTypeExcel :ReportModeTypeKeynote;
//        self.applyBlock(reportMode);
    }
    

    
//    [self close];
    

}

-(NSString *)getDefaultVaule:(NSTextField *)textF{
    NSString *vaule = @"";
    if (!textF.stringValue.length) {
        vaule = textF.placeholderString;
    }else{
        vaule = textF.stringValue;
    }
    return vaule;
}


- (IBAction)btnClickCancel:(NSButton *)sender {
    
    [self close];
}

@end
