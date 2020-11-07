//
//  dataTableView.m
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "dataTableView.h"
#import "parseCSV.h"
#import "NSEventEx.h"
#import "RedisInterface.hpp"
#import "dataPlotView.h"
#import "defineHeader.h"
#import "Client.h"
#import "loadCsvControl.h"
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>


#define NUMBERS @"0123456789.-"

extern NSMutableDictionary *m_configDictionary;
extern NSInteger tbDataTableSelectItemRow;

extern NSMutableArray *_dataReverse;
extern NSMutableArray *_rawData;
extern int selectColorBoxIndex; //left color by
extern int selectColorBoxIndex2;//right color by

extern RedisInterface *myRedis;
extern Client *cpkClient;
extern Client *correlationClient;
extern Client *calculateClient;
extern Client *reportClient;


int n_Start_Data_Col;
int n_Pass_Fail_Status;
int n_Product_Col;
int n_SerialNumber;
int n_SpecialBuildName_Col;
int n_Special_Build_Descrip_Col;
int n_StationID_Col;
int n_StartTime;
int n_Version_Col;


/*
 
 
 #define Start_Data_Row                 7
 #define Start_Data_Col                 11
 #define Pass_Fail_Status               7
 #define Product_Col                    1
 #define SerialNumber                   2
 #define SpecialBuildName_Col           3
 #define Special_Build_Descrip_Col      4
 #define StationID_Col                  6
 #define StartTime                      8
 #define Version_Col                    10
 */


@interface dataTableView ()
{
    BOOL enableEditing;
    NSUInteger clickItemIndex;
    NSUInteger editLimitRow;
    NSString *retestValue;  //记录上次结果
    NSString *removeValue;  //记录上次结果
    NSString *desktopPath;
    int select_btn_x;
    int select_btn_y;
    int click_item_flag;
    NSMutableArray *arrSearch;
    int n_search;
    CGFloat _lastLeftPaneWidth;
    int n_loadCsvBtn;
    int n_sort_col1;
    
}

@property (weak) IBOutlet NSTableView *dataTableView;
@property (nonatomic,strong)NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *dataBackup;
@property (nonatomic,strong)NSMutableArray *scriptData;
@property (nonatomic,strong)NSMutableArray *sortDataBackup;
//@property (nonatomic,strong)NSMutableArray *rawData;
@property (nonatomic,strong)NSMutableDictionary *indexItemNameDic;
@property (nonatomic,strong)NSMutableArray *ListAllItemNameArr;
@property (nonatomic,strong)NSMutableDictionary *textEditLimitDic;

@property (nonatomic,strong)NSMutableArray *colorRedIndex;  //不相同的item，后面追加的数据，显示红色
@property (nonatomic,strong)NSMutableArray *colorGreenIndex; //相同的item，显示绿色
@property (nonatomic,strong)NSMutableArray *colorRedIndexBackup;  //不相同的item，后面追加的数据，显示红色
@property (nonatomic,strong)NSMutableArray *colorGreenIndexBackup; //相同的item，显示绿色

@property (weak) IBOutlet NSTextField *txtScriptPath;

@property loadCsvControl *modalCsvController;
@end

@implementation dataTableView

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _data = [[NSMutableArray alloc]init];
        _scriptData = [[NSMutableArray alloc]init];
        //_dataReverse = [[NSMutableArray alloc]init];
        //_rawData = [[NSMutableArray alloc]init];
        _indexItemNameDic = [[NSMutableDictionary alloc] init];
        _textEditLimitDic = [[NSMutableDictionary alloc] init];
        _ListAllItemNameArr  = [[NSMutableArray alloc]init];
        enableEditing = YES;
        clickItemIndex = -1;
        editLimitRow = -1;
        retestValue=@"";
        removeValue = @"";
        
        select_btn_x = 0;
        select_btn_y = 0;
        click_item_flag = 0;
        arrSearch = [[NSMutableArray alloc]init];
        _dataBackup = [[NSMutableArray alloc]init];
        n_search = 0;
        n_loadCsvBtn = 0;
        n_sort_col1 = 0;
        _sortDataBackup = [[NSMutableArray alloc]init];
        
        n_Start_Data_Col = -1;
        n_Pass_Fail_Status = -1;
        n_Product_Col =-1;
        n_SerialNumber = -1;
        n_SpecialBuildName_Col = -1;
        n_Special_Build_Descrip_Col =-1;
        n_StationID_Col =-1;
        n_StartTime = -1;
        n_Version_Col =-1;
        
        
        
        _colorRedIndex = [[NSMutableArray alloc]init];
        _colorGreenIndex = [[NSMutableArray alloc]init];
        _colorRedIndexBackup = [[NSMutableArray alloc]init];
        _colorGreenIndexBackup = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [_dataTableView setDelegate:self];
    [_dataTableView setDataSource:self];
    
    [self.dataTableView reloadData];
    [self.dataTableView setDoubleAction:@selector(DblClickOnTableView:)];
    [self.dataTableView setAction:@selector(DblClickOnTableView:)];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
    [self keyDown:aEvent];
    return aEvent;
    }];
    
    desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *logPath = [NSString stringWithFormat:@"%@/CPK_Log",desktopPath];
    [self createFileDirectories:logPath];
    NSString *failPlot = [NSString stringWithFormat:@"%@/fail_plot",logPath];
    [self createFileDirectories:failPlot];
    NSString *plot = [NSString stringWithFormat:@"%@/plot",logPath];
    [self createFileDirectories:plot];
    
    NSString *temp = [NSString stringWithFormat:@"%@/temp",logPath];
    [self createFileDirectories:temp];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcpk.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcor.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcalc.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
   // [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.logparam.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.txtScriptPath setStringValue:@""];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetColorByLeft object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetColorByRight object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSelectX object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSelectY object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetParameters object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toLoadCsv:) name:kNotificationToLoadCsv object:nil];
    //

    _lastLeftPaneWidth = self.leftPane.frame.size.width;
    csvView = [[csvListController alloc]init];
    [self LoadSubView:csvView.view];
    [self.splitView setPosition:0 ofDividerAtIndex:0];

}

-(void)awakeFromNib
{
    [self.splitView setPosition:0 ofDividerAtIndex:0];
}
-(void)settingTableViewData:(NSNotification *)nf
{
    NSString * name = [nf name];   // set color by choose
    if ([ name isEqualToString:kNotificationSetColorByLeft])
    {
        NSDictionary* info = [nf userInfo];
        int colorIndex = [[info valueForKey:select_Color_Box_left] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][tb_color_by_left]=[NSNumber numberWithInt:colorIndex];
        }
    }
    else if ([ name isEqualToString:kNotificationSetColorByRight])
    {
        NSDictionary* info = [nf userInfo];
        int colorIndex = [[info valueForKey:select_Color_Box_Right] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][tb_color_by_right]=[NSNumber numberWithInt:colorIndex];
        }
        
    }
    else if ([ name isEqualToString:kNotificationSelectX])
    {
        NSDictionary* info = [nf userInfo];
        int x = [[info valueForKey:btn_select_x] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][button_select_x]=[NSNumber numberWithInt:x];
            [self triggerGeneratePlot:row withApplyBox:YES withSelectXY:1];
        }
        
        
        
        
    }
    else if ([ name isEqualToString:kNotificationSelectY])
    {
        NSDictionary* info = [nf userInfo];
        int y = [[info valueForKey:btn_select_y] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][button_select_y]=[NSNumber numberWithInt:y];
             [self triggerGeneratePlot:row withApplyBox:YES withSelectXY:10];
        }
       
        
    }
     else if ([ name isEqualToString:kNotificationSetParameters])
     {
         /*
          @try {
             NSDictionary* info = [nf userInfo];
             NSString *path = [info valueForKey:paramPath];
             NSLog(@"======>>>>>>:%@",path);
             NSFileManager *fh_csv = [NSFileManager defaultManager];
             NSData *data = [fh_csv contentsAtPath:path];
             NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSArray *line = [str componentsSeparatedByString:@"\n"];
             for (int i = 1; i< [line count]; i++)
            {
                NSArray *lineArr = [line[i] componentsSeparatedByString:@","];
                if ([lineArr count]>5)
                {
                    for (int j = 0; j< [_ListAllItemNameArr count]; j++)
                    {
                        if ([_ListAllItemNameArr[j] isEqualToString:lineArr[0]])
                        {
                            _data[j][BC_Col] = lineArr[1];
                            _data[j][p_val_Col] = lineArr[2];
                            _data[j][a_q_Cal] = lineArr[3];
                            _data[j][a_irr_Cal] = lineArr[4];
                            _data[j][CV3_Cal] =lineArr[5];
                            break;
                        }
                        
                    }
                }

            }
             
            [self.dataTableView reloadData];
        }
         @catch (NSException *exception)
         {
             NSLog(@"-----update 3CV,a_q,a_irr error");
         }
          */
         
     }
    
    
}

//-(void)readParameterCsv:(NSString *)path
//{
//       NSFileManager *fh_csv = [NSFileManager defaultManager];
//       NSData *data = [fh_csv contentsAtPath:path];
//       NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//       NSArray *line = [str componentsSeparatedByString:@"\n"];
//
//
//       for (int i = 0; i< [line count]; i++)
//       {
//           NSArray *lineArr = [line[i] componentsSeparatedByString:@","];
//           NSString * finnalStr=[line[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//
//       }
//}

- (void)createFileDirectories:(NSString *)folderPath
{
    // 判断文件夹是否存在，不存在则创建对应文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:folderPath];
    if (isExist)
    {
        NSLog(@"目录已经存在");
    }
    else
    {
        BOOL ret = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (ret)
        {
            NSLog(@"目录创建成功");
            
        }
        else
        {
            NSLog(@"目录创建失败");
            return;
        }
    }
}

