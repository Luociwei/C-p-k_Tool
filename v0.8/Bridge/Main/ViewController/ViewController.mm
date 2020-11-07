//
//  ViewController.m
//  SC_CPK
//
//  Created by ciwei luo on 2020/3/31.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "ViewController.h"
#import "ShowingLogVC.h"
#import <CWGeneralManager/NSString+Extension.h>
#import <CWGeneralManager/CWFileManager.h>
#import <CWGeneralManager/PythonTask.h>
#import <CWGeneralManager/parseCSV.h>
#import <CWGeneralManager/MyEexception.h>
#import <CWGeneralManager/MyTableView.h>
#import "ItemMode.h"
#import "LoadingVC.h"
#import "ShowingLogVC.h"
#import "KeynoteReportVC.h"
#import "ExcelReportVC.h"
#import "SnVauleVC.h"
#import "ColorByMode.h"
#import "LoadCsvController.h"
#import "Client.h"

#define  cpk_zmq_addr           @"tcp://127.0.0.1:3100"
//#define  correlation_zmq_addr   @"tcp://127.0.0.1:3110"
//#define  calculate_zmq_addr     @"tcp://127.0.0.1:3120"


typedef NS_ENUM(NSUInteger, CPK_EventType) {
    CPK_EventTypeOneItem = 0,
    CPK_EventTypeExcelReport = 1,
    CPK_EventTypeKNoteReport = 2,
    CPK_EventTypeAllReport = 3,
};


@interface ViewController ()<ExtendedTableViewDelegate,ReportVCDelegate,ExcelReportVCDelegate,LoadCsvControllerDelegate>
@property (nonatomic,strong) NSMutableArray *csvTestDatas;
@property (nonatomic,strong) NSMutableDictionary *items_dicDatas;

@property (nonatomic,strong) NSMutableArray<ItemMode *> *itemOriginalDatas;
//@property (nonatomic,strong) NSMutableArray *titles_datas;
@property (nonatomic,strong) NSMutableArray<ItemMode *> *itemDatas;
@property (nonatomic,strong) NSMutableArray<ItemMode *> *lasItemDatas;
@property (nonatomic,strong) NSMutableArray<SnVauleMode *> *sn_datas;
@property (nonatomic,strong) NSMutableArray<SnVauleMode *> *original_sn_datas;
@property (nonatomic,strong) NSMutableArray<ColorByMode *> *color_datas;
@property (nonatomic,strong) NSMutableArray<ColorByMode *> *color_datas2;
@property (nonatomic,strong) NSMutableArray<NSString *> *colorTable2_datas;
@property (nonatomic,strong) NSMutableDictionary *color_dicDatas;

@property (weak) IBOutlet MyTableView *itemsTableView;
@property (weak) IBOutlet NSTableView *snTableView;
@property (weak) IBOutlet NSComboBox *colorbByBox2;
@property (weak) IBOutlet MyTableView *colorByTableview2;

@property (weak) IBOutlet NSComboBox *colorByBox;
@property (weak) IBOutlet MyTableView *colorByTableView;
@property (weak) IBOutlet NSTextField *pathOpenLabel;
@property (weak) IBOutlet NSTextField *pathLogLable;
@property (weak) IBOutlet NSTextField *LSL_lable;
@property (weak) IBOutlet NSTextField *USL_lable;
@property (weak) IBOutlet NSTextField *binsTextF;

@property (unsafe_unretained) IBOutlet NSTextView *logView;
@property (strong,nonatomic)NSMutableString *mutLogString;

@property (weak) IBOutlet NSImageView *mapView;

@property (weak) IBOutlet NSImageView *correlationView;

@property (weak) IBOutlet NSSegmentedControl *removeSegment;

@property (weak) IBOutlet NSSegmentedControl *frist_all_last_Segment;

@property (weak) IBOutlet NSButton *scriptBtn;
@property (nonatomic,strong)LoadingVC *loadingVC;
@property (nonatomic,strong)SnVauleVC *snVauleVC;
@property (nonatomic,strong)KeynoteReportVC *keynoteReportVC;
@property (nonatomic,strong)ExcelReportVC *excelReportVC;
@property (nonatomic,strong)LoadCsvController *loadCsvVC;
@property (weak) IBOutlet NSSegmentedControl *testSegment;
@property (weak) IBOutlet NSSegmentedControl *limitDataSegment;

@property (weak) IBOutlet NSSegmentedControl *reportSegment;

@property (weak) IBOutlet NSButton *selectXData;
@property (weak) IBOutlet NSButton *selectYData;
@property (nonatomic,strong) ItemMode *last_itemM;



@end

