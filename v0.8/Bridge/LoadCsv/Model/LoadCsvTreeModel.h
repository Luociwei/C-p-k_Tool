//
//  LoadCsvTreeModel.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/27.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadCsvTreeModel : NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic)NSInteger index;
@property(nonatomic,strong)NSString *rootName;
@property(nonatomic,strong)NSMutableArray *childNodes;
@end

NS_ASSUME_NONNULL_END