-(IBAction)DblClickOnTableView:(id)sender
{
    NSInteger row = [self.dataTableView selectedRow];
    NSLog(@"=====>>>> select row: %zd",row);
    if (row == -1)
    {
        NSInteger col = [self.dataTableView selectedColumn];
        if (col ==0)
        {
            if ([_colorGreenIndexBackup count]>0 || [_colorRedIndexBackup count]>0)
            {
                n_sort_col1 ++;
                [_data removeAllObjects];
                [_colorGreenIndex removeAllObjects];
                [_colorRedIndex removeAllObjects];
                
                if (n_sort_col1%3 ==1)  //绿色排序显示在前面
                {
                    NSMutableArray *sort = [NSMutableArray array];
                    int i;
                    for (i=0; i<[_colorGreenIndexBackup count]; i++)
                    {
                        int index = [_colorGreenIndexBackup[i] intValue];
                        [sort addObject:_sortDataBackup[index]];
                        [_colorGreenIndex addObject:[NSNumber numberWithInt:i]];
                    }
                
                    for (int j=0; j<[_colorRedIndexBackup count]; j++)
                    {
                        int index = [_colorRedIndexBackup[j] intValue];
                        [sort addObject:_sortDataBackup[index]];
                        [_colorRedIndex addObject:[NSNumber numberWithInt:i+j]];
                    }
                    
                    for (int m=0; m<[_sortDataBackup count]; m++)
                    {
                        if ((![_colorGreenIndexBackup containsObject:[NSNumber numberWithInt:m]]) &&(![_colorRedIndexBackup containsObject:[NSNumber numberWithInt:m]]))
                        {
                            [sort addObject:_sortDataBackup[m]];
                        }
                    }
                    
                    [_data setArray:sort];
                    
                }
                
               if (n_sort_col1%3 ==2)  //红色排序显示在前面
                {
                       NSMutableArray *sort = [NSMutableArray array];
                       int i;
                        for (i=0; i<[_colorRedIndexBackup count]; i++)
                        {
                            int index = [_colorRedIndexBackup[i] intValue];
                            [sort addObject:_sortDataBackup[index]];
                            [_colorRedIndex addObject:[NSNumber numberWithInt:i]];
                        }
                       
                       for (int j=0; j<[_colorGreenIndexBackup count]; j++)
                       {
                           int index = [_colorGreenIndexBackup[j] intValue];
                           [sort addObject:_sortDataBackup[index]];
                           [_colorGreenIndex addObject:[NSNumber numberWithInt:i+j]];
                       }
                   

                       
                       for (int m=0; m<[_sortDataBackup count]; m++)
                       {
                           if ((![_colorGreenIndexBackup containsObject:[NSNumber numberWithInt:m]]) &&(![_colorRedIndexBackup containsObject:[NSNumber numberWithInt:m]]))
                           {
                               [sort addObject:_sortDataBackup[m]];
                           }
                       }
                       
                       [_data setArray:sort];
                }
                
                if (n_sort_col1%3 ==0)  //正常排序显示
                 {
                     [_data setArray:_sortDataBackup];
                     [_colorRedIndex setArray:_colorRedIndexBackup];
                     [_colorGreenIndex setArray:_colorGreenIndexBackup];
                     
                 }
            }
            else
            {
                NSLog(@"--only isight data ,can not sort!!!  %zd",col);
            }
            
            [self.dataTableView reloadData];
        }
        else
        {
            NSLog(@"--select data tbs item is wrong!!!  %zd",col);
        }
        
        return;
    }
    
    [self triggerGeneratePlot:row withApplyBox:NO withSelectXY:-1];
    /*
    tbDataTableSelectItemRow = row;
    NSString *retest = [m_configDictionary valueForKey:kRetestSeg];
    NSString *removeFail = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *bins = [m_configDictionary valueForKey:kBins];
    NSLog(@"==>row:%zd   %@  %@  bin:%@",row,retest,removeFail,bins);
    _data[row][31]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    if (clickItemIndex!=row|| [retestValue isNotEqualTo:retest] || [removeValue isNotEqualTo:removeFail])
    {
        clickItemIndex = row;
        retestValue = retest;
        removeValue = removeFail;
        if (selectColorBoxIndex == 0)  //color by box 关闭
        {
            NSString * itemName = [self combineItemName:[_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",row]]];
            NSLog(@"--ClickOnTableView--:%zd  selectColorBoxIndex:%d, item name : %@",row,selectColorBoxIndex,itemName);
            NSMutableArray * itemData = [self calculateData:row];
            NSLog(@"==<>>> %zd",[itemData count]);
            //[self calculateData:row withRetest:[m_configDictionary valueForKey:kRetestSeg] withRemove:[m_configDictionary valueForKey:kRemoveFailSeg]];
            [self sendDataToRedis:itemName withData:itemData];
            NSString *pic = [self sendCpkZmqMsg:itemName];
            NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/%@",desktopPath,pic];
            [self notifySetImage:path];
        }
        else
        {
             [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
        }

    }
    else
    {
        if (selectColorBoxIndex > 0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
        }
        else
        {
            NSLog(@"--click the same item, do nothing");
        }
    }
    */

}