@implementation ViewController{
    NSString *_plot_logPath;
    NSString *_temp_logPath;
    NSTask *Task;
    NSFileHandle *filehandler;
    NSInteger mismatchItemsCount;
//    PyObject *_cpkModule;
    BOOL _isRunPython;
    PythonTask *pTask;
    BOOL _isSelectX;
   // BOOL _isFristClickRow;
//    BOOL _isLoadScript;
    NSInteger channel_id_index;
    NSArray *_colorByBoxValues;
    NSInteger _clickIndexTableColumn;
    NSInteger _clickCpkTableColumn;
    NSInteger _index_parametric;
    Client *cpkClient;
    NSString * _cpkHTHL;
    NSString * _cpkLTHL;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    cpkClient = [[Client alloc] init];   // connect CPK zmq for cpk_test.py
    [cpkClient CreateRPC:cpk_zmq_addr withSubscriber:nil];
    [cpkClient setTimeout:20*1000];
    
    self.view.wantsLayer=YES;//80-180-250
    self.view.layer.backgroundColor = [NSColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
   // self.view.layer.backgroundColor = [NSColor gridColor].CGColor;
    
    _mutLogString = [[NSMutableString alloc]init];

    self.itemsTableView.extendedDelegate = self;
    self.colorByTableView.extendedDelegate = self;
    self.colorByTableview2.extendedDelegate = self;
    [self initAllDatas];
    
    [self initTableView:self.colorByTableview2];
    [self initTableView:self.colorByTableView];
    [self initTableView:self.snTableView];
    [self initTableView:self.itemsTableView];
    
//    [self.colorByBox removeAllItems];
//    [self.colorByBox addItemsWithObjectValues:@[@"Off"]];

    _colorByBoxValues =@[@"Off",@"Version",@"Product",@"Station ID",@"Special Build Name",@"Fixture Channel ID",@"Diags_Version"];
    [self.colorByBox removeAllItems];//@"Station ID",@"Version"
    [self.colorByBox addItemsWithObjectValues:_colorByBoxValues];
    
    [self.colorbByBox2 removeAllItems];//@"Station ID",@"Version"
    [self.colorbByBox2 addItemsWithObjectValues:@[@"Off"]];
    [self.colorByBox selectItemAtIndex:0];
    [self.colorbByBox2 selectItemAtIndex:0];
   // self.pathLogLable.stringValue = [NSString stringWithFormat:@"Report File Path:%@",logPath];

    [self generateLogDir];

    NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
    [self setPicture:pic_path];
    self.loadingVC =[LoadingVC new];
    self.loadCsvVC =[LoadCsvController new];
    self.loadCsvVC.loadCsvDelegate = self;
    self.snVauleVC = [SnVauleVC new];
    self.keynoteReportVC = [KeynoteReportVC new];
    self.excelReportVC =[ExcelReportVC new];
    self.keynoteReportVC.reportDelegate = self;
    self.excelReportVC.reportDelegate = self;


    
    //[self Lanuch_cpk];
}

- (IBAction)logFileClick:(NSButton *)sender {//.stringByDeletingLastPathComponent
    [CWFileManager cw_openFileWithPath:_plot_logPath];
    
}

-(void)Lanuch_cpk
{
    system("/usr/bin/ulimit -n 8192");
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.8/bin/python3";
    NSString *budle_path = [[NSBundle mainBundle] resourcePath];//generate_keynote.py
    NSString * arg = [budle_path stringByAppendingPathComponent:@"python_test/start.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i start.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //杀掉cpk_test.py 进程
    [self execute_withTask:cmd withPython:arg];
    
}

-(int)execute_withTask:(NSString*) szcmd withPython:(NSString *)arg
{
    if (!szcmd) return -1;
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:szcmd];
    [task setArguments:[NSArray arrayWithObjects:arg, nil]];
    [task launch];
    return 0;
}

//- (IBAction)cpkTest:(NSButton *)sender {
//    //NSLog(@"==>%s",myRedis->GetString("test_item_1"));
//    //NSLog(@"==>%s",myRedis->GetString("test_item_2"));
//
//    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
//    int ret = [cpkClient SendCmd:@"Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Frequency"];
//    if (ret > 0)
//    {
//        NSString * response = [cpkClient RecvRquest:1024];
//
//        if (!response)
//        {    //Not response
//            //@throw [NSException exceptionWithName:@"automation Error" reason:@"pleaase check fixture." userInfo:nil];
//            NSLog(@"zmq for python error");
//        }
//        NSLog(@"app->get response from python: %@",response);
//    }
//    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
//    NSLog(@"====python 执行时间: %f",now-starttime);
//
//}

-(void)initAllDatas{
    
    [self.csvTestDatas removeAllObjects];
    self.csvTestDatas = nil;
    self.csvTestDatas = [[NSMutableArray alloc]init];
    
    [self.items_dicDatas removeAllObjects];
    self.items_dicDatas = nil;
    self.items_dicDatas = [[NSMutableDictionary alloc]init];
    
    
    [self.color_datas removeAllObjects];
    self.color_datas = nil;
    self.color_datas = [[NSMutableArray alloc]init];
    
    [self.color_datas2 removeAllObjects];
    self.color_datas2 = nil;
    self.color_datas2 = [[NSMutableArray alloc]init];
    
    
    [self.colorTable2_datas removeAllObjects];
    self.colorTable2_datas = nil;
    self.colorTable2_datas = [[NSMutableArray alloc]init];
    
    [self.color_dicDatas removeAllObjects];
    self.color_dicDatas = nil;
    self.color_dicDatas = [[NSMutableDictionary alloc]init];
    
    
    [self.itemDatas removeAllObjects];
    self.itemDatas = nil;
    self.itemDatas = [[NSMutableArray alloc]init];
    
    [self.itemOriginalDatas removeAllObjects];
    self.itemOriginalDatas = nil;
    self.itemOriginalDatas = [[NSMutableArray alloc]init];
    
    [self.original_sn_datas removeAllObjects];
    self.original_sn_datas = nil;
    self.original_sn_datas = [[NSMutableArray alloc]init];
    
    [self.sn_datas removeAllObjects];
    self.sn_datas = nil;
    self.sn_datas = [[NSMutableArray alloc]init];
    
    [self deletePic];
}

-(void)generateLogDir{
    NSString *deskPath = [NSString cw_getDesktopPath];
    NSString *plot_logPath =[deskPath stringByAppendingPathComponent:@"CPK_Log/plot"];
    [CWFileManager cw_createFile:plot_logPath  isDirectory:YES];
    NSString *temp_logPath =[deskPath stringByAppendingPathComponent:@"CPK_Log/temp"];
    [CWFileManager cw_createFile:temp_logPath  isDirectory:YES];
    _plot_logPath =plot_logPath;
    _temp_logPath =temp_logPath;
    
    NSString *item_limit_path = [_temp_logPath stringByAppendingPathComponent:@"item_limit.csv"];
    if (![CWFileManager cw_isFileExistAtPath:item_limit_path]) {
        NSMutableString *text = [[NSMutableString alloc] initWithString:@"index,item,low,upper,new_lsl,new_usl,apply\n"];
        
        NSError *error;
        [text writeToFile:item_limit_path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

-(void)initTableView:(NSTableView *)tableView{
    tableView.headerView.hidden=NO;
    tableView.usesAlternatingRowBackgroundColors=YES;
    tableView.rowHeight = 20;
    //[tableView setDoubleAction:@selector(doubleClick:)];
    tableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask |NSTableViewSolidVerticalGridLineMask ;
}

- (IBAction)save_csv:(NSButton *)sender {
    if (!self.itemOriginalDatas.count) {
        return;
    }
    NSMutableString *text = [[NSMutableString alloc] initWithString:@"index,item,low,upper,new_lsl,new_usl,apply\n"];
    NSString *path = [_temp_logPath stringByAppendingPathComponent:@"item_limit.csv"];

    NSArray *columns = self.itemsTableView.tableColumns;
    for (int m =0;m<self.itemOriginalDatas.count;m++) {
        
        ItemMode *item_mode = self.itemOriginalDatas[m];

        for (int i =0; i<8; i++) {
            if (i==4) {
                continue;
            }
            NSString *key = [columns[i] identifier];
            [text appendString:[item_mode getVauleWithKey:key]];
            if (i!=7) {
                [text appendString:@","];
            }else{
                [text appendString:@"\n"];
            }
        }

    }

    NSError *error;
    [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    //[text writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (sender==nil) {
        return;
    }
    if(error){
        NSLog(@"save file error %@",error);
        [MyEexception RemindException:@"Save Fail" Information:[NSString stringWithFormat:@"Error Info:%@",error]];
        
    }else{
        [MyEexception RemindException:@"Save Success" Information:[NSString stringWithFormat:@"File Path:%@",path]];
    }
}


-(void)addScriptWithPath:(NSString *)path{
    if (!self.csvTestDatas.count) {
        return;
    }
    
    self.loadingVC.showingText = @"script";
//    [self.loadingVC showViewAsSheetOnViewController:self];
    
    CSVParser *csv = [[CSVParser alloc]init];
    NSMutableArray *scriptArray = nil;
    if ([csv openFile:path]) {
        scriptArray = [csv parseFile];
    }
    
    if (scriptArray.count<2 ) {
        
        [self.loadingVC dismisssViewOnViewController:self];
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"Test Seq. CSV has wrong format.\nPlease make sure right test sequence csv was used"]];
        return;
    }
    
    if (scriptArray.count<self.itemOriginalDatas.count ) {
        
        [self.loadingVC dismisssViewOnViewController:self];
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"Test Data. CSV count is more than Test Seq. CSV.\nPlease make sure right Test Data. csv or Test Seq. CSV was used"]];
        return;
    }
    
    
    NSArray *titles_arr = scriptArray[0];
    NSInteger count = titles_arr.count;
    NSString *testName =titles_arr[0];
    NSString *subTestName =titles_arr[1];
    NSString *subSubTestName =titles_arr[2];
    
    if (count<3 || ![testName.uppercaseString containsString:@"TESTNAME"]|| ![subTestName.uppercaseString containsString:@"SUBTESTNAME"]|| ![subSubTestName.uppercaseString containsString:@"SUBSUBTESTNAME"]) {
        
        [self.loadingVC dismisssViewOnViewController:self];
        return;
    }
    
    
    NSMutableArray *scriptItemsNameArr = [[NSMutableArray alloc] init];
    for (int i =1; i<scriptArray.count; i++) {
        NSArray *item_arr = scriptArray[i];
        if (item_arr.count <3) {
            continue;
        }
        
        NSString *itemTestName = [item_arr[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *itemSubTestName =[item_arr[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *itemSubSubTestName =[item_arr[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *itemName = [NSString stringWithFormat:@"%@ %@ %@",itemTestName,itemSubTestName,itemSubSubTestName];
        if (itemName.length<3 || [itemName containsString:@"\\"]|| [itemName containsString:@"//"]) {
            continue;
        }
        NSString *desc =item_arr[3];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:itemName forKey:@"name"];
        [dic setValue:desc forKey:@"desc"];
        [scriptItemsNameArr addObject:dic];
        //mutar
    }
    
    
    NSMutableArray *newCsvListArr =[self changeToListArray:self.csvTestDatas];
    NSMutableArray *mutCsvArr =[self sortCsv:newCsvListArr scriptItemsNameArr:scriptItemsNameArr];
//    Backlight,Minimum_Brightness-PWM_Mode_VBAT4V3,IBATT_backlight_OFF
    if (mismatchItemsCount>20) {
        [self.loadingVC dismisssViewOnViewController:self];
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"Only load Test data,Because Test data and test Seq. CSV has %ld mismatches.\nPlease make sure right test sequence csv was used",(long)mismatchItemsCount]];
        mismatchItemsCount = 0;

//        [self.itemsTableView reloadData];
        [self reloadDataForItemsTableView];
        return;
    }
    
    //cw
//    _isLoadScript = YES;
    if ([self generateItemsTableListDatas:mutCsvArr csvPath:path isLoadScript:YES]) {
        
        self.csvTestDatas =mutCsvArr;
    }else{
       [self.loadingVC dismisssViewOnViewController:self];
    }
    
    [self generateColorTableListDatas:mutCsvArr];

    [self generateColor2TableListDatas:mutCsvArr];
    
    [self.loadingVC dismisssViewOnViewController:self];
    
    self.scriptBtn.enabled = NO;
    
    [self writeNewScriptCsvFile:mutCsvArr scriptPath:path];
    
    if (mismatchItemsCount >0) {
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"Test data and test Seq. CSV has %ld mismatches.\nPlease make sure right test sequence csv was used",(long)mismatchItemsCount]];
       // mismatchItemsCount = 0;
    }
    
}


- (IBAction)add_script:(NSButton *)sender {
    if (!self.csvTestDatas.count) {
        return;
    }
    
    [CWFileManager openPanel:^(NSString * _Nonnull path) {
        [self addScriptWithPath:path];
    }];
    
}


-(void)writeNewScriptCsvFile:(NSMutableArray *)mutCsvArr scriptPath:(NSString *)scriptPath{
    
    NSMutableString *text = [[NSMutableString alloc] init];
    for (int m1 =0; m1<mutCsvArr.count; m1++) {
        NSArray *rowArr = mutCsvArr[m1];
        for (int m2 =0; m2<rowArr.count; m2++) {
            id row_str = rowArr[m2];
            if ([row_str isKindOfClass:[NSMutableDictionary class]]) {
                row_str = [row_str objectForKey:@"name"];
            }
            [text appendString:row_str];
            if (m2 == rowArr.count-1) {
                [text appendString:@"\n"];
            }else{
                [text appendString:@","];
            }
            
        }
    }
    NSString *pathLogName  =[self.pathOpenLabel.stringValue.lastPathComponent stringByReplacingOccurrencesOfString:@".csv" withString:@""];
    NSString *newFileName = [NSString stringWithFormat:@"%@&&%@",pathLogName,scriptPath.lastPathComponent];
    NSString *path1 = [_temp_logPath stringByAppendingPathComponent:newFileName];
    NSError *error;
    [text writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [MyEexception RemindException:@"Save Success" Information:[NSString stringWithFormat:@"New csv file path:%@",path1]];
}

-(NSMutableArray *)sortCsv:(NSMutableArray *)newCsvListArr scriptItemsNameArr:(NSMutableArray *)scriptItemsNameDicArr{
    NSMutableArray *sortArr = [[NSMutableArray alloc]init];
    if (newCsvListArr.count<13) {
        return sortArr;
    }
    NSMutableArray *csv_titlesArr = [[NSMutableArray alloc]init];
    NSInteger count =[newCsvListArr[0] count];
    for (NSInteger i =0; i<_index_parametric; i++) {
        [csv_titlesArr addObject:newCsvListArr[i]];
    }
    //cwssss    NSArray *head_arr = mutArray[0];

    NSMutableArray *csv_itemsArr = [[NSMutableArray alloc]init];
    for (NSInteger j =_index_parametric; j<newCsvListArr.count; j++) {
        [csv_itemsArr addObject:newCsvListArr[j]];
    }
    
    NSMutableArray *mut_itemsArrFromSciprt = [[NSMutableArray alloc]init];

    for (int k = 0; k<scriptItemsNameDicArr.count; k++) {
        NSMutableArray *mut_itemArr = [[NSMutableArray alloc]init];
        for (int z =0; z<count; z++) {
            if (z==0) {
                [mut_itemArr addObject:scriptItemsNameDicArr[k]];
            }else{
//                NSMutableDictionary *dic= [[NSMutableDictionary alloc]init];
//                [dic setValue:@"" forKey:@"name"];
//                [dic setValue:@"" forKey:@"desc"];
//               [mut_itemArr addObject:dic];
                [mut_itemArr addObject:@""];
            }
            
        }
        [mut_itemsArrFromSciprt addObject:mut_itemArr];
    }
    
    NSMutableArray *new_itemsArrFromSciprt = [self getSortNewItemsArr:csv_itemsArr new_itemsArr:mut_itemsArrFromSciprt];

    sortArr =[self changeToRowArray:new_itemsArrFromSciprt csv_titlesArr:csv_titlesArr];
    return sortArr;

    
}

-(NSMutableArray *)changeToRowArray:(NSMutableArray *)new_itemsArrFromSciprt csv_titlesArr:(NSMutableArray *)csv_titlesArr{
    NSMutableArray *newArrRows = [[NSMutableArray alloc]init];
    NSArray *siteArr =csv_titlesArr[0];

    for (int k = 0; k<[siteArr count]; k++) {
        NSMutableArray *mut_csvArr = [[NSMutableArray alloc]init];
        [newArrRows addObject:mut_csvArr];
    }
    
        for (int z = 0; z<csv_titlesArr.count; z++) {
            NSMutableArray *csv_titles = csv_titlesArr[z];
            for (int i =0; i<csv_titles.count; i++) {
                NSMutableArray *mutArrRow = newArrRows[i];
                [mutArrRow addObject:csv_titles[i]];
            }
           // [mutArrRow addObject:csv_titles];
        }
        
    for (int z = 0; z<new_itemsArrFromSciprt.count; z++) {
        NSMutableArray *csv_titles = new_itemsArrFromSciprt[z];
        for (int i =0; i<csv_titles.count; i++) {
            NSMutableArray *mutArrRow = newArrRows[i];
            [mutArrRow addObject:csv_titles[i]];
        }
        // [mutArrRow addObject:csv_titles];
    }
    

    return newArrRows;
  
}

-(NSMutableArray *)getSortNewItemsArr:(NSMutableArray *)csv_itemsArr new_itemsArr:(NSMutableArray *)new_itemsArr{
    NSMutableArray *sortItemsArr = [[NSMutableArray alloc]init];
    
    for (int i =0; i<new_itemsArr.count; i++) {
        NSMutableArray *itemNameArr = new_itemsArr[i];
        NSMutableDictionary *dic =itemNameArr[0];
//        NSString *scirpt_itemName = [dic objectForKey:@"name"];
//        NSLog(@"-------%d---",i);
        NSMutableArray *itemArr = [self searchScirptItemNameInCsv_itemsArr:csv_itemsArr scirptItemDic:dic];
        
        if (itemArr.count) {
            [sortItemsArr addObject:itemArr];
        }else{
            [itemNameArr exchangeObjectAtIndex:0 withObjectAtIndex:1];
            [sortItemsArr addObject:itemNameArr];
        }
    }
    
    NSMutableArray *mismatchItems =[self getMismatchItems:csv_itemsArr sortItemsArr:sortItemsArr];
    
    [sortItemsArr addObjectsFromArray:mismatchItems];
    return sortItemsArr;
    
}

-(NSMutableArray *)getMismatchItems:(NSMutableArray *)csv_itemsArr sortItemsArr:(NSMutableArray *)sortItemsArr{
    NSMutableArray *mismatchItems = [[NSMutableArray alloc]init];
    int i =0;
    for (NSMutableArray *csv_itemArr in csv_itemsArr) {
        NSString *csv_itemName =csv_itemArr[1] ;
        BOOL isMatch = NO;
        int j =0;
        for (NSMutableArray *sort_itemArr in sortItemsArr) {

            id sort_itemName =sort_itemArr[1];
            if ([sort_itemName isKindOfClass:[NSMutableDictionary class]]) {
                sort_itemName=[sort_itemName objectForKey:@"name"];
//                if ([sort_itemName isEqualToString:@"Backlight,Minimum_Brightness-PWM_Mode_VBAT4V3,IBATT_backlight_OFF"]) {
//                    NSLog(@"1");
//                }
            }
            if ([sort_itemName isEqualToString:csv_itemName]) {
                isMatch = YES;
                
                break;
            }
            j++;
        }
        if (!isMatch) {
            [mismatchItems addObject:csv_itemArr];
        }
        i++;
    }
    mismatchItemsCount =mismatchItems.count;

    return mismatchItems;
}

-(NSMutableArray *)searchScirptItemNameInCsv_itemsArr:(NSMutableArray *)csv_itemsArr scirptItemDic:(NSMutableDictionary *)scirptItemDic{
    NSString *scirptItemName = [scirptItemDic objectForKey:@"name"];
    for (int i =0;i<csv_itemsArr.count;i++) {
        NSMutableArray *csv_itemArr =csv_itemsArr[i];
        id csv_itemName =csv_itemArr[1];
        if ([csv_itemName isKindOfClass:[NSMutableDictionary class]]) {
            continue;
        }

        if ([csv_itemName isEqualToString:scirptItemName]) {
            
            NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:csv_itemArr];
            [arr replaceObjectAtIndex:1 withObject:scirptItemDic];
            
            return arr;
        }
    }
    
    return nil;
    
}

-(NSMutableArray *)changeToListArray:(NSMutableArray *)csvArr{
    
    NSMutableArray *newListArr = [[NSMutableArray alloc]init];

    for (int k = 0; k<[csvArr[1] count]; k++) {
        NSMutableArray *mut_csvArr = [[NSMutableArray alloc]init];
        [newListArr addObject:mut_csvArr];
    }
    
    
    for (int i =0 ; i<csvArr.count; i++) {
        
        NSMutableArray *item_arr = csvArr[i];
        if (item_arr.count != [csvArr[1] count]) {
            continue;
        }
//        NSMutableArray *mut_csvArr = [[NSMutableArray alloc]init];
        for (int j = 0; j<item_arr.count; j++) {
            
            NSString *str = @"";
            if ([item_arr[j] length]) {
                str = item_arr[j];
            }

            NSMutableArray *mut_csvArr =newListArr[j];
            [mut_csvArr addObject:str];
        }
        
        
    }
    
    return newListArr;
    
}


-(ItemMode *)matchItemModeWithItemName:(NSString *)item_name{
    for (ItemMode *itemM in self.itemOriginalDatas) {
        if ([itemM.item isEqualToString:item_name]) {
            return itemM;
        }
    }
    
    return nil;
}

-(NSMutableArray *)get_calculateArrWithCsvPath:(NSString *)csvPath isLoadScript:(BOOL)isLoadScript{
    NSString *path = [_temp_logPath stringByAppendingPathComponent:@"calculate_param.csv"];
    if (!isLoadScript) {//
        [CWFileManager cw_removeItemAtPath:path];
        NSString *settingListPath= [[NSBundle mainBundle] pathForResource:@"SettingList.plist" ofType:nil];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:settingListPath];
        NSString *python_path = @"";
        BOOL isPython3 = [dic[@"isPython3"] boolValue];
        if (isPython3) {
            python_path =dic[@"which python3"];
        }else{
            python_path =dic[@"which python2"];
        }
        
        NSString *budle_path = [[NSBundle mainBundle] resourcePath];//generate_keynote.py
        NSString *python_file = [budle_path stringByAppendingPathComponent:@"python_test/start.py"];
        PythonTask *pTask = [[PythonTask alloc]initWithPythonPath:python_file parArr:@[csvPath,_plot_logPath.stringByDeletingLastPathComponent,_cpkLTHL,_cpkHTHL,@"Off",@"250",@"yes",@"Accelerometer AVG-FS8g_ODR200HZ_Zup accel_nmGALP_average_z",@"",@"calculate-param",@"",@"",@"",@"",@"Off",@"",@"",@"",@"",@"",@"",@"",@""] lauchPath:python_path];
        NSString *read = [pTask read];
        [self appenLog:read];
    }
    
    
    NSMutableArray *calculateArr = [[NSMutableArray alloc]init];
    if ([CWFileManager cw_isFileExistAtPath:path]) {
        CSVParser *csv = [[CSVParser alloc]init];
        if ([csv openFile:path]) {
            calculateArr =[csv parseFile];
        }
    }

    return calculateArr;
}


