//
//  dataPlotView.m
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "dataPlotView.h"
#import "defineHeader.h"
#import "RedisInterface.hpp"
#import "Client.h"
#import "reportSettingCfg.h"

NSMutableDictionary *m_configDictionary;
NSInteger tbDataTableSelectItemRow;

NSMutableArray *_dataReverse;
NSMutableArray *_rawData;
int selectColorBoxIndex;   //left color by
int selectColorBoxIndex2;  //right color by


extern RedisInterface *myRedis;
extern Client *cpkClient;
extern Client *correlationClient;
extern Client *calculateClient;
extern Client *reportClient;



extern int n_Start_Data_Col;
extern int n_Pass_Fail_Status;
extern int n_Product_Col;
extern int n_SerialNumber;
extern int n_SpecialBuildName_Col;
extern int n_Special_Build_Descrip_Col;
extern int n_StationID_Col;
extern int n_StartTime;
extern int n_Version_Col;

@interface dataPlotView ()
{
    NSMutableArray * lastItemSelectColorTbLeft;   //记录上次结果
    NSMutableArray * lastItemSelectColorTbRight;   //记录上次结果
    
    NSInteger lastTbDataTableSelectItemRow;//记录上次结果
    NSString *desktopPath;
    
    int n_select_x;
    int n_select_y;
    NSArray *colorByName;
}
@property (nonatomic,strong)NSMutableArray *data;  //left color by data
@property (nonatomic,strong)NSMutableArray *data2;  //right color by data

@property(strong) reportSettingCfg *reportSetWin;
@end

@implementation dataPlotView

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _data = [[NSMutableArray alloc]init];
        _data2 = [[NSMutableArray alloc]init];
        m_configDictionary = [[NSMutableDictionary alloc]init];
        _rawData = [[NSMutableArray alloc]init];
        _dataReverse = [[NSMutableArray alloc]init];
        tbDataTableSelectItemRow = -1;
        lastTbDataTableSelectItemRow = -1;
        selectColorBoxIndex = 0;  //left
        selectColorBoxIndex2 = 0;  //right
        lastItemSelectColorTbLeft = [NSMutableArray array];
        lastItemSelectColorTbRight = [NSMutableArray array];
        
        n_select_x=0;
        n_select_y=0;
        colorByName = @[Off,Version,Station_ID,Special_Build_Name,Special_Build_Descrip,Product,Channel_ID];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_colorByTableView setDelegate:self];
    [_colorByTableView setDataSource:self];
    [_colorByTableView2 setDelegate:self];
    [_colorByTableView2 setDataSource:self];
    [self initColorTabView:nil];
    
    desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_ApplyBoxCheck];
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    
    //left color by
    [self.colorByTableView setDoubleAction:@selector(DblClickOnTableView:)];
    [self.colorByTableView setAction:@selector(DblClickOnTableView:)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DblClickOnTableView:) name:kNotificationClickPlotTable object:nil];
    //right color by
    [self.colorByTableView2 setDoubleAction:@selector(DblClickOnTableView2:)];
    [self.colorByTableView2 setAction:@selector(DblClickOnTableView2:)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DblClickOnTableView2:) name:kNotificationClickPlotTable2 object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ClickOnSelectXY:) name:kNotificationClickPlotTable_selectXY object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initColorTabView:) name:kNotificationInitColorTable object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUiImage:) name:kNotificationSetCpkImage object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUiImage:) name:kNotificationSetCorrelationImage object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
    [self.sliderL setHidden:YES];
    [self.sliderR setHidden:YES];
}
-(NSMutableArray *)getNeedDeletDataIndex  //更具UI retest 和remove fail 按钮，移除相关index 数据
{
    NSString *opt1 = [m_configDictionary valueForKey:kRetestSeg];
    NSString *opt2 = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *dic_key = [NSString stringWithFormat:@"%@&%@",opt1,opt2];
    NSMutableArray *indexArr = [m_configDictionary valueForKey:dic_key];
    //NSLog(@"====>>>>>delet: %@",indexArr);
    return indexArr;
}

