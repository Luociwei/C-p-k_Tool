//
//  WindowVC.m
//  SC_CPK
//
//  Created by ciwei luo on 2020/3/31.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "WindowVC.h"
#import "ViewController.h"
#import "ShowingLogVC.h"
#import <CWGeneralManager/CWFileManager.h>
#import <CWGeneralManager/NSString+Extension.h>
@interface WindowVC ()

@end

@implementation WindowVC

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //[self cw_addViewController:[ViewController new]];

    [self cw_addViewController:[ViewController new] logVC:[ShowingLogVC new] ];
    

//    
//    NSMutableArray *mutCsvArr = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"10",@"5",@"6",@"7",@"15", @"1",nil];
//
//    //[mutCsvArr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 10-5)]];
////    [ mutCsvArr  removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:2]];
////    [ mutCsvArr  removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:3]];
//    
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
//    NSString *content = [CWFileManager cw_readFromFile:@"/Users/ciweiluo/Desktop/testss.txt"];
//    NSArray *scriptArray1 = [content cw_componentsSeparatedByString:@"/n"];
//    
//       NSLog(@"1");

}



@end