-(NSInteger)getIndexParametricWithArray:(NSArray *)head_arr{
   
    NSInteger index_parametric  = [head_arr indexOfObject:@"Parametric"];
    if (index_parametric<12) {
        index_parametric = 12;
    }
    
    
    return index_parametric;
    
}


-(BOOL)addCsvWithPath:(NSString *)path isLoadScript:(BOOL)isLoadScript{
    self.loadingVC.showingText = @"csv";
    [self.loadingVC showViewAsSheetOnViewController:self];
    
//    if ([path isEqualToString:self.pathOpenLabel.stringValue]) {
//        return YES;
//    }
    
    NSMutableArray *mutCsvArr = [[NSMutableArray alloc]init];
    CSVParser *csv = [[CSVParser alloc]init];
    
    if ([csv openFile:path]) {
        mutCsvArr =[csv parseFile];
    }
    
    if (mutCsvArr.count<8 ) {
        
        [self.loadingVC dismisssViewOnViewController:self];
        return NO;
    }
    mismatchItemsCount = 0;
    NSInteger count = [mutCsvArr[1] count];
    NSMutableArray *newCsvArr = [[NSMutableArray alloc]initWithArray:mutCsvArr];
    _index_parametric = [self getIndexParametricWithArray:newCsvArr[0]];
    
    for (int i =0; i<newCsvArr.count; i++) {
        NSMutableArray *arr = newCsvArr[i];
        NSInteger arr_count = arr.count;
        if (i>=0 && i<8) {
            if (arr.count != count) {
                for (int j =0; j<count- arr_count; j++) {
                    [arr addObject:@""];
                }
            }
        }
        
        if (arr.count != count) {
            
            [mutCsvArr removeObject:arr];
            
        }
//        if (parametric>=13) {
//
////            for (int z =12; z<parametric; z++) {
//               [mutCsvArr[i] removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(12, parametric-12)]];
//
//        }
        
    }
    
    
//    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:mutCsvArr.count];
//    // 外层一个循环
//    for (NSString *item in mutCsvArr) {
//        // 调用-containsObject:本质也是要循环去判断，因此本质上是双层遍历
//        // 时间复杂度为O ( n^2 )而不是O (n)
//        if (![resultArray containsObject:item]) {
//            [resultArray addObject:item];
//        }
//    }
//


    if ([self generateItemsTableListDatas:mutCsvArr csvPath:path isLoadScript:NO]) {
        
        [self.csvTestDatas removeAllObjects];
        self.csvTestDatas =mutCsvArr;
    }
    
//    _isLoadScript = NO;
    [self generateColorTableListDatas:mutCsvArr];
    
    [self generateColor2TableListDatas:mutCsvArr];
    
   // [self.loadingVC dismisssViewOnViewController:self];
    
    self.pathOpenLabel.stringValue = path;
    
    [self appenLog:path];
    
    [self.scriptBtn setEnabled:YES];
    _isSelectX = NO;
//    BOOL needLoadScript =  [MyEexception messageBoxYesNo:@"Prompt" informativeText:@"Loading the csv is successful.Do you need loading scrpit now ?"];
//    if (needLoadScript) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self add_script:nil];;
//            });
//
//        });
//
//    }
    return YES;
}

- (IBAction)add_csv_click:(NSButton *)sender {
    [self.loadCsvVC showViewOnViewController:self];
    
//    [CWFileManager openPanel:^(NSString * _Nonnull path) {
//        [self addCsvWithPath:path];
//    }];
    
}


-(void)appenLog:(NSString *)str{
//    [self.mutLogString appendString:str];
//    [self.mutLogString appendString:@"\n"];
//    self.logView.string =self.mutLogString;
    if (str.length) {
        [ShowingLogVC postNotificationWithLog:str type:@""];
    }
    
}

//- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
//    NSComboBox *comboBox = notification.object;
//    NSString *title = comboBox.stringValue;
//    [self.color_datas removeAllObjects];
//    if ([self.color_dicDatas.allKeys containsObject:title]) {
//
//        [self.color_datas addObjectsFromArray:[self.color_dicDatas objectForKey:title]];
//    }
//    [self.colorByTableView reloadData];
//}




- (IBAction)seletionChanged:(NSComboBox *)comboBox {
    
//    if (self.itemsTableView.selectedRow<0) {
//        return;
//    }
    
    if (comboBox == self.colorByBox) {
        NSString *str = self.colorByBox.stringValue;
        
        self.color_datas2 =nil;
        
        if ([str.lowercaseString isEqualToString:@"off"]) {
            [self.colorbByBox2 removeAllItems];//@"Station ID",@"Version"
            //        NSMutableArray *colorbByBox2Arr =[colorbByBox2MutArr removeObject:str];
            [self.colorbByBox2 addItemsWithObjectValues:@[@"Off"]];
        }else{
            [self.colorbByBox2 removeAllItems];//@"Station ID",@"Version"
            NSMutableArray *colorbByBox2MutArr = [[NSMutableArray alloc]initWithArray:_colorByBoxValues];
            [colorbByBox2MutArr removeObject:str];
            //        NSMutableArray *colorbByBox2Arr =[colorbByBox2MutArr removeObject:str];
            [self.colorbByBox2 addItemsWithObjectValues:colorbByBox2MutArr];
        }
        [self.colorbByBox2 selectItemAtIndex:0];
        self.colorTable2_datas = nil;
        [self.colorByTableview2 reloadData];

    }else{
//        NSString *str = self.colorbByBox2.stringValue;
       // [self.colorByTableview2 reloadData];
    }
    
    [self reloadColorDatas:comboBox];
    
    
    if ([comboBox.stringValue.lowercaseString isEqualToString:@"off"]) {
        NSInteger index = self.itemsTableView.selectedRow;
        
        [self reflesh:self.itemsTableView row:index];
    }


}

-(void)reloadColorDatas:(NSComboBox *)comboBox {
    NSString *title = comboBox.stringValue;
    
//    [self.color_datas removeAllObjects];

    if (comboBox == self.colorByBox ) {
        if ([self.color_dicDatas.allKeys containsObject:title]) {
            
            self.color_datas =[self.color_dicDatas objectForKey:title];
        }else{
            self.color_datas =nil;//[[NSMutableArray alloc]init]
        }
        
        [self.colorByTableView reloadData];
    }else{
        [self reloadColorBy2TableView];
    }
  
}


-(void)reloadColorBy2TableView{
    //        if ([self.color_dicDatas.allKeys containsObject:title]) {
    //
    //            self.color_datas2 =[self.color_dicDatas objectForKey:title];
    //        }else{
    //            self.color_datas2 =nil;//[[NSMutableArray alloc]init]
    //        }
    //        [self.colorByTableview2 reloadData];
    
    //        NSArray *colorByModeArr = self.color_dicDatas[title];
    //        for (int i =0; i<colorByModeArr.count; i++) {
    //            ColorBy2Mode *mode2 = [colorByModeArr[i] colorBy2Mode];
    //            NSString *colorTitle = mode2.colorTitle;
    self.colorTable2_datas = nil;
    NSInteger row = self.colorByTableView.selectedRow;
    if (row <0) {
        [self.colorByTableview2 reloadData];
        return;
    }
    NSString *color1title = self.colorByBox.stringValue;
    NSArray *colorByModeArr=[self.color_dicDatas objectForKey:color1title];
    ColorBy2Mode *mode2 = [colorByModeArr[row] colorBy2Mode];
    NSString *color2title = self.colorbByBox2.stringValue;
    //  NSString
    
    if ([color2title.lowercaseString isEqualToString:@"version"]) {
        
        self.colorTable2_datas =[[NSMutableArray alloc]initWithArray: mode2.versionArray.allObjects];
        
    }else if ([color2title.lowercaseString containsString:@"station id"]){
        
        self.colorTable2_datas = [[NSMutableArray alloc]initWithArray: mode2.stationIDArr.allObjects];
        
    }else if ([color2title.lowercaseString containsString:@"special build name"]){
        self.colorTable2_datas = [[NSMutableArray alloc]initWithArray: mode2.specialBuildNameArr.allObjects];;
        
    }else if ([color2title.lowercaseString containsString:@"channel"]&&[color2title.lowercaseString containsString:@"id"]&&[color2title.lowercaseString containsString:@"fixture"]){
        self.colorTable2_datas = [[NSMutableArray alloc]initWithArray: mode2.channelIDArray.allObjects];;
   
    }else if ([color2title.lowercaseString containsString:@"product"]){
        self.colorTable2_datas = [[NSMutableArray alloc]initWithArray: mode2.productArray.allObjects];;
        
    }else if ([color2title.lowercaseString containsString:@"diags"]){
        self.colorTable2_datas = [[NSMutableArray alloc]initWithArray: mode2.diagsVersionArr.allObjects];;
        
    }
    else{
        
    }
 
//    if (self.colorTable2_datas.count<=3) {
//        self.colorTable2_datas=nil;
//    }
    
    [self.colorByTableview2 reloadData];
    
    
}

#pragma mark-  NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    //返回表格共有多少行数据
    if (tableView == self.colorByTableView) {
        return [self.color_datas count];
    }
    else if (tableView == self.colorByTableview2) {
  
        return [self.colorTable2_datas count];
        
    }
    
    else if (tableView == self.snTableView) {
        return [self.sn_datas count];
    }
    
    else{
        return [self.itemDatas count];
    }
    
}