-(void)OnTimer:(NSTimer *)timer
{
    NSString *pathcpk = [NSString stringWithFormat:@"%@/CPK_Log/temp/.logcpk.txt",desktopPath];
    NSString *logcpk = [NSString stringWithContentsOfFile:pathcpk encoding:NSUTF8StringEncoding error:nil];
    if ([logcpk containsString:@"PASS"]|| [logcpk containsString:@"FAIL"])
    {
        [@"none" writeToFile:pathcpk atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkImage object:nil userInfo:dic];
        NSLog(@"====set cpk pic===");
    }
    NSString *pathcor = [NSString stringWithFormat:@"%@/CPK_Log/temp/.logcor.txt",desktopPath];
    NSString *logcor = [NSString stringWithContentsOfFile:pathcor encoding:NSUTF8StringEncoding error:nil];
    if ([logcor containsString:@"PASS"]||[logcor containsString:@"FAIL"])
    {
        [@"none" writeToFile:pathcor atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCorrelationImage object:nil userInfo:dic];
        NSLog(@"====set correlation pic===");
    }
    
    NSString *pathcalc = [NSString stringWithFormat:@"%@/CPK_Log/temp/.logcalc.txt",desktopPath];
    NSString *logcalc = [NSString stringWithContentsOfFile:pathcalc encoding:NSUTF8StringEncoding error:nil];
    BOOL isFinished = [[m_configDictionary valueForKey:K_dic_Load_Csv_Finished] boolValue];
    if ([logcalc containsString:@"PASS"] && isFinished)
    {
        // update UI display
         [@"none" writeToFile:pathcalc atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = [NSString stringWithFormat:@"%@/CPK_Log/temp/calculate_param.csv",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:paramPath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetParameters object:nil userInfo:dic];
        
    }
    
}

-(void)initColorTabView:(NSNotification *)nf
{
    //NSDictionary* info = [nf userInfo];
    if ([[nf name] isEqualToString:kNotificationInitColorTable])
    {
        [self.retestSegment setSelectedSegment:1];
        [self.removeFailSegment setSelectedSegment:0];
        [m_configDictionary setValue:[self switchRetest:1] forKey:kRetestSeg];
        [m_configDictionary setValue: [self switchRemoveFail:0] forKey:kRemoveFailSeg];
        NSLog(@"=1=> %@ %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
        [self.txtBins setIntValue:250];
        [m_configDictionary setValue:[NSString stringWithFormat:@"%@",@"250"] forKey:kBins];
        
        [self.colorByBox removeAllItems];
        [self.colorByBox addItemsWithObjectValues:colorByName];
        [self.colorByBox selectItemAtIndex:0];
        
        [self.colorByBox2 removeAllItems];
        [self.colorByBox2 addItemsWithObjectValues:colorByName];
        [self.colorByBox2 selectItemAtIndex:0];
        
        NSString *picPath =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
        [self setCpkImage:picPath];
        [self setCorrelationImage:picPath];
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsRight];
        [_data removeAllObjects];
        [_data2 removeAllObjects];
        selectColorBoxIndex = 0;
        selectColorBoxIndex2 = 0;
        [self.colorByTableView reloadData];
    }
}

-(void)setUiImage:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationSetCpkImage])
    {
        NSDictionary * dic = [nf userInfo];
        NSString * path = [dic valueForKey:imagePath];
        [self setCpkImage:path];
    }
    else if([ name isEqualToString:kNotificationSetCorrelationImage])
    {
        NSDictionary * dic = [nf userInfo];
        NSString * path = [dic valueForKey:imagePath];
        [self setCorrelationImage:path];
    }
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
    //NSLog(@"--->>set name to redis:%@  %@",name,arrData);
}

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

