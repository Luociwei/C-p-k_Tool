//
//  PythonTask.m
//  TestDemo
//
//  Created by ciwei luo on 2020/4/20.
//  Copyright © 2017 ciwei luo. All rights reserved.
//

#import "PythonTask.h"
#import "ShowingLogVC.h"

@implementation PythonTask
{
    BOOL isOpen;
    NSTask *task;
    NSPipe *readPipe;
    NSFileHandle *readHandle;
    NSPipe *writePipe;
//    NSFileHandle *writeHandle;
}

-(instancetype)initWithLauchPath:(NSString *)lauchPath  arguments:(NSArray *)arguments{
    if (self=[super init]) {
        
        task = [[NSTask alloc] init];
        [task setLaunchPath:lauchPath];//@"/usr/bin/python"

        readPipe = [NSPipe pipe];
        readHandle = [readPipe fileHandleForReading];
        writePipe = [NSPipe pipe];
        _writeHandle = [writePipe fileHandleForWriting];
        [task setStandardInput:writePipe];
        [task setStandardOutput:readPipe];
        [task launch];
        
    }
    return self;
}




-(instancetype)initWithPythonPath:(NSString*)path parArr:(NSArray *)parArr lauchPath:(NSString *)lauchPath{
    if (self=[super init]) {
        
        NSMutableArray *mut_parArr = [[NSMutableArray alloc]initWithArray:[NSArray arrayWithObjects:path, nil]];
        if (parArr.count) {
            [mut_parArr addObjectsFromArray:parArr];
        }
        if (task ==nil) {
            task = [[NSTask alloc] init];
            [task setLaunchPath:lauchPath];//@"/usr/bin/python"
            //        NSMutableString *mut_str = nil;
            //        if (parArr.count) {
            //            mut_str = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",pythonPath,filePath]];
            //
            //            for (NSString *str in parArr) {
            //                [mut_str appendString:@" "];
            //                [mut_str appendString:@"\'"];
            //                [mut_str appendString:str];
            //                [mut_str appendString:@"\'"];
            //
            //            }
            //        }
            //        [task setArguments:[NSArray arrayWithObjects:@"-c",mut_parArr, nil]];
            [task setArguments:mut_parArr];
            readPipe = [NSPipe pipe];
            readHandle = [readPipe fileHandleForReading];
            writePipe = [NSPipe pipe];
            _writeHandle = [writePipe fileHandleForWriting];
            [task setStandardInput:writePipe];
            [task setStandardOutput:readPipe];
            [task launch];
//            [task waitUntilExit];
 

            
        }

    }
    return self;
}


-(void)setParArr:(NSArray *)parArr  pythonPath:(NSString*)path {
    NSMutableArray *mut_parArr = [[NSMutableArray alloc]initWithArray:[NSArray arrayWithObjects:path, nil]];
    if (parArr.count) {
        [mut_parArr addObjectsFromArray:parArr];
    }
    [task setArguments:mut_parArr];
}

-(instancetype)initWithShellPath:(NSString*)filePath parArr:(NSArray *)parArr pythonPath:(NSString *)pythonPath{
    if (self=[super init]) {

        task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];

        if (!pythonPath.length) {
            pythonPath = @"python";
        }
        NSMutableString *mut_str = nil;
        if (parArr.count) {
            mut_str = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",pythonPath,filePath]];
            
            for (NSString *str in parArr) {
                [mut_str appendString:@" "];
                [mut_str appendString:@"\'"];
                [mut_str appendString:str];
                [mut_str appendString:@"\'"];
                
            }
        }
        
       // @"sudo spctl --master-disable";
//        NSString * cmd = [NSString stringWithFormat:@"%@\necho '%@' | sudo -S which python",@"sudo spctl --master-disable",@"luo%2019"];
        
        
        [task setArguments:[NSArray arrayWithObjects:@"-c",mut_str, nil]];
        readPipe = [NSPipe pipe];
        readHandle = [readPipe fileHandleForReading];
        writePipe = [NSPipe pipe];
        _writeHandle = [writePipe fileHandleForWriting];
        [task setStandardInput:writePipe];
        [task setStandardOutput:readPipe];
        [task launch];
        
    }
    return self;
}


-(NSString*)send:(NSString*)command
{
//    if(isOpen == false)
//    {
//        return @"";
//    }
    NSData * in_data = [command dataUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];
    [_writeHandle writeData:in_data];
    usleep(200000);
    //[QThread usleep: 100];
    NSData *readData = [readHandle availableData];
    NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    NSLog(@"\nsend command: %@ ----> %@\n", command, string);
    return string;
}


-(NSString*)read1{

    NSData *readData = [readHandle availableData];
    NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];

    return string;
}

-(NSString*)read{
    
    NSMutableString *mut_string = [[NSMutableString alloc]init];
    while (1) {
        NSData *readData = [readHandle availableData];
        if (!readData.length) {
            break;
        }
        NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
//        if (!string.length) {
//            break;
//        }
        [mut_string appendString:string];
    }
    
    
    
    return mut_string;
}

-(BOOL)close{
    
    if(isOpen == false)
    {
        return true;
    }
    BOOL result = false;
    NSString * in_str = @"quit\n";
    NSData * in_data = [in_str dataUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];
    [_writeHandle writeData:in_data];
    [_writeHandle closeFile];
    usleep(100000);
    NSData *readData = [readHandle availableData];
    NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    NSLog(@"\nsend command: %@ ----> %@\n", @"quit", string);
    if([string containsString:@"Quitting"])
    {
        isOpen = false;
        result = true;
    }
    [task waitUntilExit];
    return result;
}


-(BOOL)isOpen
{
    return isOpen;
}


@end