#pragma mark-  NSTableViewDelegate
//-(void)doubleClick:(NSTableView *)tableView{
//    if (_isRunPython) {
//        return;
//    }
//    if (tableView == self.itemsTableView || tableView == self.colorByTableView ) {
//        NSIndexSet *indexes = tableView.selectedRowIndexes;
//        NSInteger index = indexes.firstIndex;
//        if (self.itemDatas.count) {
//            ItemMode *itemM = self.itemDatas[index];
//            if ([itemM.low isEqualToString:itemM.upper]&&tableView == self.itemsTableView) {
//                NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
//                [self setPicture:pic_path];
//                return;
//            }
//            
//            [self runPython:@"one_item_plot"];
////            [self appenLog:@"loading chat pic...."];
////            NSString *pic_path =[NSString stringWithFormat:@"%@/temp_pic.png",_temp_logPath];
////            [self setPicture:pic_path];
////            [self appenLog:@"loading chat pic finish"];
//            
//        }
//        
//    }
//}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
   
    NSString *identifier = tableColumn.identifier;
    if ([identifier isEqualToString:@"index"]) {
        
        _clickIndexTableColumn=_clickIndexTableColumn+1;

        NSMutableArray *mutArr4 = [[NSMutableArray alloc]init];
        NSMutableArray *mutArr5 = [[NSMutableArray alloc]init];
        for (int i =0; i<self.itemOriginalDatas.count; i++) {
            ItemMode *mode = self.itemOriginalDatas[i];
            if (mode.dataType == DataTypeInsight) {
                [mutArr4 addObject:mode];
            }else if (mode.dataType == DataTypeNotInsight){
                
            }else if (mode.dataType == DataTypeMismatch){
                [mutArr5 addObject:mode];
            }
            
        }
        self.itemDatas = nil;
        if (_clickIndexTableColumn%3==1) {
//            [mutArr1 addObjectsFromArray:mutArr2];
            self.itemDatas = mutArr4;
            self.lasItemDatas =mutArr4;
        }else if(_clickIndexTableColumn%3==2){
//            [mutArr2 addObjectsFromArray:mutArr1];
            self.itemDatas = mutArr5;
            self.lasItemDatas =mutArr5;
        }else{
            self.itemDatas = self.itemOriginalDatas;
            self.lasItemDatas =self.itemOriginalDatas;
        }
        
//        [self.itemsTableView reloadData];
        [self reloadDataForItemsTableView];
    }else if ([identifier isEqualToString:@"Cpk-Orig"]) {
        _clickCpkTableColumn=_clickCpkTableColumn+1;
        
        NSMutableArray *mutArr1 = [[NSMutableArray alloc]init];
        NSMutableArray *mutArr2 = [[NSMutableArray alloc]init];
        NSMutableArray *mutArr3 = [[NSMutableArray alloc]init];
        for (int i =0; i<self.itemOriginalDatas.count; i++) {
            ItemMode *mode = self.itemOriginalDatas[i];
            if (mode.isCpkPass == CpkOrigResultTypeGreen) {
                [mutArr2 addObject:mode];
            }else if(mode.isCpkPass == CpkOrigResultTypeYellow){
                [mutArr1 addObject:mode];
            }else if(mode.isCpkPass == CpkOrigResultTypeRed){
                [mutArr3 addObject:mode];
            }
            
        }
        self.itemDatas = nil;
        if (_clickCpkTableColumn%4==1) {
//            [mutArr1 addObjectsFromArray:mutArr2];
//            [mutArr1 addObjectsFromArray:mutArr3];
            self.itemDatas = mutArr2;
            self.lasItemDatas =mutArr2;
        }else if(_clickCpkTableColumn%4==2){
//            [mutArr2 addObjectsFromArray:mutArr1];
//            [mutArr2 addObjectsFromArray:mutArr3];
            self.itemDatas = mutArr1;
            self.lasItemDatas =mutArr1;
        }else if(_clickCpkTableColumn%4==3){
            //            [mutArr2 addObjectsFromArray:mutArr1];
            //            [mutArr2 addObjectsFromArray:mutArr3];
            self.itemDatas = mutArr3;
            self.lasItemDatas =mutArr3;
        }else{
            self.itemDatas = self.itemOriginalDatas;
            self.lasItemDatas =self.itemOriginalDatas;
        }
        
        //        [self.itemsTableView reloadData];
        [self reloadDataForItemsTableView];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *identifier = tableColumn.identifier;
    NSString *value = @"";
    NSTextField *textField;
    NSButton *checkBoxField;

    NSView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    
//    if(!view){
//
//        textField =  [[NSTextField alloc]init];
//
//        textField.identifier = identifier;
//        view = textField ;
//
//    }
//    else{
//
//        //        textField = (NSTextField*)view;
//        NSArray *subviews = [view subviews];
//
//        textField = subviews[0];
//
//
//    }
    
    NSArray *subviews = [view subviews];
    if ([identifier isEqualToString:@"update"]) {
        checkBoxField = subviews[0];
        checkBoxField.tag = row;
        checkBoxField.target = self;
        [checkBoxField setAction:@selector(updateBtnClick:)];
    }else{
        textField = subviews[0];
        textField.wantsLayer=YES;
        [textField setBezeled:NO];
        
        [textField setDrawsBackground:NO];
    }


    if (tableView == self.colorByTableView) {
        if ([identifier isEqualToString:@"index"]) {
            value = [NSString stringWithFormat:@"%ld",row+1];
        }else{
            tableColumn.title = self.colorByBox.stringValue;
            value=[[self.color_datas[row] colorBy2Mode] colorTitle];
        }

    }else if (tableView == self.colorByTableview2) {
        if ([identifier isEqualToString:@"index"]) {
            value = [NSString stringWithFormat:@"%ld",row+1];
        }else{
//            tableColumn.title = self.colorbByBox2.stringValue;
            
           // value=[[self.color_datas2[row] colorBy2Mode] colorTitle];
            value = self.colorTable2_datas[row];
        }
        
    }
    else if (tableView == self.snTableView) {
        
        SnVauleMode *sv_data = self.sn_datas[row];
        sv_data= self.sn_datas[row];
        value=[sv_data getVauleWithKey:identifier];
        if ([identifier isEqualToString:@"index"]) {
            value = [NSString stringWithFormat:@"%ld",row+1];
        }
        else if ([identifier isEqualToString:@"value"]) {
            if ([sv_data.result.uppercaseString isEqualToString:@"PASS"]) {
                textField.layer.backgroundColor = [NSColor greenColor].CGColor;
            }else{
                textField.layer.backgroundColor = [NSColor redColor].CGColor;
            }
        
        }else if ([identifier isEqualToString:@"sn"]) {
            if ([sv_data.totalResult.uppercaseString isEqualToString:@"PASS"]) {
             
                [textField setTextColor:[NSColor blackColor]];
            }else{
                [textField setTextColor:[NSColor redColor]];
            }
        }
 
    }else{
//        NSInteger count = self.itemOriginalDatas.count;
        ItemMode *item_data = self.itemDatas[row];
        if ([identifier isEqualToString:@"index"]) {
            
            if (item_data.dataType == DataTypeNotInsight) {
                textField.layer.backgroundColor = [NSColor grayColor].CGColor;
            }else if (item_data.dataType == DataTypeInsight){
                textField.layer.backgroundColor = [NSColor greenColor].CGColor;
            }else if (item_data.dataType == DataTypeMismatch){
                textField.layer.backgroundColor = [NSColor redColor].CGColor;
            }

//            if (item_data.index >= count-mismatchItemsCount) {
//                //item_data.isMismatch = YES;
//                textField.layer.backgroundColor = [NSColor redColor].CGColor;
//            }else{
//                if (!item_data.isNotInsight) {
//                    textField.layer.backgroundColor = [NSColor greenColor].CGColor;
//                }else{
//
//                    textField.layer.backgroundColor = [NSColor grayColor].CGColor;
//
//                }
//            }
            
        }else if ([identifier isEqualToString:@"Cpk-Orig"]){
            if (item_data.isCpkPass == CpkOrigResultTypeNull) {
               textField.layer.backgroundColor = [NSColor clearColor].CGColor;
            }else{
                //                NSString *str_cpkOrig =item_data.cpkOrig;
                //                float int_cpkOrig = str_cpkOrig.floatValue;
                //                if (int_cpkOrig>10 || int_cpkOrig<1.33) {
                //                    textField.layer.backgroundColor = [NSColor redColor].CGColor;
                //                }else{
                //                    textField.layer.backgroundColor = [NSColor greenColor].CGColor;
                //                }
                
                if (item_data.isCpkPass == CpkOrigResultTypeGreen) {
                    textField.layer.backgroundColor = [NSColor greenColor].CGColor;
                }else if (item_data.isCpkPass == CpkOrigResultTypeRed){
                    textField.layer.backgroundColor = [NSColor redColor].CGColor;
                }else if (item_data.isCpkPass == CpkOrigResultTypeYellow){
                    textField.layer.backgroundColor = [NSColor yellowColor].CGColor;
                }
            }
            
        }

            value=[item_data getVauleWithKey:identifier];
   
    }
    
    
    if ([identifier isEqualToString:@"update"]) {
        NSControlStateValue state =[value isEqualToString:@"1"] ? NSControlStateValueOn :NSControlStateValueOff;
        [checkBoxField setState:state];
        

    }else{
        if(!value.length){
            //更新单元格的文本
            [textField setStringValue:@""];
        }else{
            [textField setStringValue:value];
        }
    }
    
//    if ([identifier isEqualToString:@"value"]) {
//        [textField setTextColor:[NSColor blueColor]];
//        textField.layer.backgroundColor = [NSColor greenColor].CGColor;
//    }
    
    return view;
}


//- （void）tableView：（NSTableView *）tableView didClickedRow：（NSInteger）row {
//    // have fun
//}
//文本输入框变化处理事件
-(void)controlTextDidChange:(NSNotification *)aNotification{
    NSTextField *textF =aNotification.object;
    NSInteger row =self.itemsTableView.selectedRow;
    NSInteger col = [self.itemsTableView columnForView:textF];
    NSString *identifier = self.itemsTableView.tableColumns[col].identifier;
    ItemMode *item_mode = self.itemDatas[row];
    [item_mode setVauleWithKey:identifier value:textF.stringValue];
}


-(void)updateBtnClick:(NSButton *)btn{
    
    NSInteger btn_tag = btn.tag;
    ItemMode *item = self.itemDatas[btn_tag];
    NSInteger state = btn.state;
    item.needUpdate = state;
    [self.itemsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:btn_tag] byExtendingSelection:false];
//    [self.itemsTableView selectedRowIndexes:1];
    NSInteger index = self.itemsTableView.selectedRow;
    
    [self reflesh:self.itemsTableView row:index];
    NSLog(@"1");

}

- (IBAction)click_frist_all_lastSegment:(NSSegmentedControl *)sender {

    
   // NSInteger selectedRow = self.itemsTableView.selectedRow;
    
  //  [self reloadSnVauleTableList:self.itemDatas[selectedRow]];
    
    
//    NSInteger index = self.itemsTableView.selectedRow;
//    if (index <0) {
//        return;
//    }
//
//    [self reflesh:self.itemsTableView row:index];

}


-(void)reloadSnVauleTableList:(ItemMode *)itemMdoe{
    
    if (itemMdoe != nil) {
        
        [self.sn_datas removeAllObjects];
        [self.original_sn_datas removeAllObjects];
        
        NSMutableArray *sn_vauleOriginalArr = itemMdoe.SnVauleArray;
        if (self.frist_all_last_Segment.selectedSegment==0) {//frist
            //
            for (int i=0; i<sn_vauleOriginalArr.count; i++) {
                SnVauleMode*snVauleMode=sn_vauleOriginalArr[i];
                
                NSString *sn = snVauleMode.sn;
                
                BOOL isExistSn = NO;
                for (SnVauleMode*sv_mode in self.sn_datas) {
                    if ([sv_mode.sn isEqualToString:sn]) {
                        isExistSn = YES;
                        break;
                    }
                }
                if (isExistSn) {
                    // [sn_vauleMutArr removeObject:snVauleMode];
                }else{
                    [self.sn_datas addObject:snVauleMode];
                }
                
                //                sn_vauleArr = mutArr;
                // [self.sn_datas addObjectsFromArray:mutArr];
            }
            // sn_vauleArr = [mutSet allObjects];
        }else if (self.frist_all_last_Segment.selectedSegment==1){//last
            //            sn_vauleArr = sn_vauleOriginalArr;
            [self.sn_datas addObjectsFromArray:sn_vauleOriginalArr];
            
        }
        else if (self.frist_all_last_Segment.selectedSegment==2){//last
            
            for (NSInteger i=sn_vauleOriginalArr.count-1; i>=0; i--) {
                SnVauleMode*snVauleMode=sn_vauleOriginalArr[i];
                
                NSString *sn = snVauleMode.sn;
                
                BOOL isExistSn = NO;
                for (SnVauleMode*sv_mode in self.sn_datas) {
                    if ([sv_mode.sn isEqualToString:sn]) {
                        isExistSn = YES;
                        break;
                    }
                }
                if (isExistSn) {
                    // [sn_vauleMutArr removeObject:snVauleMode];
                }else{
                    [self.sn_datas addObject:snVauleMode];
                }
                
                //                sn_vauleArr = mutArr;
                // [self.sn_datas addObjectsFromArray:mutArr];
            }
            
        }
    }
    
    [self.original_sn_datas addObjectsFromArray:self.sn_datas];
    
//    [self clickRemoveItems:self.removeSegment];
    
    [self clickRemoveItemsWithSelectedSegment:self.removeSegment.selectedSegment];
    
}

-(void)reloadDataForItemsTableView{
    
    [self.itemsTableView reloadData];
    if (self.itemDatas.count) {
        [self.itemsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:false];
    }
    
    
}

- (IBAction)searchAction:(NSSearchField *)sender {
    
    NSString *content = sender.stringValue;
    
    if (!content.length) {
        if (self.lasItemDatas.count) {
            self.itemDatas = self.lasItemDatas;
        }else{
            self.itemDatas = self.itemOriginalDatas;
        }
        
//        [self.itemsTableView reloadData];
        [self reloadDataForItemsTableView];
        return;
    }
    
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    for (int i =0; i<self.itemDatas.count; i++) {
        ItemMode *mode = self.itemDatas[i];
        NSString *item_name = mode.item;
        if ([item_name.lowercaseString containsString:content.lowercaseString]) {
            [mutArr addObject:mode];
        }
    }
    self.itemDatas = mutArr;
//    self.lasItemDatas = mutArr;
//    [self.itemsTableView reloadData];
    [self reloadDataForItemsTableView];
    [self search_filter:content];
    
}


