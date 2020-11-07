//
//  ShowingLogVC.m
//  TestPlanEditor
//
//  Created by ciwei luo on 2020/1/17.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "ShowingLogVC.h"
#import <CWGeneralManager/NSString+Extension.h>

@interface ShowingLogVC ()
@property (strong,nonatomic)NSMutableString *mutLogString;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation ShowingLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mutLogString = [NSMutableString string];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLog:)
                                                 name:@"ShowingLogVCWillPrintLog"
                                               object:nil];
    self.logTextView.layoutManager.allowsNonContiguousLayout = NO;
    // Do view setup here.
}
- (IBAction)clean:(NSButton *)sender {
    self.mutLogString=nil;
    self.mutLogString =[[NSMutableString alloc] initWithString:@"Clean..................\n"];
    self.logTextView.string = @"";
    
}


+(void)postNotificationWithLog:(NSString *)log type:(NSString *)type{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    [dic setObject:log forKey:@"log"];
    [dic setObject:type forKey:@"type"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowingLogVCWillPrintLog" object:nil userInfo:dic];
}


-(void)showLog:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    NSString *log = [dic objectForKey:@"log"];
    NSString *type = [dic objectForKey:@"type"];
    NSString *timeString = [NSString cw_stringFromCurrentDateTimeWithMicrosecond];
    [self.mutLogString appendString:[NSString stringWithFormat:@"%@ %@ %@\n",timeString,type,log]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.string = self.mutLogString;
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.string.length, 1)];
    });
}
- (IBAction)filtre:(NSSearchField *)sender {
    NSLog(@"%@",self.mutLogString);

    NSString *strSearch = sender.stringValue;
    
    if (!strSearch.length) {
        self.logTextView.string = self.mutLogString;
        return;
    }
    NSArray *strArr = [self.mutLogString cw_componentsSeparatedByString:@"\n"];
    NSMutableString *filterStr = [NSMutableString string];
    for (NSString *str in strArr) {
        if ([str.lowercaseString containsString:strSearch.lowercaseString]) {
            [filterStr appendString:str];
            [filterStr appendString:@"\n"];
        }
    }
    self.logTextView.string = filterStr;

}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
