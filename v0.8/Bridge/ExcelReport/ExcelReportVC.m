//
//  ExcelReport.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/7/3.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "ExcelReportVC.h"

@interface ExcelReportVC ()

@property (weak) IBOutlet NSButton *exportAllItems;
@property (weak) IBOutlet NSButton *btnApply;

@property (weak) IBOutlet NSButton *outOfBelowRange;

@property (weak) IBOutlet NSTextField *lslView;
@property (weak) IBOutlet NSTextField *uslView;

@property (weak) IBOutlet NSTextField *userView;
@property (weak) IBOutlet NSTextField *buildView;
@property (weak) IBOutlet NSButton *populateDistr;
@property (weak) IBOutlet NSTextField *projectView;

@end

@implementation ExcelReportVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//    _exportType = @"All";
//    _generatePlot = @"NO";
    
     self.btnApply.enabled = NO;
    
}

- (IBAction)clickAll:(NSButton *)btn {
//    if (btn.state) {
//        self.outOfBelowRange.state = 0;
//    }
    
    self.outOfBelowRange.state = !btn.state;
}

-(NSString *)getExportType{
    if (self.exportAllItems.state) {
        return @"All";
    }else{
        return @"FAIL";
    }
}

-(NSString *)getGeneratePlot{
    if (self.populateDistr.state) {
        return @"Yes";
    }else{
        return @"NO";
    }
}

- (IBAction)clickOut:(NSButton *)btn {
//    if (btn.state) {
//        self.exportAllItems.state = 0;
//    }
    self.exportAllItems.state = !btn.state;
}

- (IBAction)cancel:(NSButton *)sender {
    [self close];
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

-(void)controlTextDidChange:(NSNotification *)obj{
    if (obj.object) {
        
    }
    
    if (self.userView.stringValue.length &&self.projectView.stringValue.length&&self.buildView.stringValue.length) {
        
        self.btnApply.enabled = YES;

    }else{
        self.btnApply.enabled = NO;
    }
    
}

- (IBAction)apply:(NSButton *)sender {

    NSString *string =@"";
    if (!self.userView.stringValue.length) {
        string = @"User Name";
    }else if (!self.projectView.stringValue.length){
        string = @"Project Name";
    }else if (!self.buildView.stringValue.length){
        string = @"Target Build";
    }
    
    if (string.length) {
        [MyEexception RemindException:@"Warning!!!" Information:[NSString stringWithFormat:@"Please input info in %@ box",string]];
        return;
    }
    __block BOOL checkApply = NO;
    [self.itemOriginalDatas enumerateObjectsUsingBlock:^(ItemMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isNotApply) {
            checkApply = YES;
            *stop = YES;
        }
    }];
    if (checkApply) {
        //        [MyEexception messageBoxYesNo:@"Erorr" Information:@"you have updated new limit,but not apply"];
        BOOL is_exit = [MyEexception messageBoxYesNo:@"Erorr" informativeText:@"you have updated new limit,but not apply.if continue,please click yes."];
        if (!is_exit) {
            return;
        }
    }
    
    if (self.reportDelegate && [self.reportDelegate respondsToSelector:@selector(excelReportVCApplyClick:)]) {
        ReportMode *reportMode = [ReportMode new];
        reportMode.lsl = [self getDefaultVaule:self.lslView];
        reportMode.usl = [self getDefaultVaule:self.uslView];
        reportMode.user = [self getDefaultVaule:self.userView];
        reportMode.build = [self getDefaultVaule:self.buildView];
        reportMode.project = [self getDefaultVaule:self.projectView];
        reportMode.exportType = [self getExportType];
        reportMode.generatePlot = [self getGeneratePlot];
        reportMode.reportType = ReportModeTypeExcel;
        //
        //        reportMode.reportType = self.reportTypeView.selectedSegment ?  ReportModeTypeKeynote :ReportModeTypeExcel;
        [self.reportDelegate excelReportVCApplyClick:reportMode];
        
    }
    
}

@end