-(void)search_filter:(NSString *)content{
    

    
}


- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
   
    BOOL b = _isRunPython ? NO : YES;
    return b;
}


-(void)tableViewKeyMove:(NSTableView *)tableView{
    if (tableView != self.itemsTableView) {
        return;
    }
    NSInteger index = self.itemsTableView.selectedRow;
    if (index <0) {
        return;
    }
    
    [self reflesh:tableView row:index];
    
}

-(void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row location:(NSPoint)location{
//    if (tableView != self.itemsTableView) {
//        return;
//    }
    NSInteger index = tableView.selectedRow;
    if (row != index) {
        return;
    }

    if (tableView == self.itemsTableView) {
        
//        if (location.x > 873 &&location.x<1050) {
//            return;
//        }
        
    }else if (tableView == self.colorByTableView){
        
        [self reloadColorBy2TableView];
      
    }

    
    [self reflesh:tableView row:index];
    
//    if (_isRunPython) {
//        return;
//    }
//
//    if (!self.itemDatas.count) {
//        return;
//    }
//
////    NSTableView *tableView = notification.object;
//
//
//    if (tableView == self.itemsTableView || tableView == self.colorByTableView) {
//
//        if (self.itemDatas.count) {
//            ItemMode *itemM = self.itemDatas[index];
//
//            if ([itemM.low isEqualToString:itemM.upper]) {
//                NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
//                [self setPicture:pic_path];
//                [self reloadSnVauleTableList:itemM];
//                return;
//            }
////            if (tableView == self.itemsTableView) {
////                [self reloadSnVauleTableList:itemM];
////            }
//             [self reloadSnVauleTableList:itemM];
//            [self runPython:@"one_item_plot"];
//
//        }
//
//    }
}

-(void)reflesh:(NSTableView *)tableView row:(NSInteger)row{
    row = self.itemsTableView.selectedRow;
    if (_isRunPython || !self.itemDatas.count || row<0) {
        return;
    }
    
    if (tableView == self.itemsTableView || tableView == self.colorByTableView || tableView == self.colorByTableview2) {
        
        if (self.itemDatas.count) {
            
            ItemMode *itemM = self.itemDatas[row];
//            if ((itemM.low.integerValue==0&&itemM.upper.integerValue ==0)||(itemM.low.integerValue==1&&itemM.upper.integerValue ==1)) {
//                
//                NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
//                [self setPicture:pic_path];
//                [self reloadSnVauleTableList:itemM];
//                return;
//                
//            }
            
            //            if (tableView == self.itemsTableView) {
            //                [self reloadSnVauleTableList:itemM];
            //            }
            [self reloadSnVauleTableList:itemM];
            [self runPython:[ReportMode defaultOneItemReportMode]];
            
        }
        
    }
}


//- (void)tableViewSelectionDidChange:(NSNotification *)notification{
//    if (_isRunPython) {
//        return;
//    }
//
//    if (!self.itemDatas.count) {
//        return;
//    }
//
//    NSTableView *tableView = notification.object;
//
//    NSInteger index = self.itemsTableView.selectedRow;
//    if (tableView == self.itemsTableView || tableView == self.colorByTableView) {
//
//        if (self.itemDatas.count) {
//            ItemMode *itemM = self.itemDatas[index];
//
//            if ([itemM.low isEqualToString:itemM.upper]) {
//                NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
//                [self setPicture:pic_path];
//                [self reloadSnVauleTableList:itemM];
//                return;
//            }
//            if (tableView == self.itemsTableView) {
//                [self reloadSnVauleTableList:itemM];
//            }
//
//            [self runPython:@"one_item_plot"];
//
//        }
//
//    }
//}



- (IBAction)clickRemoveItems:(NSSegmentedControl *)sender {
    
    if (_isRunPython) {
        return;
    }
    
    if (sender.selectedSegment == 0) {//remove fail items
        if (!self.original_sn_datas.count) {
            [self.snTableView reloadData];
            return;
        }
        [self.sn_datas removeAllObjects];
        for (int i =0 ; i<self.original_sn_datas.count; i++) {
            SnVauleMode *sv = self.original_sn_datas[i];
            if ([sv.totalResult.uppercaseString isEqualToString:@"PASS"]) {
//                [self.sn_datas removeObject:sv];
                [self.sn_datas addObject:sv];
            }
        }
        
    }else{
        self.sn_datas = [[NSMutableArray alloc]initWithArray:self.original_sn_datas];
    }
    
  //  [self.snTableView reloadData];
    
    NSInteger index = self.itemsTableView.selectedRow;
    if (index <0) {
        return;
    }

    [self reflesh:self.itemsTableView row:index];
    
}

-(void)clickRemoveItemsWithSelectedSegment:(NSInteger)selectedSegment{
    if (selectedSegment == 0) {//remove fail items
        if (!self.original_sn_datas.count) {
            [self.snTableView reloadData];
            return;
        }
        [self.sn_datas removeAllObjects];
        for (int i =0 ; i<self.original_sn_datas.count; i++) {
            SnVauleMode *sv = self.original_sn_datas[i];
            if ([sv.totalResult.uppercaseString isEqualToString:@"PASS"]) {
                //                [self.sn_datas removeObject:sv];
                [self.sn_datas addObject:sv];
            }
        }
        
    }else{
        self.sn_datas = [[NSMutableArray alloc]initWithArray:self.original_sn_datas];
    }
    
    //  [self.snTableView reloadData];
    
//    NSInteger index = self.itemsTableView.selectedRow;
//    if (index <0) {
//        return;
//    }
//
//    [self reflesh:self.itemsTableView row:index];
    
}



- (IBAction)clickLimitData:(NSSegmentedControl *)sender {
    NSInteger index = self.itemsTableView.selectedRow;
    if (index <0) {
        return;
    }

    [self reflesh:self.itemsTableView row:index];
}

-(void)deletePic{
 
    NSString *pic_path1=[NSString stringWithFormat:@"%@/temp_pic.png",_temp_logPath];
    NSString *pic_path2 =[NSString stringWithFormat:@"%@/correlation.png",_temp_logPath];
    if ([CWFileManager cw_isFileExistAtPath:pic_path1]) {
        [CWFileManager cw_removeItemAtPath:pic_path1];
        
    }
    
    if ([CWFileManager cw_isFileExistAtPath:pic_path2]) {
        
        [CWFileManager cw_removeItemAtPath:pic_path2];
    }

}




-(void)setPicture:(NSString *)pic_path1 pic_path2:(NSString *)pic_path2{
    
    if ([CWFileManager cw_isFileExistAtPath:pic_path1]) {
        NSImage *image1 = [[NSImage alloc]initWithContentsOfFile:pic_path1];
//        NSImage *image2 = [[NSImage alloc]initWithContentsOfFile:pic_path2];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView setImage:image1];
//                [self.correlationView setImage:image2];
                
            });
//        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
           
            NSImage *image1 = [[NSImage alloc]initWithContentsOfFile:pic_path];
//            NSImage *image2 = [[NSImage alloc]initWithContentsOfFile:pic_path];
            [self.mapView setImage:image1];
//            [self.correlationView setImage:image2];
            
        });
    }
    
    if ([CWFileManager cw_isFileExistAtPath:pic_path2]) {
        NSImage *image2 = [[NSImage alloc]initWithContentsOfFile:pic_path2];
        //        NSImage *image2 = [[NSImage alloc]initWithContentsOfFile:pic_path2];
        //        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
     
                [self.correlationView setImage:image2];
            
        });
        //        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *pic_path =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
            
            NSImage *image2 = [[NSImage alloc]initWithContentsOfFile:pic_path];
            //            NSImage *image2 = [[NSImage alloc]initWithContentsOfFile:pic_path];
    
            [self.correlationView setImage:image2];
            
        });
    }
}

-(void)setPicture:(NSString *)pic_path{
    [self setPicture:pic_path pic_path2:pic_path];
}

//-(void)set

-(void)initTableList{
    self.itemDatas = [[NSMutableArray alloc]init];
    self.sn_datas =[[NSMutableArray alloc]init];
    
    for (int i =0; i<5; i++) {
        ItemMode *mode = [[ItemMode alloc]init];
        mode.item= [NSString stringWithFormat:@"item_%d",i];
        mode.upper = [NSString stringWithFormat:@"%d",i+5];
        mode.low = [NSString stringWithFormat:@"%d",i-5];
        [self.itemDatas addObject:mode];
    }
    
    for (int i =0; i<5; i++) {
        SnVauleMode *mode = [[SnVauleMode alloc]init];
        mode.sn= [NSString stringWithFormat:@"sn_%d",i];
        mode.value = [NSString stringWithFormat:@"%d",i+5];
        [self.sn_datas addObject:mode];
    }
    
    [self initTableView:self.snTableView];
    [self initTableView:self.itemsTableView];
}
-(NSInteger)getStationChannelIdIndex:(NSArray *)titles{
    NSInteger __block index = -1;
    [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *obj_str;
        if ([obj isKindOfClass:[NSString class]]) {
            obj_str = (NSString *)obj;
            
        }else if ([obj isKindOfClass:[NSMutableDictionary class]]){
            obj_str = [obj objectForKey:@"name"];;
        }
        
        if ([obj_str.uppercaseString isEqualToString:@"FIXTURE CHANNEL ID"]||[obj_str.uppercaseString isEqualToString:@"FIXTURE INITILIZATION SLOT_ID"]||[obj_str.uppercaseString isEqualToString:@"FIXTURE RESET CALC FIXTURE_CHANNEL"]||[obj_str.uppercaseString isEqualToString:@"HEAD ID"]) {
            index = idx;
            *stop = YES;
            
        }

    }];
    return index;
}