-(BOOL)triggerGeneratePlot:(NSInteger)rowtb withApplyBox:(BOOL)ApplyBoxflag withSelectXY:(int)xy
{
    NSInteger row = 0;
    for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
    {
        if ([_ListAllItemNameArr[i] isEqualToString:_data[rowtb][1]])
        {
            row = i;
            break;
        }
    }
    
    tbDataTableSelectItemRow = row;
    NSString *retest = [m_configDictionary valueForKey:kRetestSeg];
    NSString *removeFail = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *bins = [m_configDictionary valueForKey:kBins];
    NSLog(@"==>row:%zd   %@  %@  bin:%@",row,retest,removeFail,bins);
    _data[rowtb][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    _data[rowtb][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    if (clickItemIndex!=row|| [retestValue isNotEqualTo:retest] || [removeValue isNotEqualTo:removeFail]||ApplyBoxflag)
    {
        clickItemIndex = row;
        retestValue = retest;
        removeValue = removeFail;
        if (selectColorBoxIndex == 0 && selectColorBoxIndex2 == 0)  //color by box 关闭
        {
            NSString * itemName = [self combineItemName:[_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",row]]];
            NSLog(@"--ClickOnTableView--:%zd  selectColorBoxIndex:%d, selectColorBoxIndex2:%d,item name : %@",row,selectColorBoxIndex,selectColorBoxIndex2,itemName);
            NSMutableArray * itemData = [self calculateData:row];
            NSLog(@"==<>>> %zd",[itemData count]);
            //[self calculateData:row withRetest:[m_configDictionary valueForKey:kRetestSeg] withRemove:[m_configDictionary valueForKey:kRemoveFailSeg]];
            if (xy==-1)
            {
                // do nothing
            }
            else
            {
                itemName = [NSString stringWithFormat:@"%@$$%d",itemName,xy];
            }
            [self sendDataToRedis:itemName withData:itemData];
            [self sendCpkZmqMsg:itemName];
            [self sendCorrelationZmqMsg:itemName];
//            NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/%@",desktopPath,pic];
//            [self notifySetImage:path];
        }
        else
        {
            if (xy==-1)
            {
                // NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:ApplyBoxflag] forKey:applyBoxCheck];
                if (selectColorBoxIndex > 0)
                {
                   [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
                }
                else if (selectColorBoxIndex2 > 0)
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
                }
                 
            }
            else
            {
                NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:xy] forKey:selectXY];
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable_selectXY object:nil userInfo:dic];

            }
        }

    }
    else
    {
        if (selectColorBoxIndex > 0 )
        {
            //NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:ApplyBoxflag] forKey:applyBoxCheck];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
        }
        else if(selectColorBoxIndex2 > 0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
        }
        else
        {
            NSLog(@"--click the same item, do nothing");
        }
    }
    return ApplyBoxflag;
}

-(IBAction)btnClickApply:(NSButton*)sender
{
    NSLog(@"==>%@  %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
    NSInteger btnTag = sender.tag;  // select row
    NSInteger state = sender.state;
    _data[btnTag][tb_apply] = [NSNumber numberWithInteger:state];
    _data[btnTag][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    _data[btnTag][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    [self.dataTableView reloadData];
    if ([_data[btnTag][tb_lsl] isEqualTo:@""] &&[_data[btnTag][tb_usl] isEqualTo:@""])
    {
        [self AlertBox:@"Warning!!!" withInfo:@"Please input LSL or USL firstly!!!"];
        _data[btnTag][tb_apply] = [NSNumber numberWithInt:0];
        [self.dataTableView reloadData];
        return;
    }
    if ([_data[btnTag][tb_lsl] isNotEqualTo:@""] &&[_data[btnTag][tb_usl] isNotEqualTo:@""])
    {
        float low =  [_data[btnTag][tb_lsl] floatValue];
        float high =  [_data[btnTag][tb_usl] floatValue];
        if (low>high)
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Input LSL is bigger than USL!!!"];
            _data[btnTag][tb_apply] = [NSNumber numberWithInt:0];
            [self.dataTableView reloadData];
            return;
        }
    }
    [m_configDictionary setValue:[NSNumber numberWithBool:btnTag] forKey:K_dic_ApplyBoxCheck];
    NSString * itemName =[self combineItemName: [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",btnTag]]];
    NSLog(@"==> tag:%zd  state:%zd, item name: %@",btnTag,state,itemName);
    [self triggerGeneratePlot:btnTag withApplyBox:YES withSelectXY:-1];
    
}

-(NSString *)openCSVLoadPanel
{
    //[[NSWorkspace sharedWorkspace] openFile:@"~/desktop"];
    //[[NSWorkspace sharedWorkspace] openFile:desktopPath];
    //    [panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
        //[panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result)  //[NSApp mainWindow]
    //    {
    //        if (result == NSModalResponseOK) {
    //             @try {
    //                 csvpath = [[[panel URLs] objectAtIndex:0] path];
    //                 [self.txtScriptPath setStringValue:csvpath];
    //             }
    //             @catch (NSException *exception) {
    //                 NSLog(@"Load file failed,please check the data");
    //             }
    //             @finally {
    //             }
    //         }
    //     }];
        
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"CSV", @"csv", @"Csv",nil]];
    [panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        [self.txtScriptPath setStringValue:csvpath];
    }
    else
    {
        [self.txtScriptPath setStringValue:@"--"];
    }
    if (csvpath==nil || [csvpath isEqualToString:desktopPath])
    {
        return nil;
    }
    return csvpath;
}

- (IBAction)btnSearchCsv:(id)sender
{
    if (n_search == 0)
     {
         [_dataBackup setArray:_data];
         n_search ++;
     }
    [arrSearch removeAllObjects];
    NSString *content = [sender stringValue];
    if (content.length<2)
    {
        [_data setArray:_dataBackup];
        [self.dataTableView reloadData];
        n_search = 0;
        return;
    }
    [self searchFind:content];
    
}

-(void)searchFind:(NSString *)content
{

    for (NSArray *lineData in _data)
    {
        NSString *lineStr = lineData[1];
        if ([lineStr.uppercaseString containsString:content.uppercaseString])
        {
            [arrSearch addObject:lineData];
        }
        
    }
    [_data setArray:arrSearch];
    [self.dataTableView reloadData];
}

- (IBAction)btLoadCsvData:(id)sender
{
    
     [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.25; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        //if ([self.splitView isSubviewCollapsed:self.rightPanel])
//         if(n_loadCsvBtn %2==1)
//        {
//            // -> expand
//            [self.splitView setPosition:_lastLeftPaneWidth ofDividerAtIndex:0];
//        }
//        else {
//            // <- collapse
//            _lastLeftPaneWidth = self.leftPane.frame.size.width; //  remember current width to restore
//            [self.splitView setPosition:0 ofDividerAtIndex:0];
//        }
         if (_lastLeftPaneWidth==0 )
         {
            
             [self.splitView setPosition:1500 ofDividerAtIndex:0];
             _lastLeftPaneWidth = 1500;
         }
         else
         {
             [self.splitView setPosition:0 ofDividerAtIndex:0];
              _lastLeftPaneWidth = 0;
             
         }
         
        
        [self.splitView layoutSubtreeIfNeeded];
    }];
    
    return;
   // [self openSheet:sender];
   /* NSString *csvPath = [self openCSVLoadPanel];

    if (!csvPath) {
        NSLog(@"--no csv select");
        return;
    }
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    [m_configDictionary setValue:csvPath forKey:Load_Csv_Path];
    [self sendCalculateZmqMsg:@"calculate-param"];
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    //NSString *csvPath = @"/Users/RyanGao/Desktop/cpk/cpk_data_0611/J5xx-FCT.csv"; //J5xx-FCT   test
    [self reloadDataWithPath:csvPath];
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    [self initRetestAndRemoveFailSeg];
    [self initColorByTableView];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInitColorTable object:nil userInfo:nil];
    
    //再次加载，需要init
    enableEditing = YES;
    clickItemIndex = -1;
    editLimitRow = -1;
    retestValue=@"";
    removeValue = @"";
    NSLog(@"====load csv执行时间: %f",now-starttime);
    
    NSString *file1 = [NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    NSString *file2 = [NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    [manager removeItemAtPath:file2 error:nil];
    NSString *picPath2 =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath2 toPath:file2 error:nil];
    */
}


-(void)toLoadCsv:(NSNotification *)nf
{
    //NSString *csvPath = [self openCSVLoadPanel];
    
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    NSDictionary* info = [nf userInfo];
    NSString *csvPath = [info valueForKey:@"data_csv"];
    NSString *scriptPath = [info valueForKey:@"script_csv"];
    NSLog(@"---->>>csvpath: %@   scriptpath: %@",csvPath,scriptPath);
    [m_configDictionary setValue:csvPath forKey:Load_Csv_Path];
    // NSString *csvPath = [m_configDictionary valueForKey:Load_Csv_Path];
    if (!csvPath) {
        NSLog(@"--no csv select");
        return;
    }
    [self.txtScriptPath setStringValue:csvPath];
    [self sendCalculateZmqMsg:@"calculate-param"];
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    //NSString *csvPath = @"/Users/RyanGao/Desktop/cpk/cpk_data_0611/J5xx-FCT.csv"; //J5xx-FCT   test
    [self reloadDataWithPath:csvPath];
    
    //解析脚本csv
    if (scriptPath)
    {
        [self reloadScriptDataWithPath:scriptPath];
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    [self initRetestAndRemoveFailSeg];
    [self initColorByTableView];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInitColorTable object:nil userInfo:nil];
    
    //再次加载，需要init
    enableEditing = YES;
    clickItemIndex = -1;
    editLimitRow = -1;
    retestValue=@"";
    removeValue = @"";
    NSLog(@"====load csv执行时间: %f",now-starttime);
    
    NSString *file1 = [NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    NSString *file2 = [NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    [manager removeItemAtPath:file2 error:nil];
    NSString *picPath2 =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath2 toPath:file2 error:nil];
    
    
    _lastLeftPaneWidth = self.leftPane.frame.size.width; //  remember current width to restore
    [self.splitView setPosition:0 ofDividerAtIndex:0];
     _lastLeftPaneWidth = 0;
    [self.dataTableView setFocusRingType:NSFocusRingTypeNone];
    [self.splitView layoutSubtreeIfNeeded];
    
    
}


-(void)openSheet:(id)sender {
    if(!_modalCsvController)
    {
        _modalCsvController = [[loadCsvControl alloc] init];
    }
//    loadCsvControl *modalCsvController = [[loadCsvControl alloc] init];
//    _modalCsvController = modalCsvController;
    NSLog(@"===<<>> begine");
    [self.viewWindow.window beginSheet:self.modalCsvController.window completionHandler:^(NSModalResponse returnCode)
    {
        switch (returnCode) {
            case NSModalResponseOK:
                NSLog(@"===***** OK");
                break;
            case NSModalResponseCancel:
                NSLog(@"===***** Cancel");
                break;
            default:
                break;
        }
    }];
     
}


-(BOOL)reloadScriptDataWithPath:(NSString *)path
{
    NSString *scriptFileName=[[path lastPathComponent] stringByDeletingPathExtension];
    NSArray *vers = _dataReverse[n_Version_Col];

    if (![vers containsObject:scriptFileName])
    {
        NSArray *scriptName = [scriptFileName componentsSeparatedByString:@"__"];
        if ([scriptName count]>1)
        {
            NSString *scriptName1 = [NSString stringWithFormat:@"%@__%@",scriptName[0],scriptName[1]];// 根据 两个下划线拆分
            NSString *scriptName2 = [NSString stringWithFormat:@"%@__%@",scriptName[1],scriptName[0]];// 根据 两个下划线拆分
            if (![vers containsObject:scriptName1] ||![vers containsObject:scriptName2])
            {
                [self AlertBox:@"error!" withInfo:@"Load test script can not match raw data, will be not loading!!!"];
                return NO;
            }
            
        }
        else
        {
             if (![vers containsObject:scriptName[0]])
             {
                 [self AlertBox:@"error!" withInfo:@"Load test script can not match raw data, will be not loading!!!"];
                 return NO;
             }
             
        }
   
        
    }

    
    [_scriptData removeAllObjects];
    CSVParser *csv = [[CSVParser alloc]init];
    if ([csv openFile:path])
    {
        _scriptData = [csv parseFile];
    }
    if (!_scriptData.count)
    {
        return NO;
    }
    
    NSMutableArray *dataBackupTmp = [NSMutableArray array];
    [dataBackupTmp setArray:_data];
    
    int n_testname = -1;
    int n_subtestname = -1;
    int n_subsubtestname = -1;
    int n_discribe = -1;
    int n_lowlimit = -1;
    int n_highlimit = -1;
    
    //NSMutableArray *mutArrayReverse = [NSMutableArray arrayWithArray:[self reverseArray:_scriptData]];
    ///NSMutableArray *mutArrayReverse = nil;//[NSMutableArray arrayWithArray:[self ]];
    
    for (int i=0; i<[_scriptData[0] count]; i++)
    {
         if ([_scriptData[0][i] isEqualToString:@"TESTNAME"] )
         {
              n_testname = i;
         }
        else if([_scriptData[0][i] isEqualToString:@"SUBTESTNAME"] )
        {
            n_subtestname = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"SUBSUBTESTNAME"] )
        {
             n_subsubtestname = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"DESCRIPTION"] )
        {
            n_discribe = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"LOW"] )
        {
            n_lowlimit = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"HIGH"] )
        {
            n_highlimit = i;
        }
        
    }

    if (n_testname>=0 && n_subtestname>=0&&n_subsubtestname>=0&&n_discribe>=0 && n_lowlimit>=0 && n_highlimit>=0)
    {
     
    }
    else
    {
        [self AlertBox:@"error!!!" withInfo:@"Script format error!!!"];
        return NO;
    }
    
    
    [_indexItemNameDic removeAllObjects];
    [_textEditLimitDic removeAllObjects];
    
    NSMutableArray *ItemNameArrBackup = [NSMutableArray array];
    [ItemNameArrBackup setArray:_ListAllItemNameArr];
    
    [_ListAllItemNameArr removeAllObjects];
    
    
    
    NSMutableArray * newArr = [NSMutableArray array]; //保存脚本与insight 匹配数据
    NSMutableArray * arrSameItemIndex = [NSMutableArray array];  //找到相同item 的index
    
    int n_scriptDat = 0;  //确保不在空元素上索引
    for (int n_index=0; n_index<[_scriptData count]; n_index++)  //i=0 is the test name
    {
    
        if ([_scriptData[n_index] count]>12)  //至少12列,去除脚本空行
        {
            NSString *testName = [NSString stringWithFormat:@"%@ %@ %@",_scriptData[n_index][n_testname],_scriptData[n_index][n_subtestname],_scriptData[n_index][n_subsubtestname]];
            NSString *describe = _scriptData[n_index][n_discribe];
            NSString *lowLimit = _scriptData[n_index][n_lowlimit];
            NSString *highLimit = _scriptData[n_index][n_highlimit];
            
            int m = -1;
            for (int j=0; j<[ItemNameArrBackup count]; j++)
            {
                 if ([ItemNameArrBackup[j] isEqualToString:testName])  //找到脚本与insight 数据相同的item，把数据插入与脚本相同的item 里面加进去，第一列index 显示绿色。 注意：是插入对应item 里面的数据
                 {
                     [newArr addObject:dataBackupTmp[j]];
                     newArr[n_scriptDat][tb_index]= [NSNumber numberWithInt:n_scriptDat];  //UI index
                     [arrSameItemIndex addObject:[NSNumber numberWithInt:j]];
                     [_colorGreenIndex addObject:[NSNumber numberWithInt:n_scriptDat-1]];  //因为第一行要删除，第一行是Test Name，所以不可能能匹配到，索引变成0 开始
                     m=j;
                     //NSLog(@"====>>>>>> same item: %@    %d",testName,n_scriptData);
                     break;
                 }
                 
        
            }
            if (m<0)  //没有找到脚本与insight 相同的item，显示脚本顺序，不插入insight 数据
            {
                [newArr addObject:_scriptData[n_index]];

                newArr[n_scriptDat][tb_index]= [NSNumber numberWithInteger:n_scriptDat];  //UI index
                newArr[n_scriptDat][tb_item]= testName;   //UI item;
                newArr[n_scriptDat][tb_lower]= lowLimit;   //UI lower;
                newArr[n_scriptDat][tb_upper]= highLimit;   //UI upper;
                                                              // number 6 is unit
                newArr[n_scriptDat][tb_lsl]= @"";  // UI new LSL
                newArr[n_scriptDat][tb_usl]= @"";  // UI new USL
                newArr[n_scriptDat][tb_apply]= [NSNumber numberWithInteger:0];  // UI apply button
                newArr[n_scriptDat][tb_description]= describe;  // UI description
                newArr[n_scriptDat][tb_bc]= @"";  // UI BC
                newArr[n_scriptDat][tb_p_val]= @"";  // UI p_val
                newArr[n_scriptDat][tb_a_q]= @"";  // UI a_Q
                newArr[n_scriptDat][tb_i_irr]= @"";  // UI i_irr
                newArr[n_scriptDat][tb_3cv]= @"";  // UI 3CV
                
                newArr[n_scriptDat][16]=@"";
                newArr[n_scriptDat][17]=@"";
                newArr[n_scriptDat][18]=@"";
                
                newArr[n_scriptDat][19]= [NSNumber numberWithInteger:250];  // UI界面设置的bin值
                newArr[n_scriptDat][20]= @"";  //zmq 传过给python的item 名字
                newArr[n_scriptDat][21]= @"2020/0/0 00:00:00";                               //设置cpk start 开始时间
                newArr[n_scriptDat][22]= @"2020/0/0 10:00:00";                               //设置cpk start结束 时间
                newArr[n_scriptDat][23]=@""; //设置生成报告的 BC
                newArr[n_scriptDat][24]=@"";//设置生成报告的 a_L
                newArr[n_scriptDat][25]=@"";//设置生成报告的 a_M
                newArr[n_scriptDat][26]=@"";//设置生成报告的 a_L
                newArr[n_scriptDat][27]=@"";//设置生成报告的 a_U
                newArr[n_scriptDat][28]=@"";//设置生成报告的 a_Q
                newArr[n_scriptDat][29]=@"";//设置生成报告的 a_irr
                newArr[n_scriptDat][30]=[NSString stringWithFormat:@"%@/CPK_Log",desktopPath];//设置log文件路径 /桌面/CPK_Log
                newArr[n_scriptDat][tb_color_by_left]= [NSNumber numberWithInteger:0];  //设置color By左边那个
                newArr[n_scriptDat][tb_color_by_right]= [NSNumber numberWithInteger:0];  //设置color By右边那个
                newArr[n_scriptDat][button_select_x]= [NSNumber numberWithInteger:0];
                newArr[n_scriptDat][button_select_y]= [NSNumber numberWithInteger:0];
                newArr[n_scriptDat][tb_script_flag]= [NSNumber numberWithInteger:1];
                newArr[n_scriptDat][tb_data]= Start_Data;  //all the test data below

                
            }
            n_scriptDat++;
            
        }
    }
    
    
    //NSLog(@"====>相同项目 index: %@    newArr count: %zd ",arrSameItemIndex,[newArr count]);
    if ([arrSameItemIndex count] >0)  //不匹配的数据追加在后面
    {
        int n_num = (int)[newArr count];  //前面显示的脚本的总数量，后面在脚本的总数量上，追加不匹配的数据
        int n_row=n_num;   //后面追加数据，开始的行号
        for (int i=0; i<[dataBackupTmp count]; i++)
        {
            if (![arrSameItemIndex containsObject:[NSNumber numberWithInt:i]])//去除相同的item 以后，把剩下insight data 追加显示在后面，第显示 红色
            {
                [newArr addObject:dataBackupTmp[i]];
                newArr[n_row][tb_index]= [NSNumber numberWithInt:n_row];  //UI index
                [_colorRedIndex addObject:[NSNumber numberWithInt:n_row-1]];
                n_row++;
                
            }
            
        }
    }
    
    if ([_colorRedIndex count]>0)
    {
        NSString * mismatch = [NSString stringWithFormat:@"Test data and test script have %zd items mismatch, and list at the end in red color.",[_colorRedIndex count]];
        [self AlertBox:@"Warning!!!" withInfo:mismatch];
    }
    
    [newArr removeObjectAtIndex:0];  //删除脚本数据TestName subTestName第一条名称删除
   
    NSMutableArray *dataReversBackupTmp = [NSMutableArray array];
    for (int i=0; i<[_dataReverse count]; i++)
    {
        if (i<n_Start_Data_Col)
        {
            [dataReversBackupTmp addObject:_dataReverse[i]];
        }
    }
    
     for (int i=0; i<[newArr count]; i++)
     {
         [dataReversBackupTmp addObject:newArr[i]];
         
         NSString * testName = newArr[i][tb_item];
         [_indexItemNameDic setValue:testName forKey:[NSString stringWithFormat:@"%d",i]];  //设置load script脚本以后，数据显示字典。 注意之前load insight 数据设置一次，如果load脚本，再设置一次。
         [_ListAllItemNameArr addObject:testName];     //设置load script脚本以后，数据显示数据item 名字，后面根据item 名字，找到对应数组索引
    
     }
     
    _dataReverse = dataReversBackupTmp;
    [_data setArray:newArr];
    [self.dataTableView reloadData];
    
    [_sortDataBackup setArray:_data];
    [_colorGreenIndexBackup setArray:_colorGreenIndex];
    [_colorRedIndexBackup setArray:_colorRedIndex];
    
    return YES;
    
}

