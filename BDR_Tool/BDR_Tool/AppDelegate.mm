//
//  AppDelegate.m
//  CPK_Test
//
//  Created by RyanGao on 2020/6/23.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "AppDelegate.h"

#define  cpk_zmq_addr           @"tcp://127.0.0.1:3100"
#define  correlation_zmq_addr   @"tcp://127.0.0.1:3110"
#define  calculate_zmq_addr     @"tcp://127.0.0.1:3120"
#define  report_zmq_addr     @"tcp://127.0.0.1:3120"



Client *cpkClient;
Client *correlationClient;
Client *calculateClient;
Client *reportClient;
RedisInterface *myRedis;

@interface AppDelegate ()
{
    
}
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        startPython = [[StartUp alloc] init];
        [startPython OpenRedisServer];  // redis server launch
        
        [startPython Lanuch_cpk];   // python cpk
        [startPython Lanuch_correlation];  // python correlation
        [startPython Lanuch_calculate];  // python correlation
        [startPython Lanuch_report];   //report
        

        
        cpkClient = [[Client alloc] init];   // connect CPK zmq for cpk_test.py
        [cpkClient CreateRPC:cpk_zmq_addr withSubscriber:nil];
        [cpkClient setTimeout:20*1000];
        
        correlationClient = [[Client alloc] init];   // connect Correlation zmq for correlation_test.py
        [correlationClient CreateRPC:correlation_zmq_addr withSubscriber:nil];
        [correlationClient setTimeout:20*1000];
        
        calculateClient = [[Client alloc] init];   // connect calculate zmq for correlation_test.py
        [calculateClient CreateRPC:calculate_zmq_addr withSubscriber:nil];
        [calculateClient setTimeout:20*1000];
        
        reportClient = [[Client alloc] init];   // connect calculate zmq for report_test.py
        [reportClient CreateRPC:report_zmq_addr withSubscriber:nil];
        [reportClient setTimeout:20*1000];
        
        myRedis = new RedisInterface();  // redis client connect
        myRedis->Connect();
        myRedis->SetString("dummy", "just for test");
        
    }
    return self;
}

-(void)awakeFromNib
{
    
    tablePanel = [[dataTableView alloc]init];
    [self setTableDetailView:tablePanel.view];
    
    plotPanel = [[dataPlotView alloc]init];
    [self setPlotDetailView:plotPanel.view];
    
   

    
}

-(void)setTableDetailView:(NSView *)view
{
    [self replaceView:tableViewDetail with:view];
    tableViewDetail =view;
}

-(void)setPlotDetailView:(NSView *)view
{
    [self replaceView:plotViewDetail with:view];
    plotViewDetail = view;
}

-(void)replaceView:(NSView *)oldView with:(NSView *)newView
{
    [newView setFrame:[oldView frame]];
    [[oldView superview] addSubview:newView];
    [[oldView superview] replaceSubview:oldView with:newView];
    [oldView setHidden:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    self.csvController = [[loadCsvControl alloc] initWithWindowNibName:@"loadCsvControl"];
//    [self.csvController showWindow:self];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    NSLog(@"--close app--");
    NSString *file_cli = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-cli"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *cli_Path = [NSString stringWithFormat:@"%@ flushall",file_cli];
    for (int i=0; i<10; i++)
        system([cli_Path UTF8String]);
    
    for (int i=0; i<20; i++)
    {
        NSString *killRedis = @"ps -ef |grep -i redis-server |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([killRedis UTF8String]);
    }
    
    NSString *logCmd1 = @"ps -ef |grep -i python |grep -i correlation_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd1 UTF8String]);  //杀掉correlation_test.py 进程
    
    NSString *logCmd2 = @"ps -ef |grep -i python |grep -i cpk_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd2 UTF8String]); //杀掉cpk_test.py 进程
    
    NSString *logCmd3 = @"ps -ef |grep -i python |grep -i calculate_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd3 UTF8String]);  //杀掉calculate_test.py 进程
       
    
    
    return YES;
}

- (IBAction)btReadCsv:(id)sender
{
    myRedis->SetString("csv_all", "0.01,0.03\n0.02,0.05,0.8\n");
    myRedis->SetString("Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Frequency", "0.01,0.03");
    myRedis->SetString("row1", "0.01,0.03,0.02");
    myRedis->SetString("row2", "0.01,0.03,0.02");
    myRedis->SetString("one_item", "0.01,0.03,0.02");
    
    myRedis->SetString("Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Peak_Power", "0.05,0.04,0.06");
    myRedis->SetString("test_item_3", "350");
    
    myRedis->SetString("test_item_1", "0.01,0.03,0.02");
    myRedis->SetString("test_item_2", "1.01,1.03,0.02");
    myRedis->SetString("test_item_3", "2.01,3.03,0.02");
}
- (IBAction)btCpk:(id)sender
{
   //NSLog(@"==>%s",myRedis->GetString("test_item_1"));
   //NSLog(@"==>%s",myRedis->GetString("test_item_2"));
    
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    int ret = [cpkClient SendCmd:@"Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Frequency"];
    if (ret > 0)
    {
        NSString * response = [cpkClient RecvRquest:1024];
        
        if (!response)
        {    //Not response
            //@throw [NSException exceptionWithName:@"automation Error" reason:@"pleaase check fixture." userInfo:nil];
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
    }
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
    
}
- (IBAction)btCorrelation:(id)sender
{
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    int ret = [correlationClient SendCmd:@"test_item_2"];
    if (ret > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
}

- (IBAction)btCalculate:(id)sender
{
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    
    int ret = [calculateClient SendCmd:@"test_item_3"];
    if (ret > 0)
    {
        NSString * response = [calculateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
    
}

- (IBAction)btCpkCorrTogether:(id)sender
{
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    
    int ret1 = [cpkClient SendCmd:@"test_item_1"];
    int ret2 = [correlationClient SendCmd:@"test_item_2"];
    
    if (ret1 > 0)
    {
        NSString * response = [cpkClient RecvRquest:1024];
        
        if (!response)
        {
            NSLog(@"zmq cpk for python error");
        }
        NSLog(@"app->get response from cpk python: %@",response);
    }
    
    if (ret2 > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq correlation for python error");
        }
        NSLog(@"app->get response from correlation python: %@",response);
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
    
}

@end