-(NSString *)sendCorrelationZmqMsg:(NSString *)name
{
    
    NSString *file1 = [NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    
    int ret = [correlationClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)combineItemName:(NSString *)name
{
    NSString *str_name = @"";
    // 传过来的的name 后面已经有##，因name 是自动往后拼接的##
    str_name = [NSString stringWithFormat:@"%@%@&%@",name,[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]];
    return str_name;
}

-(void)toClickOnTableView:(NSNotification *)nf
{
    
}


-(void)ClickOnSelectXY:(NSNotification *)nf
{
    NSDictionary * dic = [nf userInfo];
    int xy = [[dic valueForKey:selectXY] intValue];
    [self getTwoColorTableDataAndSend:xy];
}

-(IBAction)DblClickOnTableView:(id )sender
{

    NSInteger row = [self.colorByTableView selectedRow];
    if (row == -1 && selectColorBoxIndex2 == 0)
    {
        NSLog(@"--select item is wrong---!!!");
        return;
    }
    
//    NSDictionary * dic = [nf userInfo];
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];
    //NSLog(@"==>row:%zd  %@  %@  bin:%@",row,[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg],[m_configDictionary valueForKey:kBins]);
    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView selectedRowIndexes];
    if ([rowIndexes count]) {
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [selectItem addObject:_data[idx]];
        }];
        //NSLog(@"==selectItem:>>> %@   tbDataTableSelectItemRow:%zd",selectItem,tbDataTableSelectItemRow);

        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsLeft];
        if (tbDataTableSelectItemRow>=0)
        {
            NSMutableArray *selectItemColorTbRight = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsRight]];

            if ([selectItem isNotEqualTo:lastItemSelectColorTbLeft] || lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow|| selectItemColorTbRight !=lastItemSelectColorTbRight ||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
            }
            else
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                NSLog(@"=====click the same items");
                return;
            }
            
            [self getTwoColorTableDataAndSend:-1];
            
        }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!"];
        }
    }
    else
    {
        NSLog(@"==>>> %@",Off);
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
    }

}


-(void)DblClickOnTableView2:(id )sender
{
    NSInteger row = [self.colorByTableView2 selectedRow];
    if (row == -1 && selectColorBoxIndex==0) {
        NSLog(@"--select item is wrong- 2--!!!");
        return;
    }
    NSLog(@"---click right color by ");
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];

    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView2 selectedRowIndexes];
    if ([rowIndexes count])
    {
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop)
        {
                [selectItem addObject:_data2[idx]];
            }];

        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsRight];
        
        if (tbDataTableSelectItemRow>=0)
        {
                NSMutableArray *selectItemColorTbLeft = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsLeft]];
                if ([selectItem isNotEqualTo:lastItemSelectColorTbRight] ||[selectItemColorTbLeft isNotEqualTo:lastItemSelectColorTbLeft] ||lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                }
                else
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                    NSLog(@"=====click the same items");
                    return;
                }
                
                
            [self getTwoColorTableDataAndSend:-1];
                
                
            }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!"];
        }
            
    }
    else
    {
        NSLog(@"==>>> %@",Off);
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
    }
    
    

    
}


-(NSArray*)combineMutiArray:(NSMutableArray *)arrayLeft withArray:(NSMutableArray *)arrayRight withDeleteArray:(NSMutableArray *)array3
{
       NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",arrayLeft];
       NSArray * filter_no = [arrayRight filteredArrayUsingPredicate:filterPredicate_same];
//       NSLog(@"%@",filter_no);
       NSPredicate * filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arrayLeft];
       NSArray * filter1 = [arrayRight filteredArrayUsingPredicate:filterPredicate1];
       //找到在arr1中不在数组arr2中的数据
       NSPredicate * filterPredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arrayRight];
       NSArray * filter2 = [arrayLeft filteredArrayUsingPredicate:filterPredicate2];
       //拼接数组
       NSMutableArray *array = [NSMutableArray arrayWithArray:filter1];
       [array addObjectsFromArray:filter2];
       
       NSArray *result = [[filter_no arrayByAddingObjectsFromArray:array] arrayByAddingObjectsFromArray:array3];
       //NSLog(@"==> %@",result);
       return result;
      //    NSPredicate * filter_same = [NSPredicate predicateWithFormat:@"SELF IN %@",selectItemColorTbItemLeft];  //找到相同元素
      //    NSArray * filter_selectItemColorTbItem = [selectItemColorTbItemRight filteredArrayUsingPredicate:filter_same];
}