-(BOOL)reloadDataWithPath:(NSString *)path
{
    
    [_data removeAllObjects];
    [_dataReverse removeAllObjects];
    [_rawData removeAllObjects];
    [_indexItemNameDic removeAllObjects];
    [_textEditLimitDic removeAllObjects];
    [_ListAllItemNameArr removeAllObjects];
    
    [_colorRedIndex removeAllObjects];
    [_colorGreenIndex removeAllObjects];
    [_colorRedIndexBackup removeAllObjects];
    [_colorGreenIndexBackup removeAllObjects];
    
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    CSVParser *csv = [[CSVParser alloc]init];
    if ([csv openFile:path])
    {
        _rawData = [csv parseFile];
    }
    if (!_rawData.count)
    {
          return NO;
    }
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====read csv执行时间: %f",now-starttime);
    // ====store data fct
    //myRedis->SetString(FCT_RAW_DATA,[[NSString stringWithFormat:@"%@",_rawData] UTF8String]);
    if (myRedis)
    {
        myRedis->SetString(FCT_SCRIPT_VERSION,[[NSString stringWithFormat:@"%@",_rawData[0]] UTF8String]);
        myRedis->SetString(FCT_ITEMS_NAME,[[NSString stringWithFormat:@"%@",_rawData[1]] UTF8String]);
    }
    else
    {
        NSLog(@"---->> redis error");
    }
    /*
     Site,Product,SerialNumber,Special Build Name,Special Build Description,Unit Number,Station ID,Test Pass/Fail Status,StartTime,EndTime,Version,List of Failing Tests,Head Id,Fixture Id
     
     #define Start_Data_Row                 7
     #define Start_Data_Col                 11
     #define Pass_Fail_Status               7
     #define Product_Col                    1
     #define SerialNumber                   2
     #define SpecialBuildName_Col           3
     #define Special_Build_Descrip_Col      4
     #define StationID_Col                  6
     #define Start_Calc_Data_Col            12
     #define StartTime                      8
     #define Version_Col                    10
     
     */
     //for (int i=0; i<[_rawData[0] count]; i++)  //计算开始
    int n_index = 30; //匹配前30个数据，节约时间
    if ([_rawData[0] count] <30)
    {
        n_index = (int)[_rawData[0] count];
    }

     for (int i=0; i<n_index; i++)
     {
         if ([_rawData[0][i] isEqualToString:@"Parametric"])
         {
             n_Start_Data_Col = i;   //是12   第一个测试item 开始列
             
         }
          if ([_rawData[1][i] isEqualToString:@"Test Pass/Fail Status"])
          {
              n_Pass_Fail_Status = i;
          }
         if ([_rawData[1][i] isEqualToString:@"Product"])
         {
             n_Product_Col = i;
         }
         if ([_rawData[1][i] isEqualToString:@"SerialNumber"])
         {
             n_SerialNumber = i;
         }
         if ([_rawData[1][i] isEqualToString:@"Special Build Name"])
         {
             n_SpecialBuildName_Col = i;
         }
         if ([_rawData[1][i] isEqualToString:@"Special Build Description"])
         {
             n_Special_Build_Descrip_Col = i;
         }
         if ([_rawData[1][i] isEqualToString:@"Station ID"])
         {
             n_StationID_Col = i;
         }
         if ([_rawData[1][i] isEqualToString:@"StartTime"])
         {
             n_StartTime = i;
         }
         if ([_rawData[1][i] isEqualToString:@"Version"])
         {
             n_Version_Col = i;
         }
     }
    
    if (n_Start_Data_Col<0 ||n_Pass_Fail_Status<0||n_Product_Col<0||n_SerialNumber<0||n_SpecialBuildName_Col<0||n_Special_Build_Descrip_Col<0||n_StationID_Col<0||n_StartTime<0||n_Version_Col<0)
    {
        [self AlertBox:@"Error" withInfo:@"Raw data format is error, can not load!!!"];
        return NO;
    }
    
    
    for (int i=0; i<create_empty_line; i++)  //参看  数据说明.xlsx，前面从0 到36行，留给ui界面 和UI界面的一些设置，从37行开始，是储存的数据
    {
        /*
         因为前面几7行，insight 有数据是如下，所以从第7行开始，创建新的，防止把insight data 数据污染
         FCT,20200310_v1__oscar_
         Site,Product,SerialNumb
         Display Name ----->,,,,
         PDCA Priority ----->,,,
         Upper Limit ----->,,,,,
         Lower Limit ----->,,,,,
         Measurement Unit ----->
         */
        [_rawData insertObject:@[@""] atIndex:7];  //占位，给UI显示 从第七开始，
        
    }
    
 
        
    
    NSMutableArray *mutArrayReverse = [NSMutableArray arrayWithArray:[self reverseArray:_rawData]];
    //_dataReverse = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:mutArrayReverse]];
    _dataReverse = mutArrayReverse;
    NSUInteger indexItem=0;
    for (int i=0; i<[mutArrayReverse count]; i++)
    {
 
        if ([mutArrayReverse[i] isKindOfClass:[NSArray class]] && [mutArrayReverse[i] count] > 1)
        {
            if (i>=n_Start_Data_Col)  //
            {
                [_data addObject:mutArrayReverse[i]];
                _data[indexItem][tb_index]= [NSNumber numberWithInteger:indexItem+1];  //UI index
                _data[indexItem][tb_item]= mutArrayReverse[i][1];   //UI item;
                _data[indexItem][tb_lower]= mutArrayReverse[i][5];   //UI lower;
                _data[indexItem][tb_upper]= mutArrayReverse[i][4];   //UI upper;
                                                              // number 6 is unit
                _data[indexItem][tb_lsl]= @"";  // UI new LSL
                _data[indexItem][tb_usl]= @"";  // UI new USL
                _data[indexItem][tb_apply]= [NSNumber numberWithInteger:0];  // UI apply button
                _data[indexItem][tb_description]= @"";  // UI description
                _data[indexItem][tb_bc]= @"";  // UI BC
                _data[indexItem][tb_p_val]= @"";  // UI p_val
                _data[indexItem][tb_a_q]= @"";  // UI a_Q
                _data[indexItem][tb_i_irr]= @"";  // UI i_irr
                _data[indexItem][tb_3cv]= @"";  // UI 3CV
                
                _data[indexItem][18]= @"0";  //显示有没有limit zoom in
                _data[indexItem][19]= [NSNumber numberWithInteger:250];  // UI界面设置的bin值
                _data[indexItem][20]= @"";  //zmq 传过给python的item 名字
                _data[indexItem][21]= @"2020/0/0 00:00:00";                               //设置cpk start 开始时间
                _data[indexItem][22]= @"2020/0/0 10:00:00";                               //设置cpk start结束 时间
                _data[indexItem][23]=@""; //设置生成报告的 BC
                _data[indexItem][24]=@"";//设置生成报告的 a_L
                _data[indexItem][25]=@"";//设置生成报告的 a_M
                _data[indexItem][26]=@"";//设置生成报告的 a_L
                _data[indexItem][27]=@"";//设置生成报告的 a_U
                _data[indexItem][28]=@"";//设置生成报告的 a_Q
                _data[indexItem][29]=@"";//设置生成报告的 a_irr
                _data[indexItem][30]=[NSString stringWithFormat:@"%@/CPK_Log",desktopPath];//设置log文件路径 /桌面/CPK_Log
                _data[indexItem][tb_color_by_left]= [NSNumber numberWithInteger:0];  //设置color By左边那个
                _data[indexItem][tb_color_by_right]= [NSNumber numberWithInteger:0];  //设置color By右边那个
                _data[indexItem][button_select_x]= [NSNumber numberWithInteger:0];
                _data[indexItem][button_select_y]= [NSNumber numberWithInteger:0];
                _data[indexItem][tb_script_flag]= [NSNumber numberWithInteger:0]; //设置是否是script数据，insight 数据标志0
                
                _data[indexItem][tb_data]= Start_Data;  //all the test data below
                NSString *itemName = [NSString stringWithFormat:@"%@",mutArrayReverse[i][1]];
                [_indexItemNameDic setValue:itemName forKey:[NSString stringWithFormat:@"%zd",indexItem]];
                // myRedis->SetString([combineItem UTF8String],[[NSString stringWithFormat:@"%@",mutArrayReverse[i]] UTF8String]);
                [_ListAllItemNameArr addObject:itemName];
                indexItem ++;
            }
        }
    }
    
    [self.dataTableView reloadData];
    [m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:K_dic_Load_Csv_Finished];
    return YES;
}

