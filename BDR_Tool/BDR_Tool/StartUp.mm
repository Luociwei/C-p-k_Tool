//
//  StartUpInfor.m
//  GUI
//
//  Created by Ryan on 8/27/15.
//  Copyright (c) 2015 ___sc Automation___. All rights reserved.
//

#import "StartUp.h"
#include <Foundation/Foundation.h>


@implementation StartUp

-(id)init
{
    self= [super init];
    if (self) {
        system("/usr/bin/ulimit -n 8192");
    }
    return self;
}

-(BOOL)OpenRedisServer
{
    for (int i=0; i<20; i++)
    {
        NSString *killRedis = @"ps -ef |grep -i redis-server |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([killRedis UTF8String]);
    }
    
    [NSThread sleepForTimeInterval:0.2];
    NSString *file = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-server&"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    system([file UTF8String]);
    for (int i=0; i<20; i++)
    {
        NSString *killRedis = @"ps -ef |grep -i redis-server |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([killRedis UTF8String]);
    }
     [NSThread sleepForTimeInterval:0.2];
    
    
    //NSString *file = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-server&"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];

    system([file UTF8String]);
    
    [NSThread sleepForTimeInterval:0.2];
    NSString *file_cli = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-cli"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *cli_Path = [NSString stringWithFormat:@"%@ flushall",file_cli];
    for (int i=0; i<10; i++)
        system([cli_Path UTF8String]);
    return true;
}

-(void)Lanuch_cpk
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.8/bin/python3";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cpk_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i cpk_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //杀掉cpk_test.py 进程
    [self execute_withTask:cmd withPython:arg];
    
}

-(void)Lanuch_correlation
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.8/bin/python3";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"correlation_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i correlation_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);  //杀掉correlation_test.py 进程
    
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_calculate
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.8/bin/python3";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"calculate_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i calculate_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);  //杀掉calculate_test.py 进程
    
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_report
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.8/bin/python3";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i report_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);  //杀掉calculate_test.py 进程
    
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

@end