-(BOOL)generateItemsTableListDatas:(NSMutableArray *)mutArray csvPath:(NSString *)csvPath isLoadScript:(BOOL)isLoadScript{
    
//          mismatchItemsCount =0;
   // Parametric

    NSArray *titles_arr = mutArray[1];
    if (titles_arr.count<13 || _index_parametric<12) {
        [MyEexception RemindException:@"Error" Information:@"worng data"];
        return NO;
    }
    
    channel_id_index= [self getStationChannelIdIndex:titles_arr];
//    if (channel_id_index<0) {
//
//        [MyEexception RemindException:@"Error" Information:@"not found Fixture Channel id"];
//
//        return NO;
//    }
    NSMutableArray *calArr = [self get_calculateArrWithCsvPath:csvPath isLoadScript:isLoadScript];
    NSArray *upper_arr = mutArray[4];
    NSArray *low_arr = mutArray[5];
    
//    NSDate *date =[NSDate date];
    NSMutableArray *item_mode_arr = [[NSMutableArray alloc]init];
//

    for (int i=0; i<titles_arr.count; i++) {
        if (i<_index_parametric) {
            continue;
        }
        ItemMode *item_mode = [[ItemMode alloc]init];
        id item_desc= titles_arr[i];
        if ([item_desc isKindOfClass:[NSMutableDictionary class]]) {
            item_mode.item = [item_desc objectForKey:@"name"];
            item_mode.desc=[item_desc objectForKey:@"desc"];
        }else{
            item_mode.item = titles_arr[i];
            item_mode.desc=@"";
        }

        item_mode.cpkOrig = @"Null";
        item_mode.low = low_arr[i];
        item_mode.upper = upper_arr[i];
        item_mode.index=i-_index_parametric;
//        item_mode.isNotInsight = isLoadScript ? YES :NO;
        if (isLoadScript) {
            
            if (self.itemOriginalDatas.count) {
                __block  BOOL isFound = NO;
                [self.itemOriginalDatas enumerateObjectsUsingBlock:^(ItemMode *csvItemM, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([csvItemM.item isEqualToString:item_mode.item]) {
                        item_mode.dataType = DataTypeInsight;
                        
                        isFound = YES;
                        *stop = YES;
                    }
                }];
                
                if (!isFound) {
//                    item_mode.isNotInsight = YES;
                    item_mode.dataType = DataTypeNotInsight;
                }
            
            }
        }else{
             item_mode.dataType = DataTypeInsight;
        }

        
        if (calArr.count>=2) {
            [calArr enumerateObjectsUsingBlock:^(NSMutableArray *subArr, NSUInteger idx, BOOL * _Nonnull stop) {

                NSString *cal_item = subArr[0];
                if ([cal_item isEqualToString:item_mode.item]) {

                    NSString *cpk_orig =subArr[6];
                    if (cpk_orig.length) {
//                        item_mode.cpkOrig = cpk_orig;
                        [item_mode setCpkOrig:cpk_orig low:_cpkLTHL high:_cpkHTHL];
                    }
//                    item_mode.pVal =subArr[2];
//                    item_mode.aQ = subArr[3];
//                    item_mode.aIrr =subArr[4];
//                    item_mode.threeDivideMean = subArr[5];

                    *stop = YES;
                }
            }];
        }

        NSInteger cout = [mutArray[0] count];
        NSInteger empty_vaule_count = 0;
        
        for (int j =0; j<mutArray.count; j++) {
   
            NSArray *arr = mutArray[j];
            if (j<7 || cout != arr.count) {
                continue;
            }
            NSInteger index_site = [titles_arr indexOfObject:title_site];
            NSString *site = arr[index_site];
            NSInteger index_product = [titles_arr indexOfObject:title_product];
            NSString *product = arr[index_product];
            
            NSInteger index_sn = [titles_arr indexOfObject:title_sn];
            NSString *sn = arr[index_sn];
            
            NSInteger index_specialBuildName = [titles_arr indexOfObject:title_specialBN];
            NSString *specialBuildName = arr[index_specialBuildName];
            
            NSInteger index_specialBuildDes = [titles_arr indexOfObject:title_specialBD];
            NSString *specialBuildDes = arr[index_specialBuildDes];
            
            NSInteger index_unitNum = [titles_arr indexOfObject:title_unitN];
            NSString *unitNum = arr[index_unitNum];
            
            NSInteger index_stationId = [titles_arr indexOfObject:title_stationId];
            NSString *stationId = arr[index_stationId];
            
            NSInteger index_total_result = [titles_arr indexOfObject:title_totalResult];
            NSString *total_result = arr[index_total_result];
            
            NSInteger index_startTime = [titles_arr indexOfObject:title_startTime];
            NSString *startTime = arr[index_startTime];
            
            NSInteger index_endTime = [titles_arr indexOfObject:title_endTime];
            NSString *endTime = arr[index_endTime];
            
            NSInteger index_version = [titles_arr indexOfObject:title_version];
            NSString *version = arr[index_version];
            
            NSInteger index_listFailTest = [titles_arr indexOfObject:title_listFailTests];
            NSString *listFailTest = arr[index_listFailTest];
            
            NSInteger index_diagsVersion = 0;
            NSString *diagsVersion =@"";
            if ([titles_arr containsObject:title_diagsVersion]) {
                 index_diagsVersion = [titles_arr indexOfObject:title_diagsVersion];
                 diagsVersion =arr[index_diagsVersion];
            }
           
            
//            NSString *channel_id = @"";
            NSString *channel_id = [self getChannelID:arr indexOfChannel:channel_id_index];
//            if (channel_id_index) {
//                channel_id = arr[channel_id_index];
//            }
            
            if (!sn.length) {
                continue;
            }

            SnVauleMode *sv = [[SnVauleMode alloc] init];
            
            sv.sn = sn;
            sv.value = arr[i];
            
//            if ([sn isEqualToString:@"FN602530Y3HMPKD61"]) {
//                NSInteger len = sv.value.length;
//                NSLog(@"1");
//
//            }
            if (!sv.value.length) {
                empty_vaule_count = empty_vaule_count+1;
            }else{
                if (sv.value.length>40) {
                    empty_vaule_count = empty_vaule_count+1;
                }
                
            }
            
            sv.low = item_mode.low;
            sv.index = j-6;
            sv.upper = item_mode.upper;
          
            sv.site = site;
            sv.product = product;
            sv.specialBuildName = specialBuildName;
            sv.specialBuildDescription = specialBuildDes;
            sv.unitNumber = unitNum;
            sv.stationId = stationId;
            sv.totalResult =total_result;
            sv.startTime = startTime;
            sv.endTime = endTime;
            sv.version = version;
            sv.listOfFailingTests = listFailTest;
           // sv.stationFxitureChannelId = [NSString stringWithFormat:@"%@_%@",stationId,channel_id];
            sv.stationFxitureChannelId = channel_id;
            sv.diagsVersion = diagsVersion;
            [item_mode.SnVauleArray addObject:sv];
       
            
        }
        
        [item_mode_arr addObject:item_mode];
 
     
    }
    
    [self initAllDatas];

    if (mismatchItemsCount && isLoadScript) {
        for (int z=0; z<item_mode_arr.count; z++) {
            
            if (z==item_mode_arr.count-1) {
                NSLog(@"1");
            }
            if (z >= item_mode_arr.count-mismatchItemsCount) {
                ItemMode *item_mode = item_mode_arr[z];
                item_mode.dataType = DataTypeMismatch;
            }
            
        }
    }

    [self.itemDatas addObjectsFromArray:item_mode_arr];
    [self.itemOriginalDatas addObjectsFromArray:item_mode_arr];
    
    [self reloadDataForItemsTableView];
  
    return YES;

}

-(NSString *)getChannelID:(NSArray *)arr indexOfChannel:(NSInteger)index_channel{
    NSString *channel_id = @"";
    if (index_channel>0) {
        channel_id = arr[index_channel];
    }
    return channel_id;
}

//static NSString * const title_site = @"Site";
//static NSString * const title_product = @"Product";
//static NSString * const title_sn = @"SerialNumber";
//static NSString * const title_specialBN = @"Special Build Name";
//
//static NSString * const title_specialBD = @"Special Build Description";
//static NSString * const title_unitN = @"Unit Number";
//static NSString * const title_stationId = @"Station ID";
//static NSString * const title_totalResult = @"Test Pass/Fail Status";
//
//
//static NSString * const title_startTime = @"StartTime";
//static NSString * const title_endTime = @"EndTime";
//static NSString * const title_version = @"Version";
//static NSString * const title_listFailTests = @"List of Failing Tests";
//
//static NSString * const title_diagsVersion = @"Diags_Version";


-(BOOL)isContainColorByTitle:(NSString *)title{
    BOOL isContain = NO;
//    if ([title.lowercaseString containsString:@"serialnumber"]) {
//        isContain = YES;
//    }else
        if ([title.lowercaseString isEqualToString:@"version"]){
        isContain = YES;
    }else if ([title.lowercaseString containsString:@"station id"]){
        isContain = YES;
    }else if ([title.lowercaseString containsString:@"product"]){
        isContain = YES;
    }else if ([title.lowercaseString containsString:@"special build name"]){
        isContain = YES;
    }else if ([title.uppercaseString isEqualToString:@"FIXTURE CHANNEL ID"]||[title.uppercaseString isEqualToString:@"FIXTURE INITILIZATION SLOT_ID"]||[title.uppercaseString isEqualToString:@"FIXTURE RESET CALC FIXTURE_CHANNEL"]||[title.uppercaseString isEqualToString:@"HEAD ID"]){
        isContain = YES;
    }else if ([title.lowercaseString containsString:@"diags"]&&[title.lowercaseString containsString:@"version"]){
        isContain = YES;
    }
    return isContain;
}


-(NSInteger)getIndexOfTitleWithTitlesArr:(NSArray *)titlesArr title:(NSString *)title{
    
    for (NSInteger i =0; i<_index_parametric; i++) {
        NSString * title_low =[titlesArr[i] lowercaseString];
        if ([title_low isEqualToString:title.lowercaseString]) {
            return i;
        }
    }
    return 0;
}

-(NSString *)getDiagsVersionVaule:(NSArray *)arr index_diagsVersion:(NSInteger)index_diagsVersion{
    if (index_diagsVersion ==0) {
        return @"";
    }else{
        NSString *vaule = arr[index_diagsVersion];
        return vaule;
    }
}

-(void)generateColor2TableListDatas:(NSMutableArray *)mutArray{
    if (!self.color_dicDatas.count) {
        return;
    }
    
    
    NSInteger index_version =[self getIndexOfTitleWithTitlesArr:mutArray[1] title:title_version];
    NSInteger index_station_id =[self getIndexOfTitleWithTitlesArr:mutArray[1] title:title_stationId];
    
    NSInteger index_specialBN =[self getIndexOfTitleWithTitlesArr:mutArray[1] title:title_specialBN];
    NSInteger index_product =[self getIndexOfTitleWithTitlesArr:mutArray[1] title:title_product];
    NSInteger index_diagsVersion =[self getIndexOfTitleWithTitlesArr:mutArray[1] title:title_diagsVersion];
    for (NSString *title in self.color_dicDatas.allKeys) {
        
        NSArray *colorByModeArr = self.color_dicDatas[title];
        for (int i =0; i<colorByModeArr.count; i++) {
            ColorBy2Mode *mode2 = [colorByModeArr[i] colorBy2Mode];
            NSString *colorTitle = mode2.colorTitle;
            for (int i=0; i<mutArray.count;i++) {
                if (i<7) {
                    continue;
                }
                NSArray *arr = mutArray[i];
                NSString *string = @"";
               // NSString *versionStr =arr[10];
                
                if ([title.lowercaseString isEqualToString:@"version"]) {
                    string = arr[index_version];
                }else if ([title.lowercaseString containsString:@"station id"]){
                    string = arr[index_station_id];
                }else if ([title.lowercaseString containsString:@"special build name"]){
                    string = arr[index_specialBN];
                }else if ([title.lowercaseString containsString:@"channel"]&&[title.lowercaseString containsString:@"id"]&&[title.lowercaseString containsString:@"fixture"]){
                    string = [self getChannelID:arr indexOfChannel:channel_id_index];
                }else if ([title.lowercaseString containsString:@"product"]){
                    string = arr[index_product];
                }else if ([title.lowercaseString containsString:@"diags"]&&[title.lowercaseString containsString:@"version"]){
                    string = @"";
                    if (index_diagsVersion) {
                        
                        string = arr[index_diagsVersion];

                    }
                }
                
                if (![string isEqualToString:colorTitle]) {
                    continue;
                }
                
                if ([title.lowercaseString isEqualToString:@"version"]) {
                    [mode2.productArray addObject:arr[index_product]];
                    [mode2.stationIDArr addObject:arr[index_station_id]];
                    [mode2.specialBuildNameArr addObject:arr[index_specialBN]];
                    [mode2.channelIDArray addObject:[self getChannelID:arr indexOfChannel:channel_id_index]];
                    [mode2.diagsVersionArr addObject:[self getDiagsVersionVaule:arr index_diagsVersion:index_diagsVersion]];
                    
                }else if ([title.lowercaseString containsString:@"station id"]){
                    [mode2.productArray addObject:arr[index_product]];
                    [mode2.versionArray addObject:arr[index_version]];
                    [mode2.specialBuildNameArr addObject:arr[index_specialBN]];
                    [mode2.channelIDArray addObject:[self getChannelID:arr indexOfChannel:channel_id_index]];
                    [mode2.diagsVersionArr addObject:[self getDiagsVersionVaule:arr index_diagsVersion:index_diagsVersion]];
                }else if ([title.lowercaseString containsString:@"special build name"]){
                    [mode2.productArray addObject:arr[index_product]];
                    [mode2.versionArray addObject:arr[index_version]];
                    [mode2.stationIDArr addObject:arr[index_station_id]];
                    [mode2.diagsVersionArr addObject:[self getDiagsVersionVaule:arr index_diagsVersion:index_diagsVersion]];
                    [mode2.channelIDArray addObject:[self getChannelID:arr indexOfChannel:channel_id_index]];
                }else if ([title.lowercaseString containsString:@"channel"]&&[title.lowercaseString containsString:@"id"]&&[title.lowercaseString containsString:@"fixture"]){
                    [mode2.productArray addObject:arr[index_product]];
                    [mode2.versionArray addObject:arr[index_version]];
                    [mode2.stationIDArr addObject:arr[index_station_id]];
                    [mode2.specialBuildNameArr addObject:arr[index_specialBN]];
                    [mode2.diagsVersionArr addObject:[self getDiagsVersionVaule:arr index_diagsVersion:index_diagsVersion]];
           
                }else if ([title.lowercaseString containsString:@"product"]){
                    [mode2.specialBuildNameArr addObject:arr[index_specialBN]];
                    [mode2.versionArray addObject:arr[index_version]];
                    [mode2.stationIDArr addObject:arr[index_station_id]];
                    [mode2.channelIDArray addObject:[self getChannelID:arr indexOfChannel:channel_id_index]];
                    [mode2.diagsVersionArr addObject:[self getDiagsVersionVaule:arr index_diagsVersion:index_diagsVersion]];
                }else if ([title.lowercaseString containsString:@"diags"] &&[title.lowercaseString containsString:@"version"]){
                    [mode2.specialBuildNameArr addObject:arr[index_specialBN]];
                    [mode2.versionArray addObject:arr[index_version]];
                    [mode2.stationIDArr addObject:arr[index_station_id]];
                    [mode2.channelIDArray addObject:[self getChannelID:arr indexOfChannel:channel_id_index]];
                    [mode2.productArray addObject:arr[index_product]];
                }
            }
        }
    
    }
    
}

