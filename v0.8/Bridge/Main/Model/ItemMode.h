//
//  ItemMode.h
//  OPP_Tool
//
//  Created by ciwei luo on 2020/5/26.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnVauleMode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ItemType) {
    
    ItemTypeNotInsight=0,
    ItemTypeInsight=1,
    ItemTypeMismatch=2,
};
typedef NS_ENUM(NSInteger, CpkOrigResultType) {
    
    CpkOrigResultTypeNull=0,
    CpkOrigResultTypeGreen=1,
    CpkOrigResultTypeRed=2,
    CpkOrigResultTypeYellow=3,
};
typedef NS_ENUM(NSInteger, DataType) {
    
    DataTypeInsight=0,
    DataTypeNotInsight=1,
    DataTypeMismatch=2,
  
};
@interface ItemMode : NSObject

@property (nonatomic,copy)NSString *item;
@property (nonatomic,copy)NSString *upper;
@property (nonatomic,copy)NSString *low;
@property (nonatomic,copy)NSString *desc;
@property (nonatomic)DataType dataType;
@property (nonatomic)CpkOrigResultType isCpkPass;
@property (nonatomic,copy)NSString *cpkOrig;
@property (nonatomic,copy)NSString *bc;
@property (nonatomic,copy)NSString *pVal;
@property (nonatomic,copy)NSString *aQ;
@property (nonatomic,copy)NSString *aIrr;
@property (nonatomic,copy)NSString *threeDivideMean;

@property (nonatomic,copy)NSString *usl;
@property (nonatomic,copy)NSString *lsl;
@property (nonatomic)BOOL needUpdate;
//@property (nonatomic)BOOL isNotInsight;
@property (nonatomic)NSInteger index;

@property (nonatomic,readonly)BOOL isNotApply;
//@property (nonatomic)BOOL isMismatch;
@property (nonatomic,strong)NSMutableArray<SnVauleMode *> *SnVauleArray;
-(NSString *)getVauleWithKey:(NSString *)key;
-(void)setCpkOrig:(NSString *)cpkOrig low:(NSString *)low high:(NSString *)high;
-(void)setVauleWithKey:(NSString *)key value:(NSString *)value;


@end

NS_ASSUME_NONNULL_END