-(void)getTwoColorTableDataAndSend:(int)xy  //计算两个filter 选择的值
{
    
    
    NSMutableArray *delectArrIndex = [self getNeedDeletDataIndex];

    NSArray *selectItemColorTbItemLeft = [m_configDictionary valueForKey:kSelectColorByTableRowsLeft];
    NSArray *selectItemColorTbItemRight = [m_configDictionary valueForKey:kSelectColorByTableRowsRight];
    
    
    
    NSArray *itemsArr = _dataReverse[selectColorBoxIndex];  //left
    NSUInteger itemCountL = [itemsArr count];
    NSUInteger selectCountL = [selectItemColorTbItemLeft count];
    NSMutableArray *itemDataIndexLeft = [NSMutableArray array];
    NSInteger row_left = [self.colorByTableView selectedRow];
    if (selectColorBoxIndex >0 && row_left>= 0)
    {
        for (int i=0; i<selectCountL; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountL; j++)
            {
                if (j<tb_data_start)
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
                if ([itemsArr[j] isEqualTo:selectItemColorTbItemLeft[i]])
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
            }
            [itemDataIndexLeft addObject:tmp];
        }
    }
    else
    {
        for (int i=0; i<selectCountL; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountL; j++)
            {
                [tmp addObject:[NSNumber numberWithInt:j]];
            }
            [itemDataIndexLeft addObject:tmp];
        }
        
    }

    
   // NSLog(@"=====item index left: %@",itemDataIndexLeft);
    
    NSArray *itemsArr2 = _dataReverse[selectColorBoxIndex2];  //right
    NSUInteger itemCountR = [itemsArr2 count];
    NSUInteger selectCountR = [selectItemColorTbItemRight count];
    NSMutableArray *itemDataIndexRight = [NSMutableArray array];
    NSInteger row_right = [self.colorByTableView2 selectedRow];
    if (selectColorBoxIndex2>0 && row_right>=0)
    {
        for (int i=0; i<selectCountR; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountR; j++)
            {
                if (j<tb_data_start)
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
                if ([itemsArr2[j] isEqualTo:selectItemColorTbItemRight[i]])
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
            }
            [itemDataIndexRight addObject:tmp];
        }
    }
    else
    {
        for (int i=0; i<selectCountR; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountR; j++)
            {
                [tmp addObject:[NSNumber numberWithInt:j]];
            }
            [itemDataIndexRight addObject:tmp];
        }
    }
    //NSLog(@"=====item index right: %@",itemDataIndexRight);
    
    
    NSMutableArray *selectItemsIndex = [NSMutableArray array];
    NSMutableArray *selectItemsName = [NSMutableArray array];
    for (int m = 0; m<[itemDataIndexLeft count]; m++)
    {
        for (int n = 0; n<[itemDataIndexRight count]; n++)
        {
            NSPredicate * filter_same = [NSPredicate predicateWithFormat:@"SELF IN %@",itemDataIndexLeft[m]];  //找到相同元素
            NSArray * filter_selectItem = [itemDataIndexRight[n] filteredArrayUsingPredicate:filter_same];
            [selectItemsIndex addObject:filter_selectItem];
            [selectItemsName addObject:[NSString stringWithFormat:@"%@&%@",selectItemColorTbItemLeft[m],selectItemColorTbItemRight[n]]];
        }
    }
    
    //NSLog(@"=====>select item index: %@",selectItemsIndex);
    NSMutableArray *itemsData = [NSMutableArray array];
    NSMutableString *colorItemName = [NSMutableString string];
    for (int k = 0; k<[selectItemsIndex count]; k++)
    {
        
        //NSLog(@"====<<keep>>: %@",selectItemsIndex[k]);
        //NSLog(@"====<<delete>>: %@",delectArrIndex);
        
        for (int h = 0; h<[selectItemsIndex[k] count]; h++)
        {
              
             if (![delectArrIndex containsObject:selectItemsIndex[k][h]])  //在index delete 列没有的元素
             {
                 int okrow = [selectItemsIndex[k][h] intValue];
                 
                 [itemsData addObject:_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col][okrow]];
             }
        }
        [itemsData addObject:End_Data];
        [colorItemName appendString:[NSString stringWithFormat:@"%@##",selectItemsName[k]]];
    }
    
    NSString * itemName = [self combineItemName:colorItemName];
    if (xy==-1)
    {
        // do nothing
    }
    else
    {
        itemName = [NSString stringWithFormat:@"%@$$%d",itemName,xy];
    }
    NSLog(@"======send item name to redis: %@   itemsData count:%zd",itemName,[itemsData count]);
    [self sendDataToRedis:itemName withData:itemsData];
    [self sendCpkZmqMsg:itemName];
    [self sendCorrelationZmqMsg:itemName];
    
}