-(void)generateColorTableListDatas:(NSMutableArray *)mutArray{
    if (!self.itemOriginalDatas.count) {return;}
    NSArray *titles_arr = mutArray[1];
    [self.color_dicDatas removeAllObjects];
    for (int i=0; i<titles_arr.count; i++) {
        
        id title_id = titles_arr[i];
        NSString *title =@"";
        if ([title_id isKindOfClass:[NSMutableDictionary class]]) {
            title = [title_id objectForKey:@"name"];
        }else if([title_id isKindOfClass:[NSString class]]){
            title = title_id;
        }


        if (i>=_index_parametric) {
            if (channel_id_index>_index_parametric) {
                if (i==channel_id_index) {
                    if ([title containsString:@"_"]) {
                        title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    }
                    
                }else{
                    continue;
                }
            }else{
                continue;
            }
        }
        
   
        
        if (![self isContainColorByTitle:title]) {
            continue;
        }
        
        // [self.colorByBox addItemsWithObjectValues:@[@"Off",@"SerialNumber",@"Version",@"Station ID",@"Special Build Name"]];
//
//        __block ItemMode *  itemM = nil;
//        [self.itemOriginalDatas enumerateObjectsUsingBlock:^(ItemMode * obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (!obj.isNotInsight) {
//                itemM = obj;
//                *stop = YES;
//            }
//        }];
        ItemMode *itemM = self.itemOriginalDatas[0];
        NSMutableArray *colorByModeMutArr = [[NSMutableArray alloc]init];
        for (int m = 0; m<itemM.SnVauleArray.count; m++) {
            SnVauleMode *sv_mode = itemM.SnVauleArray[m];
//            if (!sv_mode.value.length) {
//                continue;
//            }
            ColorByMode *colorByMode = [[ColorByMode alloc]init];
            ////@"SerialNumber",@"Version",@"Station ID",@"Special Build Name"
 
            colorByMode.colorBy2Mode.colorTitle = [colorByMode getVauleWithKey:title snVauleMode:sv_mode];
            
            colorByMode.result = sv_mode.result;
            
            [colorByModeMutArr addObject:colorByMode];
        }
        
        NSMutableArray *mutArr = [[NSMutableArray alloc]init];
        NSMutableArray *colorByModeOriginalArr = [[NSMutableArray alloc]initWithArray:colorByModeMutArr];
//        [mutArr removeAllObjects];
        for (int j=0; j<colorByModeOriginalArr.count; j++) {
            ColorByMode*colorByM=colorByModeOriginalArr[j];
            
            NSString *title1 = colorByM.colorBy2Mode.colorTitle;
            
            BOOL isExistSn = NO;
            
            for (ColorByMode*mutColorByM in mutArr) {
                if ([mutColorByM.colorBy2Mode.colorTitle isEqualToString:title1]) {//@"CWNJ_C02-2FAP-23_2_FCT"
                    isExistSn = YES;
                    break;
                }
            }
            if (isExistSn) {
                [colorByModeMutArr removeObject:colorByM];
            }else{
                
                if (!colorByM.colorBy2Mode.colorTitle.length) {
                    colorByM.needDelete = YES;
                }else{
                    int repetitionCount = 0;
                    for (ColorByMode*mutColorByM in mutArr) {
                        if ([colorByM.colorBy2Mode.colorTitle isEqualToString:mutColorByM.colorBy2Mode.colorTitle]) {
                            repetitionCount = repetitionCount +1;
                            if (repetitionCount>3) {
                                colorByM.needDelete = YES;
                                break;
                            }
                        }
                    }
                }
                
               
                [mutArr addObject:colorByM];
                
            }
        }
        
        [colorByModeMutArr enumerateObjectsUsingBlock:^(ColorByMode * colorByM, NSUInteger idx, BOOL * _Nonnull stop) {
            if (colorByM.needDelete) {
                [colorByModeMutArr removeObject:colorByM];
            }
        }];


      
        if ([title.uppercaseString isEqualToString:@"FIXTURE CHANNEL ID"]||[title.uppercaseString isEqualToString:@"FIXTURE INITILIZATION SLOT_ID"]||[title.uppercaseString isEqualToString:@"FIXTURE RESET CALC FIXTURE_CHANNEL"]||[title.uppercaseString isEqualToString:@"HEAD ID"]) {
            //            index = idx;
            
            [self.color_dicDatas setValue:colorByModeMutArr forKey:@"Fixture Channel ID"];
        }else{
           [self.color_dicDatas setValue:colorByModeMutArr forKey:title];
        }
        
  
    }

    [self.colorByBox selectItemAtIndex:0];
    [self reloadColorDatas:self.colorByBox];
    [self.colorbByBox2 selectItemAtIndex:0];
    [self reloadColorDatas:self.colorbByBox2];
}

-(void)appendCsvString:(NSString *)str text:(NSMutableString *)text{
    if (!str.length) {
        str = @"";
    }
    [text appendString:str];
    [text appendString:@","];
}

-(NSMutableArray *)getChangeDatas:(ItemMode *)itemMdoe{
    NSMutableArray *sn_vauleOriginalArr = itemMdoe.SnVauleArray;
    NSMutableArray *sn_vauleNewArr = [[NSMutableArray alloc]init];
    
    if (self.frist_all_last_Segment.selectedSegment==0) {//frist
        //
        for (int i=0; i<sn_vauleOriginalArr.count; i++) {
            SnVauleMode*snVauleMode=sn_vauleOriginalArr[i];
            
            NSString *sn = snVauleMode.sn;
            
            BOOL isExistSn = NO;
            for (SnVauleMode*sv_mode in sn_vauleNewArr) {
                if ([sv_mode.sn isEqualToString:sn]) {
                    isExistSn = YES;
                    break;
                }
            }
            if (isExistSn) {
                // [sn_vauleMutArr removeObject:snVauleMode];
            }else{
                [sn_vauleNewArr addObject:snVauleMode];
            }
            
            //                sn_vauleArr = mutArr;
            // [self.sn_datas addObjectsFromArray:mutArr];
        }
        // sn_vauleArr = [mutSet allObjects];
    }else if (self.frist_all_last_Segment.selectedSegment==1){//last
        //            sn_vauleArr = sn_vauleOriginalArr;
        [sn_vauleNewArr addObjectsFromArray:sn_vauleOriginalArr];
        
    }
    else if (self.frist_all_last_Segment.selectedSegment==2){//last
        
        for (NSInteger i=sn_vauleOriginalArr.count-1; i>=0; i--) {
            SnVauleMode*snVauleMode=sn_vauleOriginalArr[i];
            
            NSString *sn = snVauleMode.sn;
            
            BOOL isExistSn = NO;
            for (SnVauleMode*sv_mode in sn_vauleNewArr) {
                if ([sv_mode.sn isEqualToString:sn]) {
                    isExistSn = YES;
                    break;
                }
            }
            if (isExistSn) {
                // [sn_vauleMutArr removeObject:snVauleMode];
            }else{
                [sn_vauleNewArr addObject:snVauleMode];
            }
        
        }
        
    }
    
    NSMutableArray *remove_fail_new_datas = [self getRemoveFailDtas:sn_vauleNewArr];
    return remove_fail_new_datas;
    
}


-(NSMutableArray *)getRemoveFailDtas:(NSMutableArray *)original_datas{
    NSMutableArray *new_datas = [[NSMutableArray alloc] init];
    if (self.removeSegment.selectedSegment == 0) {//remove fail items

        for (int i =0 ; i<original_datas.count; i++) {
            SnVauleMode *sv = original_datas[i];
            if ([sv.totalResult.uppercaseString isEqualToString:@"PASS"]) {
                //                [self.sn_datas removeObject:sv];
                [new_datas addObject:sv];
            }
        }
        
    }else{
        new_datas = [[NSMutableArray alloc]initWithArray:original_datas];
    }
    
    return new_datas;
    
    //  [self.snTableView reloadData];
}




-(void)generateItemCsvListWithItemMode:(ItemMode *)itemMode{
//    if (!self.original_sn_datas.count) {
//        return;
//    }
    
    if (!_isSelectX) {
        _isSelectX = YES;
        self.last_itemM = itemMode;
    }
    

    
    NSString *title1 = [NSString stringWithFormat:@"Site,Product,SerialNumber,Special Build Name,Special Build Description,Unit Number,Station ID,Test Pass/Fail Status,StartTime,EndTime,Version,List of Failing Tests,%@,%@,Fixture Channel ID,Diags_Version\n",itemMode.item,self.last_itemM.item];
        NSString *title2 = [NSString stringWithFormat:@"Upper Limit ----->,,,,,,,,,,,,%@,%@\n",itemMode.upper,self.last_itemM.upper];
    NSString *title3 = [NSString stringWithFormat:@"Low Limit ----->,,,,,,,,,,,,%@,%@\n",itemMode.low,self.last_itemM.low];
    NSMutableString *text = [[NSMutableString alloc] initWithString:title1];
    [text appendString:title2];
        [text appendString:title3];
//    NSMutableArray *lastItemSnVauleArr = [[NSMutableArray alloc]initWithArray:self.last_itemM.SnVauleArray];
   
    if (itemMode.SnVauleArray.count != self.last_itemM.SnVauleArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MyEexception RemindException:@"Error" Information:@"one_item.csv item count mismatch"];
        });
        
    }
    NSMutableArray *y_SnVauleArray =itemMode.SnVauleArray;
    NSMutableArray *x_SnVauleArray =self.last_itemM.SnVauleArray;
    for (int i=0; i<y_SnVauleArray.count; i++) {
 
        SnVauleMode *mode = y_SnVauleArray[i];
        SnVauleMode *x_mode =x_SnVauleArray[i];
        
        if (![x_mode.sn isEqualToString:mode.sn]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MyEexception RemindException:@"Error" Information:@"one_item.csv item sn mismatch"];
            });}
//        [lastItemSnVauleArr enumerateObjectsUsingBlock:^(SnVauleMode *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//            if ([obj.sn isEqualToString:mode.sn]) {
//                x_mode = obj;
//                *stop = YES;
//            }
//        }];

//        if (x_mode == nil) {
//            continue;
//        }
        
        [self appendCsvString:mode.site text:text];
        [self appendCsvString:mode.product text:text];
        [self appendCsvString:mode.sn text:text];
        [self appendCsvString:mode.specialBuildName text:text];
        [self appendCsvString:mode.specialBuildDescription text:text];
        [self appendCsvString:mode.unitNumber text:text];
        
        [self appendCsvString:mode.stationId text:text];
        [self appendCsvString:mode.totalResult text:text];
        [self appendCsvString:mode.startTime text:text];
        [self appendCsvString:mode.endTime text:text];
        [self appendCsvString:mode.version text:text];
        [self appendCsvString:mode.listOfFailingTests text:text];
        [self appendCsvString:mode.value text:text];
        [self appendCsvString:x_mode.value text:text];
//        [text appendString:mode.stationFxitureChannelId];
        [self appendCsvString:mode.stationFxitureChannelId text:text];
        //        [text appendString:mode.stationFxitureChannelId];
        [text appendString:mode.diagsVersion];
        [text appendFormat:@"\n"];
        //debug
    }
    NSString *path = [_temp_logPath stringByAppendingPathComponent:@"one_item.csv"];
    
    NSError *error;
    [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];

    if(error){
        NSLog(@"save file error %@",error);

        dispatch_async(dispatch_get_main_queue(), ^{
                    [MyEexception RemindException:@"Save Item List Fail" Information:[NSString stringWithFormat:@"Error Info:%@",error]];
        });

    }else{
//        [MyEexception RemindException:@"Save Success" Information:[NSString stringWithFormat:@"File Path:%@",path]];
    }
}

-(void)runPython:(ReportMode *)reportMode{
//    return;
//    [self appenLog:@"runPython start"];
    //excel-report  //keynote-report   one_item_plot
    
    [self deletePic];
    
    NSString *event = reportMode.reportTypeString;
    NSString * cpk_lsl = reportMode.lsl;
    NSString * cpk_usl = reportMode.usl;
    NSString * bins = self.binsTextF.stringValue;
    NSString *excel_item = reportMode.exportType;
    NSString *fail_plot_to_excel = reportMode.generatePlot;
    NSString *excel_report_user =reportMode.user;
    NSString *excel_report_stage = reportMode.build;
    NSString *excel_report_project = reportMode.project;
    if (bins.length==0) {
        bins=@"250";
    }

    NSString *limtDataString = @"limit";
    NSString *csvPath = self.pathOpenLabel.stringValue;
    if (!csvPath.length) {
        return;
    }
    if (![event containsString:@"one_item_plot"]) {
        
        if ([event containsString:@"excel-report"]) {
            [self.excelReportVC dismisssViewOnViewController:self];
        }else{
            [self.keynoteReportVC dismisssViewOnViewController:self];
        }
        

        [self.loadingVC showViewAsSheetOnViewController:self];
        
    }else{
        NSInteger limitDataSegment = self.limitDataSegment.selectedSegment;
        limtDataString = limitDataSegment ? @"data" :@"limit";
    }
//
//    [self appenLog:@"show load View"];
    NSInteger index = self.itemsTableView.selectedRow;
    NSIndexSet *index_set = self.colorByTableView.selectedRowIndexes;
    NSIndexSet *index_set2 = self.colorByTableview2.selectedRowIndexes;
    NSInteger selectedSegment = self.removeSegment.selectedSegment;
    NSInteger frist_all_last_Segment = self.frist_all_last_Segment.selectedSegment;
    

    NSInteger testSelectedSegment = self.testSegment.selectedSegment;
    
    NSString *colorByBoxValue= self.colorByBox.stringValue;
    
    NSString *colorByBoxValue2= self.colorbByBox2.stringValue;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.colorByBox.enabled = NO;
            self.colorbByBox2.enabled = NO;
            self.removeSegment.enabled = NO;
            self.frist_all_last_Segment.enabled = NO;
            self.limitDataSegment.enabled = NO;
            self.selectXData.enabled = NO;
            self.selectYData.enabled = NO;
        });
        _isRunPython = YES;
        
        self.loadingVC.showingText = event;