-(NSString *)combineItemName:(NSString *)name
{
    NSString *str_name = @"";
    str_name = [NSString stringWithFormat:@"%@##%@&%@",name,[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]];
    return str_name;
}

-(NSArray *)reverseArray:(NSArray *)array
{
    NSArray *tmpArray = array[1];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:tmpArray.count];
    for (NSInteger i=0; i<tmpArray.count; i++) {
        NSMutableArray *lineArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSInteger j=0; j<array.count; j++) {
            [lineArray addObject:@""];
        }
        [newArray addObject:lineArray];
    }
    
    for (NSInteger i=0; i<array.count; i++) {
        for (NSInteger j=0; j<tmpArray.count; j++) {
            if ([array[i] count]<=j)
            {
                newArray[j][i] = @"";
            }
            else
            {
                newArray[j][i] = array[i][j];
            }
        }
    }
    return newArray;
}

-(void)sendDataToRedis:(NSString *)name withData:(NSMutableArray *)arrData
{
    if (myRedis)
    {
         myRedis->SetString([name UTF8String],[[NSString stringWithFormat:@"%@",arrData] UTF8String]);
    }
    else
    {
        [self AlertBox:@"Warning!!!" withInfo:@"Send data to Redis server error!!!"];
    }
   
    NSLog(@"--->>set name to redis:%@  %zd",name,[arrData count]);
//    NSArray *nameArr = [name componentsSeparatedByString:@"###"];
//    if ([nameArr count]>1)
//    {
//        NSArray *nameArrOp = [nameArr[1] componentsSeparatedByString:@"&"];
//        if ([nameArrOp count]>1)
//        {
//            NSLog(@"==retest: %@  remove: %@",nameArrOp[0],nameArrOp[1]);
//        }
//    }
}


//-(void)setCpkImage:(NSString *)path
//{
//     NSImage *imageCPK = [[NSImage alloc]initWithContentsOfFile:path];
//     dispatch_async(dispatch_get_main_queue(), ^{
//        [self.cpkImageMap setImage:imageCPK];
//    });
//}
//-(void)setCorrelationImage:(NSString *)path
//{
//     NSImage *imageCorrelation = [[NSImage alloc]initWithContentsOfFile:path];
//     dispatch_async(dispatch_get_main_queue(), ^{
//         [self.correlationImageMap setImage:imageCorrelation];
//    });
//}

