//
//  ColorByMode.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/5.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnVauleMode.h"
#import "ColorBy2Mode.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorByMode : NSObject
@property (nonatomic,strong)ColorBy2Mode *colorBy2Mode;
@property (nonatomic,copy)NSString *result;
@property BOOL needDelete;
-(NSString *)getVauleWithKey:(NSString *)key snVauleMode:(SnVauleMode *)snVauleMode;

@end

NS_ASSUME_NONNULL_END