-(void)notifySetImage:(NSString *)path
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkImage object:nil userInfo:dic];
}

-(void)setCpkImage:(NSString *)path
{
     NSImage *imageCPK = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
        [self.cpkImageView setImage:imageCPK];
    });
}
-(void)setCorrelationImage:(NSString *)path
{
     NSImage *imageCorrelation = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.correlationImageView setImage:imageCorrelation];
    });
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

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}

-(NSString*)switchRetest:(NSInteger)num
{
    NSString *value = @"";
    switch (num) {
        case 0:
            value = vRetestFirst;
            break;
        case 1:
            value = vRetestAll;
            break;
        case 2:
            value = vRetestLast;
            break;
        default:
            break;
    }
    return value;
}


-(NSString*)switchRemoveFail:(NSInteger)num
{
    NSString *value = @"";
    switch (num) {
        case 0:
            value = vRemoveFailYes;
            break;
        case 1:
            value = vRemoveFailNo;
            break;
        default:
            break;
    }
    return value;
}

-(int)indexOfColorByItem:(NSString*)item
{
    for (int i=0; i<[colorByName count]; i++)
    {
        if ([colorByName[i] isEqualToString:item])
        {
            return i;
        }
    }
    return 0;
}
// Version,Station_ID,Special_Build_Name,Special_Build_Descrip,Product,Channel_ID
- (IBAction)selectColorByBoxAction:(id)sender {
    NSString *title = [(NSComboBox *)sender stringValue];
    NSLog(@"=> %@",title);
    int n_index = [self indexOfColorByItem:title];
    if (n_index>0)
    {
        [self.colorByBox2 removeAllItems];
        [self.colorByBox2 addItemsWithObjectValues:colorByName];
        [self.colorByBox2 removeItemAtIndex:n_index];
    }

    [_data removeAllObjects];
    if ([title isEqualToString:Off])
    {
        [_data removeAllObjects];
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
        
        selectColorBoxIndex = 0;
        [self.colorByBox2 removeAllItems];
        [self.colorByBox2 addItemsWithObjectValues:colorByName];
        
    }
    else if ([title isEqualToString:Version])
    {
        selectColorBoxIndex = n_Version_Col;
        NSMutableArray *vers = [m_configDictionary valueForKey:k_dic_Version];
        if ([vers count]>0) {
            _data = [NSMutableArray arrayWithArray:vers];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[Version_Col]);
            }
            
        }
         
    }
    else if ([title isEqualToString:Station_ID])
    {
        selectColorBoxIndex = n_StationID_Col;
        NSMutableArray *IDs = [m_configDictionary valueForKey:k_dic_Station_ID];
        if ([IDs count]>0) {
            _data = [NSMutableArray arrayWithArray:IDs];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[StationID_Col]);
            }
        }
    }
    else if ([title isEqualToString:Special_Build_Name])
    {
        selectColorBoxIndex = n_SpecialBuildName_Col;
        NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Name];
        if ([BuildN count]>0) {
            _data = [NSMutableArray arrayWithArray:BuildN];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
            }
        }
        
    }
    else if ([title isEqualToString:Special_Build_Descrip])
    {
        selectColorBoxIndex = n_Special_Build_Descrip_Col;
        NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Desc];
        if ([BuildN count]>0) {
            _data = [NSMutableArray arrayWithArray:BuildN];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
            }
        }
        
    }
    else if ([title isEqualToString:Product])
    {
        selectColorBoxIndex = n_Product_Col;
        NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Product];
        if ([BuildN count]>0) {
            _data = [NSMutableArray arrayWithArray:BuildN];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
            }
        }
        
    }
    else if ([title isEqualToString:Channel_ID])
    {
        int selRow = [[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue];
        selectColorBoxIndex = selRow;
        NSMutableArray *channelId = [m_configDictionary valueForKey:k_dic_Channel_ID];
        if ([channelId count]>0) {
            NSLog(@"=====<<<--->>> %@   %zd",channelId,[channelId count]);
            _data = [NSMutableArray arrayWithArray:channelId];
           
            if (tbDataTableSelectItemRow>=0)
            {
               
                if (selRow>0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[selRow]);
                }
                
            }
        }
        
    }
    /*else if ([title isEqualToString:Station_Channel_ID])
    {
        int selRow = [[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue];
        selectColorBoxIndex = StationID_Col*10000+selRow;   //取出来的时候除以10000，结果是station id，余就是channel id
        NSMutableArray *station_channelId = [m_configDictionary valueForKey:k_dic_Station_Channel_ID];
        if ([station_channelId count]>0) {
            _data = [NSMutableArray arrayWithArray:station_channelId];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[tbsDataTableSelectItemRow]);
            }
        }
        
    }*/
        