-(NSString *)sendCpkZmqMsg:(NSString *)name
{
    NSString *file1 = [NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    int ret = [cpkClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [cpkClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendCalculateZmqMsg:(NSString *)name
{
    NSString *path1 = [m_configDictionary valueForKey:Load_Csv_Path];
    NSString *path2 = [NSString stringWithFormat:@"%@/CPK_Log/temp/calculate_param.csv",desktopPath];
    NSString *path3 = [NSString stringWithFormat:@"%@/CPK_Log/temp/.logcalc.txt",desktopPath];
    
    NSString *msg = [NSString stringWithFormat:@"%@$$%@$$%@$$%@",name,path1,path2,path3];  //calculate-param

    int ret = [calculateClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [calculateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python calculate error");
        }
        NSLog(@"app->get response from python calculate: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendCorrelationZmqMsg:(NSString *)name
{
    NSString *file1 = [NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    NSLog(@"---set sendCorrelationZmqMsg:%@",name);
    int ret = [correlationClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->correlation get response from python: %@",response);
        return response;
    }
    return nil;
}


-(NSMutableArray *)removeFailData:(NSInteger)seletRow
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *itemArray = _dataReverse[seletRow+n_Start_Data_Col];
    NSArray *arrayCol = _dataReverse[n_Pass_Fail_Status];
    for (NSInteger i=0; i<[arrayCol count]; i++)
    {
        if (![arrayCol[i] containsString:@"FAIL"]) {
            [tempArray addObject:itemArray[i]];
        }
    }
    return tempArray;
}

-(NSMutableArray *)removeFailDataIndex:(int)removeF
{
    NSMutableArray *tempArray = [NSMutableArray array];
    if (removeF==0)    // remove fail = yes
    {
        NSArray *arrayCol = _dataReverse[n_Pass_Fail_Status];
        for (int i=0; i<[arrayCol count]; i++)
        {
            if ([arrayCol[i] containsString:@"FAIL"]) {
                [tempArray addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    else if (removeF==1) //remove fail = no
    {
       // nothing need to do
    }
    return tempArray;
}

-(NSMutableArray *)addPassDataIndex
{
    NSMutableArray *tempArrayIndex = [NSMutableArray array];
    NSArray *arrayCol = _dataReverse[n_Pass_Fail_Status];
    for (NSInteger i=0; i<[arrayCol count]; i++)
    {
        if (![arrayCol[i] containsString:@"FAIL"]) {
            [tempArrayIndex addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return tempArrayIndex;
}

-(int)compareTime:(NSString*)date01 withDate:(NSString*)date02
{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
        case NSOrderedAscending: ci=1; break;  //date02比date01大
        case NSOrderedDescending: ci=-1; break; //date02比date01小
        case NSOrderedSame: ci=0; break; //date02=date01
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}

-(int)compareStartTime:(NSString*)date01 withDate:(NSString*)date02
{
    if ([date01 isEqualToString:@""])
    {
        return 1;
    }
    long time01 = [self getTimeNumberWithString:date01];
    long time02 = [self getTimeNumberWithString:date02];
    if (time01>time02)
    {
        return -1;
    }
    else if (time01<time02)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

-(int)compareStartTime2:(NSString*)date01 withDate:(NSString*)date02
{
    if ([date01 isEqualToString:@""])
    {
        return -1;
    }
    long time01 = [self getTimeNumberWithString:date01];
    long time02 = [self getTimeNumberWithString:date02];
    if (time01>time02)
    {
        return -1;
    }
    else if (time01<time02)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


//字符串转时间戳 如：2017-4-10 17:15:10
- (NSString*)getTimeStrWithString:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    if ([str length]>17)
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    }
    else
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    }
    NSDate *tempDate = [dateFormatter dateFromString:str];//将字符串转换为时间对象
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];//字符串转成时间戳,精确到毫秒*1000
    return timeStr;
}

- (long)getTimeNumberWithString:(NSString *)str{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    if ([str length]>17)
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    }
    else
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"]; //设定时间的格式
    }
    NSDate *tempDate = [dateFormatter dateFromString:str];//将字符串转换为时间对象
    return (long)[tempDate timeIntervalSince1970];
}

-(NSMutableArray *)failPassItemDataIndex:(NSInteger)seletRow withRemoveOption:(int)removeF
{
    NSMutableArray *dataTemp = nil;
    if (removeF==0)    // remove fail = yes
    {
        dataTemp = [self removeFailData:seletRow];
    }
    else if (removeF==1) //remove fail = no
    {
        dataTemp = _dataReverse[seletRow+n_Start_Data_Col];
    }
    return dataTemp;
}

-(NSArray *)getItemDataIndexWithRetestOption:(int)retestSeg withRemoveOption:(int)removeFSeg
{
    if (retestSeg == 1)   // retest = all
    {
        return nil;
    }
    
    NSMutableArray *snArray = _dataReverse[n_SerialNumber];
    NSMutableArray *startTimeArray = _dataReverse[n_StartTime];
    NSArray *arrayFailPass = _dataReverse[n_Pass_Fail_Status];
    
    NSMutableArray *arrayUnique = [NSMutableArray array];
    NSMutableArray *arraySame = [NSMutableArray array];
    for (unsigned i = 0; i<[snArray count]; i++)
    {
        if ([arrayUnique containsObject:[snArray objectAtIndex:i]] == NO)
        {
            [arrayUnique addObject:[snArray objectAtIndex:i]];
        }
        else
        {
            [arraySame addObject:[snArray objectAtIndex:i]];
            
        }
    }
    NSSet *setX = [NSSet setWithArray:arraySame];
    NSArray * arrayD = [setX allObjects];
    
    NSMutableArray *timeArrIndex = [NSMutableArray array];   //retest 选项所有相同的元素 索引
    NSMutableArray *timeArrMaxIndex = [NSMutableArray array];   //retest last 即时间最大元素
    if ([arrayD count] >0)
    {
        for (NSString *snDuplicate in arrayD)
        {
            if (snDuplicate && [snDuplicate isNotEqualTo:@""])
            {
                NSString * maxStartTime=@"";
                int maxTimeIndex = 0;
                int ii=0;
                for (NSString *object in snArray)
                {
                    if ([snDuplicate isEqualToString:object])
                    {
                        [timeArrIndex addObject:[NSNumber numberWithInt:ii]];
                        if (retestSeg == 0)  // retest first
                        {
                            int result = [self compareStartTime:maxStartTime withDate:startTimeArray[ii]];
                            //NSLog(@"====retult: %d",result);
                            if(result==1)
                            {
                                if (removeFSeg == 0)
                                {
                                    if (![arrayFailPass[ii] containsString:@"FAIL"])
                                    {
                                        maxStartTime = startTimeArray[ii];
                                        maxTimeIndex = ii;
                                    }
                                }
                                else
                                {
                                    maxStartTime = startTimeArray[ii];
                                    maxTimeIndex = ii;
                                }
                            }
                        }
                        else if (retestSeg == 2)  //retest last
                        {
                            int result = [self compareStartTime2:maxStartTime withDate:startTimeArray[ii]];
                            //NSLog(@"====1 retult: %d",result);
                            if(result==-1)
                            {
                                if (removeFSeg == 0)  // remove fail=yes
                                {
                                    if (![arrayFailPass[ii] containsString:@"FAIL"])
                                    {
                                        maxStartTime = startTimeArray[ii];
                                        maxTimeIndex = ii;
                                    }
                                }
                                else  // remove fail=no
                                {
                                    maxStartTime = startTimeArray[ii];
                                    maxTimeIndex = ii;
                                }
                            }
                        }

                    }
                    ii++;
                }
                [timeArrMaxIndex addObject:[NSNumber numberWithInt:maxTimeIndex]];
                //NSLog(@"**************");
            }

        }
    }
    
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",timeArrMaxIndex];
    NSArray * filterLast = [timeArrIndex filteredArrayUsingPredicate:filterPredicate];  //==剔除Last 之前数据
    //NSLog(@"===剔除Last 之前数据 : %@  %@   %@",timeArrIndex,timeArrMaxIndex,filterLast);
    //NSLog(@"---end--");
    return filterLast;
}

-(NSMutableArray *)getItemDataWithRetestIndex:(NSArray *)filterData withRemoveFailIndex:(NSArray *)filterData2 bySelectRow:(NSInteger )seletRow  //根据index 删除数据
{
    NSMutableArray *itemArray = _dataReverse[seletRow+n_Start_Data_Col];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<[itemArray count]; i++)
    {
        if (![filterData containsObject:[NSNumber numberWithInt:i]] && ![filterData2 containsObject:[NSNumber numberWithInt:i]])
        {
           [tempArray addObject:itemArray[i]];
        }
    }
    //NSLog(@"====tempArray==>> %zd  %@",[tempArray count],tempArray);
    NSLog(@"====tempArray==>> %zd",[tempArray count]);
    return tempArray;
}

-(NSMutableArray *)getItemDataWithRetestIndex:(NSArray *)filterData bySelectRow:(NSInteger )seletRow  //根据index 删除数据
{
    NSMutableArray *itemArray = _dataReverse[seletRow+n_Start_Data_Col];
    NSMutableArray *tempArray = [NSMutableArray array];
   // NSString * max_time=_dataReverse[n_StartTime][0];
    //NSString * min_time = @"";
    for (int i=0; i<[itemArray count]; i++)
    {
        if (![filterData containsObject:[NSNumber numberWithInt:i]])
        {
           [tempArray addObject:itemArray[i]];
//            if ([_dataReverse[n_StartTime][i] isNotEqualTo:@"StartTime"] &&[_dataReverse[n_StartTime][i] isNotEqualTo:@""])  //这里如果获取时间大小，浪费时间
//            {
//                if ([self compareStartTime:max_time withDate:_dataReverse[n_StartTime][i]]==1)
//                {
//                    max_time = _dataReverse[n_StartTime][i];
//                }
//
//                if ([self compareStartTime2:min_time withDate:_dataReverse[n_StartTime][i]]==-1)
//                {
//                             min_time = _dataReverse[n_StartTime][i];
//                }
//            }
         
        }
    }
//    tempArray[21] = min_time;
//    tempArray[22] = max_time;
    [tempArray addObject:End_Data];
    //NSLog(@"====tempArray==>> %zd  %@",[tempArray count],tempArray);
//    NSLog(@"====tempArray==>> %zd",[tempArray count]);
    return tempArray;
}

-(NSMutableArray *)calculateData:(NSInteger )seletRow withRetest:(NSString *)opt1 withRemove:(NSString *)opt2
{
   // retest: first=0 all=1,last=2
    //remove fail: yes=0, no=1
    int retest = 0;
    int removeF = 0;
    if ([opt1 isEqualToString:vRetestAll] && [opt2 isEqualToString:vRemoveFailYes])
    {
        retest = 1;
        removeF = 0;
    }
    else if ([opt1 isEqualToString:vRetestAll] && [opt2 isEqualToString:vRemoveFailNo])
    {
        // for save time no need do anything
        retest = 1;
        removeF = 1;
        return _dataReverse[seletRow+n_Start_Data_Col];
    }
    else if ([opt1 isEqualToString:vRetestFirst] && [opt2 isEqualToString:vRemoveFailYes])
    {
        retest = 0;
        removeF = 0;
    }
    else if ([opt1 isEqualToString:vRetestFirst] && [opt2 isEqualToString:vRemoveFailNo])
    {
        retest = 0;
        removeF = 1;
    }
    else if ([opt1 isEqualToString:vRetestLast] && [opt2 isEqualToString:vRemoveFailYes])
    {
        retest = 2;
        removeF = 0;
    }
    else if ([opt1 isEqualToString:vRetestLast] && [opt2 isEqualToString:vRemoveFailNo])
    {
        retest = 2;
        removeF = 1;
    }
    else{
        return [NSMutableArray arrayWithObject:@[@"0"]];
    }
    
    NSMutableArray * removeArrIndex = [self removeFailDataIndex:removeF];
    //NSLog(@"===11==> %@",removeArrIndex);
    NSArray *arrIndex = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    //NSLog(@"===22==> %@",arrIndex);
    return [self getItemDataWithRetestIndex:removeArrIndex withRemoveFailIndex:arrIndex bySelectRow:seletRow];
    
}

-(NSMutableArray *)calculateData:(NSInteger )seletRow
{

    NSString *opt1 = [m_configDictionary valueForKey:kRetestSeg];
    NSString *opt2 = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *dic_key = [NSString stringWithFormat:@"%@&%@",opt1,opt2];
    NSMutableArray *indexArr = [m_configDictionary valueForKey:dic_key];
    //NSLog(@"===%%>> %@",indexArr);
    return [self getItemDataWithRetestIndex:indexArr bySelectRow:seletRow];
}



-(void)initRetestAndRemoveFailSeg
{
    int removeF = 0;  //RemoveFail=Yes
    int retest = 1;  //Retest=All
    NSMutableArray * removeArrIndex0 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex0 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex0 count]; i++)
    {
        [removeArrIndex0 addObject:retestArrIndex0[i]];
    }
    [m_configDictionary setObject:removeArrIndex0 forKey:k_dic_RetestAll_RemoveFailYes];
    
    
    removeF = 1; // RemoveFail=No
    retest = 1; //Retest=All
    NSMutableArray * removeArrIndex1 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex1 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex1 count]; i++)
    {
        [removeArrIndex1 addObject:retestArrIndex1[i]];
    }
    [m_configDictionary setObject:removeArrIndex1 forKey:k_dic_RetestAll_RemoveFailNo];
    
    removeF = 0; // RemoveFail=Yes
    retest = 0; //Retest=First
    NSMutableArray * removeArrIndex2 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex2 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex2 count]; i++)
    {
        [removeArrIndex2 addObject:retestArrIndex2[i]];
    }
    [m_configDictionary setObject:removeArrIndex2 forKey:k_dic_RetestFirst_RemoveFailYes];
    
    removeF = 1; // RemoveFail=No
    retest = 0; //Retest=First
    NSMutableArray * removeArrIndex3 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex3 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex3 count]; i++)
    {
        [removeArrIndex3 addObject:retestArrIndex3[i]];
    }
    [m_configDictionary setObject:removeArrIndex3 forKey:k_dic_RetestFirst_RemoveFailNo];
    
    retest = 2; //Retest=Last
    removeF = 0; //RemoveFail=Yes
    NSMutableArray * removeArrIndex4 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex4 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex4 count]; i++)
    {
        [removeArrIndex4 addObject:retestArrIndex4[i]];
    }
    [m_configDictionary setObject:removeArrIndex4 forKey:k_dic_RetestLast_RemoveFailYes];

    retest = 2; //Retest=Last
    removeF = 1; //vRemoveFail=No
    NSMutableArray * removeArrIndex5 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex5 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
     for (int i=0; i<[retestArrIndex5 count]; i++)
     {
         [removeArrIndex5 addObject:retestArrIndex5[i]];
     }
     [m_configDictionary setObject:removeArrIndex5 forKey:k_dic_RetestLast_RemoveFailNo];
    
}

