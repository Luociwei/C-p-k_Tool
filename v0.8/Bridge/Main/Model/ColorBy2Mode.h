//
//  ColorBy2Mode.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/7/3.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//special build name
@interface ColorBy2Mode : NSObject
@property (nonatomic,copy)NSString *colorTitle;
@property (nonatomic,strong)NSMutableSet *productArray;
@property (nonatomic,strong)NSMutableSet *versionArray;
@property (nonatomic,strong)NSMutableSet *channelIDArray;
@property (nonatomic,strong)NSMutableSet *specialBuildNameArr;
@property (nonatomic,strong)NSMutableSet *stationIDArr;
@property (nonatomic,strong)NSMutableSet *diagsVersionArr;
@end

NS_ASSUME_NONNULL_END