//        if ([self.color_dicDatas.allKeys containsObject:title]) {
//
//            self.color_datas =[self.color_dicDatas objectForKey:title];
//        }else{
//            self.color_datas =nil;
//        }
    [self.colorByTableView reloadData];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:selectColorBoxIndex] forKey:select_Color_Box_left];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetColorByLeft object:nil userInfo:dic];
}

- (IBAction)selectColorByBoxAction2:(id)sender
{
    
    NSString *title = [(NSComboBox *)sender stringValue];
    NSLog(@"=> %@",title);
    int n_index = [self indexOfColorByItem:title];
    if (n_index>0)
    {
        [self.colorByBox removeAllItems];
        [self.colorByBox addItemsWithObjectValues:colorByName];
        [self.colorByBox removeItemAtIndex:n_index];
    }
    
     [_data2 removeAllObjects];
    if ([title isEqualToString:Off])
    {
        [_data2 removeAllObjects];
        selectColorBoxIndex2 = 0;
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsRight];
        
        [self.colorByBox removeAllItems];
        [self.colorByBox addItemsWithObjectValues:colorByName];
    }
    else if ([title isEqualToString:Version])
    {
        selectColorBoxIndex2 = n_Version_Col;
        NSMutableArray *vers = [m_configDictionary valueForKey:k_dic_Version];
        if ([vers count]>0) {
            _data2 = [NSMutableArray arrayWithArray:vers];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[Version_Col]);
            }
        }
    }
    else if ([title isEqualToString:Station_ID])
    {
        selectColorBoxIndex2 = n_StationID_Col;
        NSMutableArray *IDs = [m_configDictionary valueForKey:k_dic_Station_ID];
        if ([IDs count]>0) {
            _data2 = [NSMutableArray arrayWithArray:IDs];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[StationID_Col]);
            }
        }
    }
    else if ([title isEqualToString:Special_Build_Name])
    {
        selectColorBoxIndex2 = n_SpecialBuildName_Col;
        NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Name];
        if ([BuildN count]>0) {
            _data2 = [NSMutableArray arrayWithArray:BuildN];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
            }
        }
        
    }
    else if ([title isEqualToString:Special_Build_Descrip])
    {
        selectColorBoxIndex2 = n_Special_Build_Descrip_Col;
        NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Desc];
        if ([BuildN count]>0) {
            _data2 = [NSMutableArray arrayWithArray:BuildN];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
            }
        }
        
    }
    else if ([title isEqualToString:Product])
    {
        selectColorBoxIndex2 = n_Product_Col;
        NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Product];
        if ([BuildN count]>0) {
            _data2 = [NSMutableArray arrayWithArray:BuildN];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
            }
        }
        
    }
    else if ([title isEqualToString:Channel_ID])
    {
        int selRow = [[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue];
        selectColorBoxIndex2 = selRow;
        NSMutableArray *channelId = [m_configDictionary valueForKey:k_dic_Channel_ID];
        if ([channelId count]>0) {
            NSLog(@"=====<<<--->>> %@   %zd",channelId,[channelId count]);
            _data2 = [NSMutableArray arrayWithArray:channelId];
           
            if (tbDataTableSelectItemRow>=0)
            {
               
                if (selRow>0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[selRow]);
                }
                
            }
        }
        
    }

    [self.colorByTableView2 reloadData];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:selectColorBoxIndex2] forKey:select_Color_Box_Right];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetColorByRight object:nil userInfo:dic];
}

