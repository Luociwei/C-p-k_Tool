//
//  SnVauleVC.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/17.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "SnVauleVC.h"

@interface SnVauleVC ()
@property (weak) IBOutlet NSTableView *snTableView;

//@property(nonatomic,strong)NSMutableArray<SnVauleMode *> *sn_datas;
@end

@implementation SnVauleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.title = @"Sn_Vaule_List";

    [self initTableView:self.snTableView];
    self.sn_datas = [[NSMutableArray alloc]init];
    
//    SnVauleMode *mode1 = [SnVauleMode new];
//    mode1.sn = @"111111121111";
//    mode1.value = @"1";
//    SnVauleMode *mode2 = [SnVauleMode new];
//    mode1.sn = @"111111121112";
//    mode1.value = @"2";
//    [self.sn_datas addObject:mode1];
//    [self.sn_datas addObject:mode2];
    
//    [self.snTableView reloadData];
}

-(void)initTableView:(NSTableView *)tableView{
    tableView.headerView.hidden=NO;
    tableView.usesAlternatingRowBackgroundColors=YES;
    tableView.rowHeight = 20;
    tableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask |NSTableViewSolidVerticalGridLineMask ;
}


#pragma mark-  NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
    //返回表格共有多少行数据
{
        return [self.sn_datas count];

}

#pragma mark-  NSTableViewDelegate
    
    
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSString *identifier = tableColumn.identifier;
    NSString *value = @"";
    NSTextField *textField;
    
    NSView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    
    NSArray *subviews = [view subviews];
    textField = subviews[0];
    textField.wantsLayer=YES;
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    
    
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
    
    
    if(!value.length){
        //更新单元格的文本
        [textField setStringValue:@""];
    }else{
        [textField setStringValue:value];
    }
    
    
    return view;
}

    
-(void)showViewOnViewController:(NSViewController *)vc datas:(NSMutableArray <SnVauleMode *>*)snDatas{

    [self showViewOnViewController:vc];
    [_sn_datas removeAllObjects];
    _sn_datas = nil;
    _sn_datas = [[NSMutableArray alloc]initWithArray:snDatas];
    [self.snTableView reloadData];
}
    




@end