-(void)initColorByTableView
{
    //version
    NSArray *arrayVer = _dataReverse[n_Version_Col];
    NSSet *set = [NSSet setWithArray:arrayVer];
    NSArray *tempVer = [set allObjects];
    NSMutableArray *vers = [NSMutableArray array];
    for (int i=0; i<[tempVer count]; i++)
    {
        if ([tempVer[i] isNotEqualTo:@""] && [[tempVer[i] uppercaseString] isNotEqualTo:@"VERSION"])
        {
            [vers addObject:tempVer[i]];
        }
    }
    [m_configDictionary setObject:vers forKey:k_dic_Version];
    
    // station id
     NSArray *arrayStations = _dataReverse[n_StationID_Col];
     NSSet *setStation = [NSSet setWithArray:arrayStations];
     NSArray *tempId = [setStation allObjects];
     NSMutableArray *IDs = [NSMutableArray array];
     for (int i=0; i<[tempId count]; i++)
     {
         if ([tempId[i] isNotEqualTo:@""] && [[tempId[i] uppercaseString] isNotEqualTo:@"STATION ID"])
         {
             [IDs addObject:tempId[i]];
         }
     }
     [m_configDictionary setObject:IDs forKey:k_dic_Station_ID];
    
    //Special Build Name
    NSArray *arrayBuildN = _dataReverse[n_SpecialBuildName_Col];
    NSSet *setBuild = [NSSet setWithArray:arrayBuildN];
    NSArray *tempBuildN = [setBuild allObjects];
    NSMutableArray *BuildNs = [NSMutableArray array];
    for (int i=0; i<[tempBuildN count]; i++)
    {
        if ([tempBuildN[i] isNotEqualTo:@""] && [[tempBuildN[i] uppercaseString] isNotEqualTo:@"SPECIAL BUILD NAME"])
        {
            [BuildNs addObject:tempBuildN[i]];
        }
    }
    [m_configDictionary setObject:BuildNs forKey:k_dic_Special_Build_Name];
    
    //Special Build Description
    NSArray *arrayBuildD = _dataReverse[n_Special_Build_Descrip_Col];
    NSSet *setBuildD = [NSSet setWithArray:arrayBuildD];
    NSArray *tempBuildD = [setBuildD allObjects];
    NSMutableArray *BuildDe = [NSMutableArray array];
    for (int i=0; i<[tempBuildD count]; i++)
    {
        if ([tempBuildD[i] isNotEqualTo:@""] && [[tempBuildD[i] uppercaseString] isNotEqualTo:@"SPECIAL BUILD DESCRIPTION"])
        {
            [BuildDe addObject:tempBuildD[i]];
        }
    }
    [m_configDictionary setObject:BuildDe forKey:k_dic_Special_Build_Desc];
    
    //Product
    NSArray *arrayProduct = _dataReverse[n_Product_Col];
    NSMutableArray *Produc = [NSMutableArray array];
    for (int i=tb_data_start; i<[arrayProduct count]; i++)
    {
        if ([arrayProduct[i] isNotEqualTo:@""] && [[arrayProduct[i] uppercaseString] isNotEqualTo:@"PRODUCT"])
        {
            [Produc addObject:arrayProduct[i]];
        }
    }
    
    NSSet *setProduct = [NSSet setWithArray:Produc];
    NSArray *tempProduct = [setProduct allObjects];
    [m_configDictionary setObject:tempProduct forKey:k_dic_Product];
    
    //channel id
    int index_channelId = 0;
    NSString *keyWord =  @"FIXTURE CHANNEL ID";
    NSString *keyWord2 = @"FIXTURE INITILIZATION SLOT_ID";//@"Fixture Initilization SLOT_ID";
    NSString *keyWord3 = @"FIXTURE RESET CALC FIXTURE_CHANNEL";//@"Fixture Reset CALC fixture_channel";
    NSString *keyWord4 = @"HEAD ID";//@"Head Id";
    /*for (int i=0; i<[_rawData[1] count]; i++)
    {
        if ([[_rawData[1][i] uppercaseString] isEqualToString:keyWord] || [[_rawData[1][i] uppercaseString] isEqualToString:keyWord2]||[[_rawData[1][i] uppercaseString] isEqualToString:keyWord3]||[[_rawData[1][i] uppercaseString] isEqualToString:keyWord4])
        {
            index_channelId = i;
            break;
        }
        
    }*/
    
    for (int i=0; i<[_ListAllItemNameArr count]; i++)
      {
          if ([[_ListAllItemNameArr[i] uppercaseString] isEqualToString:keyWord] || [[_ListAllItemNameArr[i] uppercaseString] isEqualToString:keyWord2]||[[_ListAllItemNameArr[i] uppercaseString] isEqualToString:keyWord3]||[[_ListAllItemNameArr[i] uppercaseString] isEqualToString:keyWord4])
          {
              index_channelId = i;
              break;
          }
          
      }
    
    index_channelId = index_channelId+ n_Start_Data_Col;
    [m_configDictionary setObject:[NSNumber numberWithInt:index_channelId] forKey:k_dic_Channel_ID_Index];
    if (index_channelId>=n_Start_Data_Col)
    {
        NSArray *arrayChannel = _dataReverse[index_channelId];
        NSMutableArray *channels = [NSMutableArray array];
        for (int i=tb_data_start; i<[arrayChannel count]; i++)
        {
//            if ([arrayChannel[i] isNotEqualTo:@""])
//            {
//                [channels addObject:arrayChannel[i]];
//            }
             if ([arrayChannel[i] isEqualToString:@""])
             {
                 [channels addObject:@"NULL"];
             }
            else
            {
                [channels addObject:arrayChannel[i]];
            }
        }
        NSSet *setChannel = [NSSet setWithArray:channels];
        NSArray *channelIDs = [setChannel allObjects];
        [m_configDictionary setObject:channelIDs forKey:k_dic_Channel_ID];
    }
    else
    {
        [self AlertBox:@"warning!" withInfo:@"Please set channel ID!!!"];
        [m_configDictionary setObject:@[@"NULL"] forKey:k_dic_Channel_ID];
    }
  
     // station id & channel id
     /*if (index_channelId>0)
     {
         NSMutableArray *staionChannel = [NSMutableArray array];
         NSArray *arrayChannel = _dataReverse[index_channelId];
         for (int i=27; i<[arrayStations count]; i++)  //从第7行开始
         {
             [staionChannel addObject:[NSString stringWithFormat:@"%@ & %@",arrayStations[i],arrayChannel[i]]];
         }
        
         NSSet *setStationChannel = [NSSet setWithArray:staionChannel];
         NSArray *stationChannelID = [setStationChannel allObjects];
         [m_configDictionary setObject:stationChannelID forKey:k_dic_Station_Channel_ID];
     }
    else
    {
         [m_configDictionary setObject:@[@"NULL"] forKey:k_dic_Station_Channel_ID];
    }
    */
    
}