- (IBAction)clickRetestSegmentAction:(id)sender {
    NSInteger ret = self.retestSegment.selectedSegment;
    NSLog(@"==%zd",ret);
    [m_configDictionary setValue:[self switchRetest:ret] forKey:kRetestSeg];
}
- (IBAction)btnShowData:(id)sender {
    //just for test
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"1.png" ofType:nil];
    [self setCpkImage:picPath];
    picPath =[[NSBundle mainBundle]pathForResource:@"2.png" ofType:nil];
    [self setCorrelationImage:picPath];
}

- (IBAction)clickRemoveFailSegmentAction:(id)sender {
    NSInteger ret = self.removeFailSegment.selectedSegment;
    NSLog(@"== %zd",ret);
    [m_configDictionary setValue:[self switchRemoveFail:ret] forKey:kRemoveFailSeg];
}
- (IBAction)btnReportExcel:(id)sender
{
    _reportSetWin=[[reportSettingCfg alloc]initWithWindowNibName:@"reportSettingCfg"];
    NSModalResponse result = [NSApp runModalForWindow:_reportSetWin.window];
    if (result == NSModalResponseOK)
    {
        NSLog(@"====ok==");
        
    } else if (result == NSModalResponseCancel)
    {
        NSLog(@"====cancel==");
    }
   
    
}

- (IBAction)btnReport:(id)sender {
    
}

- (IBAction)btnSelectY:(id)sender {
    n_select_y ++;
    int y = n_select_y%2;
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:y] forKey:btn_select_y];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSelectY object:nil userInfo:dic];
    NSLog(@"====select y: %d",y);
    
}

- (IBAction)btnSelectX:(id)sender {
    n_select_x ++;
    int x = n_select_x%2;
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:x] forKey:btn_select_x];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSelectX object:nil userInfo:dic];
    NSLog(@"====select x: %d",x);
}

- (IBAction)setTxtBinsValue:(id)sender
{
    NSLog(@"==%@",[self.txtBins stringValue]);
}
-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *textF =obj.object;
    if ([textF.identifier isEqualToString:@"bins"])
    {
        NSString *ret = [textF stringValue];
        NSLog(@"===edit bins: %@",ret);
        if ([self isAllNum:ret])
        {
            [m_configDictionary setValue:ret forKey:kBins];
        }
        else
        {
            [self AlertBox:@"Error!!!" withInfo:@"Input Bins should be number!!!"];
            NSString *val = [m_configDictionary valueForKey:kBins];
            [self.txtBins setStringValue:val];
        }
    }
}


#pragma mark TableView Datasource & delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView== self.colorByTableView) { //left color by
        return [_data count];
    }
    else if(tableView== self.colorByTableView2) //right color by
    {
        return [_data2 count];
    }
    return -1;
    
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.colorByTableView) {
        NSString *columnIdentifier = [tableColumn identifier];
         NSTableCellView *view = [_colorByTableView makeViewWithIdentifier:columnIdentifier owner:self];
        
         if ([_data count] > row)
         {
             [[view textField] setStringValue:_data[row]];
         }
         else
         {
              [[view textField] setStringValue:@"--"];
         }
         return view;
    }
    else if (tableView == self.colorByTableView2)
    {
        NSString *columnIdentifier = [tableColumn identifier];
           NSTableCellView *view = [_colorByTableView2 makeViewWithIdentifier:columnIdentifier owner:self];
          
           if ([_data2 count] > row)
           {
               [[view textField] setStringValue:_data2[row]];
           }
           else
           {
                [[view textField] setStringValue:@"--"];
           }
           return view;
    }
    return nil;
    
}

- (IBAction)sliderActionR:(id)sender
{
}

- (IBAction)sliderActionL:(id)sender
{
    //float scaleFactor = self.sliderL.floatValue;
    //self.customerViewL.mag
}
@end
