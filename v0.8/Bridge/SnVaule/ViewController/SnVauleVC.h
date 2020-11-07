//
//  SnVauleVC.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/17.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SnVauleMode.h"
#import <CWGeneralManager/MyViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface SnVauleVC : MyViewController

@property(nonatomic,strong)NSMutableArray<SnVauleMode *> *sn_datas;

-(void)showViewOnViewController:(NSViewController *)vc datas:(NSMutableArray <SnVauleMode *>*)snDatas;


@end

NS_ASSUME_NONNULL_END