#pragma mark TableView Datasource & delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_data count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnIdentifier = [tableColumn identifier];
    NSTableCellView *view = [_dataTableView makeViewWithIdentifier:columnIdentifier owner:self];
    NSUInteger index = -1;
    if ([columnIdentifier isEqualToString:@"index"])
    {
     
        index = tb_index;
        NSArray *subviews = [view subviews];
        NSTextField *txtField = subviews[0];
        if ([_colorRedIndex count]>0 || [_colorGreenIndex count]>0)
        {
            if ([_colorGreenIndex containsObject:[NSNumber numberWithInteger:row]])
              {
                 txtField.drawsBackground = YES;
                 txtField.backgroundColor = [NSColor greenColor];
              }

            if ([_colorRedIndex containsObject:[NSNumber numberWithInteger:row]])
               {
                  txtField.drawsBackground = YES;
                  txtField.backgroundColor = [NSColor systemRedColor];
               }
             if (![_colorGreenIndex containsObject:[NSNumber numberWithInteger:row]] && ![_colorRedIndex containsObject:[NSNumber numberWithInteger:row]])
                  {
                      txtField.drawsBackground = YES;
                      txtField.backgroundColor = [NSColor grayColor];
                  }
            
        }
        else
        {
            txtField.drawsBackground = NO;
        }
    }
    if ([columnIdentifier isEqualToString:@"item"]){
        index = tb_item;
    }
    if ([columnIdentifier isEqualToString:@"low"]){
        index = tb_lower;

    }
    if ([columnIdentifier isEqualToString:@"upper"]){
        index = tb_upper;
    }
    if ([columnIdentifier isEqualToString:@"lsl"]){
        index = tb_lsl;
    }
    if ([columnIdentifier isEqualToString:@"usl"]) {
        index = tb_usl;
    }
    if ([columnIdentifier isEqualToString:@"apply"]) {
        NSArray *subviews = [view subviews];
        NSButton *checkBoxField = subviews[0];
        checkBoxField.tag = row;
        checkBoxField.target = self;
        [checkBoxField setAction:@selector(btnClickApply:)];
        
        index = tb_apply;
        if ([[_data objectAtIndex:row] count]>index)
        {
            [checkBoxField setState:[[_data objectAtIndex:row][index] intValue]];
        }
        return view;
        
    }
    if ([columnIdentifier isEqualToString:@"description"]) {
         index = tb_description;
    }
    if ([columnIdentifier isEqualToString:@"bc"]) {
         index = tb_bc;
    }
    if ([columnIdentifier isEqualToString:@"p_val"]) {
         index = tb_p_val;
    }
    if ([columnIdentifier isEqualToString:@"a_q"]) {
         index = tb_a_q;
    }
    if ([columnIdentifier isEqualToString:@"a_irr"]) {
         index = tb_i_irr;
    }
    if ([columnIdentifier isEqualToString:@"3cv"]) {
         index = tb_3cv;
    }
//    if (index == -1)
//    {
//        return nil;
//    }

    if ([[_data objectAtIndex:row] count]>index)
    {
        [[view textField] setStringValue:[_data objectAtIndex:row][index]];
    }
    else
    {
         [[view textField] setStringValue:@""];
    }
    return view;
}


- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row;
{
    NSLog(@"====edit:  %@",object);
}

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    NSInteger row =self.dataTableView.selectedRow;
    editLimitRow = row;
}

- (BOOL)isAllNum:(NSString *)string{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string{
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filter];

}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}

-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *textF =obj.object;
    NSInteger row =self.dataTableView.selectedRow;
    NSInteger col = [self.dataTableView columnForView:textF];
    NSString *identifier = self.dataTableView.tableColumns[col].identifier;
    NSLog(@"===edit==>identifier: %@   row:%zd  col:%zd  %@",identifier,row,col,textF.stringValue);
    //NSString *key = [NSString stringWithFormat:@"%zd-%zd",row,col];
    //[_textEditLimitDic setValue:textF.stringValue forKey:key];
    if (col == 4 || col == 5)
    {
        if(![self isOnlyhasNumberAndpointWithString:textF.stringValue])
        {
            [self AlertBox:@"Error!" withInfo:@"Please input number type!"];
            [self.dataTableView reloadData];
            return;
        }

        if (row ==-1)
        {
            row = editLimitRow;
        }
        if (row>=0 && row<[_data count])
        {
            _data[row][col+3] = [NSString stringWithFormat:@"%@",[textF stringValue]];
        }
    }
}

- (void)keyDown:(NSEvent *)event
{
    if (![self.dataTableView isAccessibilityFocused])
    {
        NSLog(@"====not foucus on editor view");
        return;
    }
    
    if(![self.dataTableView selectedCell])
    {
        
        if (event.isCommandDown)
        {
            if ([event.characters isEqual:@"c"])  //copy
            {
                if([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)
                {
                    return;
                }
                NSLog(@"====>copy ");
            }
            else if ([event.characters isEqual:@"v"])  //paste
            {
                if(!enableEditing)
                {
                    return;
                }
                NSLog(@"====>paste ");
                [self.dataTableView reloadData];
                //[self paste:nil];
            }
            else if ([event.characters isEqual:@"x"])  //cut
            {
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1) || !enableEditing)
                {
                    return;
                }
                NSLog(@"====>cut ");
                [self.dataTableView reloadData];
               // [self cut:nil];
            }
            else if ([event.characters isEqual:@"z"])  // undo
            {
                [self.undoManager undo];
                NSLog(@"====>undo ");
            }
            else if (event.isShiftDown && [event.characters isEqual:@"z"])  // redo
            {
                [self.undoManager redo];
                NSLog(@"====>redo ");
            }
            else
            {
                return;
            }
        }
        else if (event.isShiftDown)
        {
            NSLog(@"isShiftDown");
        }
        else if (event.isOptionDown)
        {
            NSLog(@"isOptionDown");
        }
        else if (event.isControlDown)
        {
            NSLog(@"isControlDown");
        }
        else
        {
            unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
            if(key == NSDeleteCharacter)
            {
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)|| !enableEditing)
                {
                    return;
                }
                //[self delete:nil];
                NSLog(@"====>delete :%x",key);
                [self.dataTableView reloadData];
                return;
            }
            if(key == 0xf700)
            {
                NSLog(@"==>%@  %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)|| !enableEditing)
                {
                    return;
                }
                NSInteger selectRow = [self.dataTableView selectedRow]-1;
                if (selectRow < 0)
                {
                    selectRow = [self.dataTableView selectedRow];
                }
                
                _data[selectRow][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
                 _data[selectRow][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
                
                
                NSInteger rowActual = 0;
                for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
                {
                    if ([_ListAllItemNameArr[i] isEqualToString:_data[selectRow][1]])
                    {
                        rowActual = i;
                        break;
                    }
                }
                
                
                tbDataTableSelectItemRow = rowActual;
                if (selectColorBoxIndex > 0 ) //color by 打开，用color by 那边发指令给python
                {
                    //NSDictionary *dic = [NSDictionary dictionaryWithObject:[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] forKey:applyBoxCheck];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
                }
                else if(selectColorBoxIndex2>0 )
                {
                     [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
                }
                else  // color by 关闭。直接发指令给python
                {
                    NSString * itemName = [self combineItemName:[_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]]];
                    NSLog(@"====>down key :%x row: %ld   item name: %@",key,rowActual,itemName);
                    // 写发送代码
                    // NSMutableArray *itemArray = _dataReverse[selectRow+n_Start_Data_Col];
                    NSMutableArray * itemData = [self calculateData:rowActual];
                    [self sendDataToRedis:itemName withData:itemData];
                    [self sendCpkZmqMsg:itemName];
                    [self sendCorrelationZmqMsg:itemName];
//                    NSString *pic = [self sendCpkZmqMsg:itemName];
//                    NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/%@",desktopPath,pic];
//                    [self notifySetImage:path];
                }
                return;
            }
            if(key == 0xf701)
            {
                NSLog(@"==>%@  %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)|| !enableEditing)
                {
                    return;
                }
                NSInteger selectRow = [self.dataTableView selectedRow]+1;
                if (selectRow >= [_data count])
                {
                    selectRow = [self.dataTableView selectedRow];
                }
                
                _data[selectRow][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
                _data[selectRow][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By right那个,给python生成图表用
                
                
                NSInteger rowActual = 0;
                for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
                {
                    if ([_ListAllItemNameArr[i] isEqualToString:_data[selectRow][1]])
                    {
                        rowActual = i;
                        break;
                    }
                }
                
                tbDataTableSelectItemRow = rowActual;
                if (selectColorBoxIndex > 0) //color by 打开，用color by 那边发指令给python
                {
                    
                   // NSDictionary *dic = [NSDictionary dictionaryWithObject:[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] forKey:applyBoxCheck];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
                }
                else if(selectColorBoxIndex2>0)
                {
                     [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
                }
                else  // color by 关闭。直接发指令给python
                {
                    NSString * itemName = [self combineItemName:[_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]]];
                    NSLog(@"====>down key :%x row: %ld   item name: %@",key,rowActual,itemName);
                     //写发送代码
                    // NSMutableArray *itemArray = _dataReverse[selectRow+n_Start_Data_Col];
                    //NSLog(@"--ClickOnTableView--:%zd  selectColorBoxIndex:%d, item name : %@",selectRow,selectColorBoxIndex,itemName);
                    NSMutableArray * itemData = [self calculateData:rowActual];
                    NSLog(@"==<>>> %zd",[itemData count]);
                    [self sendDataToRedis:itemName withData:itemData];
                    [self sendCpkZmqMsg:itemName];
                    [self sendCorrelationZmqMsg:itemName];
//                    NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/%@",desktopPath,pic];
//                    [self notifySetImage:path];
                   
                }

                return;
            }
            NSLog(@"no shorcut: %x",key);
        }
    }
    else
    {
        NSLog(@"nothing");
    }
}


-(void)notifySetImage:(NSString *)path
{
    //NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
    //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkImage object:nil userInfo:dic];
}


#pragma mark NSSplitViewDelegate methods

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    if (subview == self.leftPane)
    {
        return YES;
    }
    else if (subview == self.rightPanel)
    {
        return YES;
    }
    
    return NO;
}


-(void)LoadSubView:(NSView *)view
{
    [[leftViewMain superview] replaceSubview:leftViewMain with:view];
    [view setFrame:[leftViewMain frame]];
    leftViewMain = view;
    //[self loadView];
}
//
-(void)setLoadCsvView:(NSView *)view
{
    [self replaceView:csvViewMain with:view];
    csvViewMain =view;
}
-(void)replaceView:(NSView *)oldView with:(NSView *)newView
{
    [newView setFrame:[oldView frame]];
    [[oldView superview] addSubview:newView];
    [[oldView superview] replaceSubview:oldView with:newView];
    [oldView setHidden:YES];
}

@end