//        if ([event containsString:@"report"]) {
//            [self.loadingVC showViewAsSheetOnViewController:self];
//        }
        
        [self generateLogDir];
        
        NSString *item_name = @"";
        NSString *new_usl = @"";
        NSString *new_lsl = @"";
        //    if (![event isEqualToString:@"cpk-report"]) {
        if (index>=0) {
            if (self.itemOriginalDatas.count) {
                ItemMode *itemM = self.itemDatas[index];
                SnVauleMode *sv_mode = itemM.SnVauleArray[0];
                if (!sv_mode.sn.length) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MyEexception RemindException:@"Error" Information:@"Wrong Data"];
                    });
                    
                    return;
                }
                if (itemM.item.length) {
                    item_name = itemM.item;
                }
                
                if (itemM.needUpdate) {
                    if (itemM.lsl.length) {
                        new_lsl = itemM.lsl;
                    }else{
                        new_lsl = itemM.low;
                    }
                    if (itemM.usl.length) {
                        new_usl = itemM.usl;
                    }else{
                        new_usl = itemM.upper;
                    }
                }

//                [self appenLog:@"generateItemCsvList---start"];
                [self generateItemCsvListWithItemMode:itemM];
//                [self appenLog:@"generateItemCsvList---end"];
            }
            
        }
        //}
//        NSString * x_cpk_lsl = @"";
//        NSString * x_cpk_usl = @"";
        // if (_isSelectX) {
        NSString *x_cpk_lsl= self.last_itemM.lsl;
        NSString *x_cpk_usl = self.last_itemM.usl;

        NSMutableString *colorBy_selete_items=[[NSMutableString alloc]init];
        if (index_set.count) {
            [colorBy_selete_items appendString:[NSString stringWithFormat:@"[%@]",colorByBoxValue]];
            [index_set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *string = [[self.color_datas[idx] colorBy2Mode] colorTitle];
                [colorBy_selete_items appendString:@","];
                [colorBy_selete_items appendString:[NSString stringWithFormat:@"[%@]",string]];
                
            }];
            
        }else{
            [colorBy_selete_items appendString:@"Off"];
            
        }
        
        
        NSMutableString *colorBy_selete_items2=[[NSMutableString alloc]init];
        if (index_set2.count) {
            [colorBy_selete_items2 appendString:[NSString stringWithFormat:@"[%@]",colorByBoxValue2]];
            [index_set2 enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                
              //  NSString *string = [[self.color_datas2[idx] colorBy2Mode] colorTitle];
                if (self.colorTable2_datas.count) {
                    NSString *string = self.colorTable2_datas[idx];
                    [colorBy_selete_items2 appendString:@","];
                    [colorBy_selete_items2 appendString:[NSString stringWithFormat:@"[%@]",string]];
                }
 
                
            }];
            
        }else{
            [colorBy_selete_items2 appendString:@"Off"];
            
        }
        
//        if (cpk_lsl.length==0) {
//            cpk_lsl=@"1.33";
//        }
//        if (cpk_usl.length==0) {
//            cpk_usl=@"999999999";
//        }
//

        //self.colorByTableView.selectedRow;
        //    NSString *python_file = [[NSBundle mainBundle] pathForResource:@"python_main.py" ofType:nil];
        //    [self appenLog:[NSString stringWithFormat:@"python_main File Path:%@\n",python_file]];
        //    PythonTask *python=[[PythonTask alloc]initWithPythonPath:python_file parArr:@[csvPath,lsl,usl,selete_items]];
        
        NSString *budle_path = [[NSBundle mainBundle] resourcePath];//generate_keynote.py
        NSString *python_file = [budle_path stringByAppendingPathComponent:@"python_test/start.py"];
        [self appenLog:[NSString stringWithFormat:@"python_start File Path:%@\n",python_file]];
        
        NSString *remove_fail  = selectedSegment ? @"NO":@"YES";
        
        NSString *dataSelect = @"First";
        if (frist_all_last_Segment ==1) {
            dataSelect = @"All";
        }else if(frist_all_last_Segment ==2){
            dataSelect = @"Last";
        }
        
        
        NSString *logPath =_temp_logPath.stringByDeletingLastPathComponent;
        
        
        if (testSelectedSegment==0) {
            ///cw debug
            
//            PyObject *arglistStr2;
//            arglistStr2 = Py_BuildValue("ssss", "suncode","shenzhen","zhongshan","zhuhai");
//            PyObject *my_func3 = PyObject_GetAttrString(_cpkModule, "my_func3");
//            if (my_func3 && PyCallable_Check(my_func3))
//            {
//                PyObject *result = PyObject_CallObject(my_func3, arglistStr2);
//                if(result != NULL){
//                    NSLog(@"Result 3 of call: %s", PyString_AsString(result));
//                }
//            }
//
//            PyObject *arglistStr1;
//            arglistStr1 = Py_BuildValue("ssssssssssss",csvPath.UTF8String, logPath.UTF8String,cpk_lsl.UTF8String,cpk_usl.UTF8String,colorBy_selete_items.UTF8String,bins.UTF8String,remove_fail.UTF8String,item_name.UTF8String, dataSelect.UTF8String,event.UTF8String,new_lsl.UTF8String,new_usl.UTF8String);
//            PyObject *cpk_run = PyObject_GetAttrString(_cpkModule, "cpk_run");
//            if (cpk_run && PyCallable_Check(cpk_run))
//            {
//                PyObject *result = PyObject_CallObject(cpk_run, arglistStr1);
//                if(result != NULL){
//                    //                PyAPI_FUNC(char *) result_pyString =PyString_AsString(result);
//                    NSLog(@"Result cpk_run of call: %s", PyString_AsString(result));
//                    //                NSString *read = [NSString stringWithUTF8String:result_pyString] ;
//                    //                [self appenLog:read];
//                    NSString *cpkRunLog = [NSString stringWithFormat:@"Result cpk_run of call: %s",PyString_AsString(result)];
//                    [self appenLog:[NSString stringWithFormat:@"Log from oc-python:%@",cpkRunLog]];
//                }
//            }
//             [self appenLog:@"run python---start"];
            NSString *settingListPath= [[NSBundle mainBundle] pathForResource:@"SettingList.plist" ofType:nil];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:settingListPath];
            NSString *python_path = @"";
            BOOL isPython3 = [dic[@"isPython3"] boolValue];
            if (isPython3) {
                python_path =dic[@"which python3"];
            }else{
                python_path =dic[@"which python2"];
            }
    

            pTask = [[PythonTask alloc]initWithPythonPath:python_file parArr:@[csvPath,logPath,cpk_lsl,cpk_usl,colorBy_selete_items,bins,remove_fail,item_name,dataSelect,event,new_usl,new_lsl,x_cpk_usl,x_cpk_lsl,colorBy_selete_items2,excel_item,fail_plot_to_excel,excel_report_user,excel_report_stage,limtDataString,excel_report_project] lauchPath:python_path];
      
            NSString *read = [pTask read];
            [self appenLog:read];
            
     
        }else{
            //NSLog(@"==>%s",myRedis->GetString("test_item_1"));
            //NSLog(@"==>%s",myRedis->GetString("test_item_2"));
            
            NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
//                pTask = [[PythonTask alloc]initWithPythonPath:python_file parArr:@[csvPath,logPath,cpk_lsl,cpk_usl,colorBy_selete_items,bins,remove_fail,item_name,dataSelect,event,new_usl,new_lsl,x_cpk_usl,x_cpk_lsl,colorBy_selete_items2,excel_item,fail_plot_to_excel,excel_report_user,excel_report_stage,limtDataString,excel_report_project] lauchPath:python_path];
            
            NSString *cmd = [NSString stringWithFormat:@"%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@",csvPath,logPath,cpk_lsl,cpk_usl,colorBy_selete_items,bins,remove_fail,item_name,dataSelect,event,new_usl,new_lsl,x_cpk_usl,x_cpk_lsl,colorBy_selete_items2,excel_item,fail_plot_to_excel,excel_report_user,excel_report_stage,limtDataString,excel_report_project];
            int ret = [cpkClient SendCmd:cmd];
            if (ret > 0)
            {
                NSString * response = [cpkClient RecvRquest:1024];
                
                if (!response)
                {    //Not response
                    //@throw [NSException exceptionWithName:@"automation Error" reason:@"pleaase check fixture." userInfo:nil];
                    NSLog(@"zmq for python error");
                }
                [self appenLog:response];
                NSLog(@"app->get response from python: %@",response);
            }
            NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
            NSLog(@"====python 执行时间: %f",now-starttime);
            
        }
        

        if ([event containsString:@"one_item_plot"]) {
            
            NSString *pic_path1=[NSString stringWithFormat:@"%@/temp_pic.png",_temp_logPath];
            NSString *pic_path2 =[NSString stringWithFormat:@"%@/correlation.png",_temp_logPath];
            [self setPicture:pic_path1 pic_path2:pic_path2];
//            [self appenLog:@"loading chart pic finish"];
//
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingVC dismisssViewOnViewController:self];
            });
            
            
        }

        _isRunPython = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.colorByBox.enabled = YES;
            self.colorbByBox2.enabled = YES;
            self.removeSegment.enabled = YES;
            self.frist_all_last_Segment.enabled = YES;
            self.limitDataSegment.enabled = YES;
            self.selectXData.enabled = YES;
            self.selectYData.enabled = YES;
            
        });
        
    });
}

-(void)LoadCsvControllerApplyClickWithDataPath:(NSString *)dataPath scriptPath:(NSString *)scriptPath cpkLTHL:(nonnull NSString *)cpkLTHL cpkHTHL:(nonnull NSString *)cpkHTHL{
    
    [self.loadCsvVC close];

    _cpkLTHL = cpkLTHL;
    _cpkHTHL =cpkHTHL;
    BOOL isLoadScript = NO;
    if (scriptPath.length) {
        isLoadScript = YES;
    }
    if ([self addCsvWithPath:dataPath isLoadScript:isLoadScript]) {
        if (isLoadScript) {
            [self addScriptWithPath:scriptPath];
        }else{
           [self.loadingVC dismisssViewOnViewController:self];
        }
        
    }
}
-(void)reportVCApplyClick:(ReportMode *)reportMode{

    [self runPython:reportMode];
}

-(void)excelReportVCApplyClick:(ReportMode *)reportMode{

    [self runPython:reportMode];
}

- (IBAction)report:(NSButton *)btn {

    if (!self.itemDatas.count) {
        return;
    }
    if (_isRunPython) {
        return;
    }

    if (self.itemsTableView.selectedRow<0) {
        
//        [MyEexception RemindException:@"Error" Information:@"Pls select the item first"];
        return;
    }
    
    
    [self save_csv:nil];
//    NSInteger reportSegment = self.reportSegment.selectedSegment;
    if ([btn.title.lowercaseString containsString:@"excel"]) {
        //[self runPython:@"excel-report"];
        [self.excelReportVC showViewOnViewController:self];
        self.excelReportVC.itemOriginalDatas = self.itemOriginalDatas;
        
        
    }else if([btn.title.lowercaseString containsString:@"keynote"]){
       [self.keynoteReportVC showViewOnViewController:self];
        
        //self.keynoteReportVC.itemOriginalDatas = self.itemOriginalDatas;
    }else{
        [self.excelReportVC showViewOnViewController:self];
//        __weak typeof(self) weakSelf = self;
//        self.reportVC.applyBlock = ^(ReportMode * _Nonnull reportMode) {
//
//            [weakSelf runPython:reportMode];
//        };
    }
    
}




- (IBAction)clickShowSnVauleVC:(NSButton *)sender {
    
    NSInteger selectedRow = self.itemsTableView.selectedRow;
    
    [self reloadSnVauleTableList:self.itemDatas[selectedRow]];
    
    [self.snVauleVC showViewOnViewController:self datas:self.sn_datas];
    
}

- (IBAction)selectDataClick:(NSButton *)btn {
    
  NSInteger index = self.itemsTableView.selectedRow;
    if (index<0) {
        return;
    }
    
    
    if ([btn.title containsString:@"X"]) {
//
//        if (!_isSelectX) {
//            self.last_itemM = self.itemDatas[index];
//            _isSelectX = YES;
//        }
        
        //self.last_itemM = self.itemDatas[index];
//         || [itemM.item.lowercaseString containsString:@"fixture channel id"]
        
//        if ([[[self.itemDatas[index] item] lowercaseString]containsString:@"fixture channel id"]) {
//            return;
//        }
        _isSelectX=NO;
        
        [self reflesh:self.itemsTableView row:index];
    }
//    else{
//        _isSelectX = NO;
//    }

    
}

@end
