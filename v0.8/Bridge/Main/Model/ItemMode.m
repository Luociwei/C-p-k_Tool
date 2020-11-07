//
//  ItemMode.m
//  OPP_Tool
//
//  Created by ciwei luo on 2020/5/26.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "ItemMode.h"


@implementation ItemMode

-(instancetype)init{
    if (self == [super init]) {
        
        self.SnVauleArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(NSString *)getVauleWithKey:(NSString *)key{
    NSString *value = @"";
    if ([key isEqualToString:@"item"]) {
        value = self.item;
    }else if ([key isEqualToString:@"upper"]) {
        value = self.upper;
    }else if ([key isEqualToString:@"low"]) {
        value = self.low;
    }else if ([key isEqualToString:@"usl"]) {
        value = self.usl;
    }else if ([key isEqualToString:@"lsl"]) {
        value = self.lsl;
    }else if ([key isEqualToString:@"index"]) {
        value =[NSString stringWithFormat:@"%ld",(long)_index];
    }else if ([key isEqualToString:@"update"]) {
        value =[NSString stringWithFormat:@"%d",_needUpdate];
    }else if ([key isEqualToString:@"Cpk-Orig"]) {
        value =self.cpkOrig;
    }else if ([key isEqualToString:@"bc"]) {
        value =self.bc;
    }else if ([key isEqualToString:@"p_val"]) {
        value =self.pVal;
    }else if ([key isEqualToString:@"a_q"]) {
        value =self.aQ;
    }else if ([key isEqualToString:@"a_irr"]) {
        value =self.aIrr;
    }else if ([key isEqualToString:@"divide"]) {
        value =self.threeDivideMean;
    }else if ([key isEqualToString:@"desc"]) {
        value =self.desc;
    }
    if (!value.length) {
        value = @"";
    }
    return value;
}

-(void)setVauleWithKey:(NSString *)key value:(NSString *)value{

    if ([key isEqualToString:@"item"]) {
        self.item =value;
    }else if ([key isEqualToString:@"upper"]) {
        self.upper=value;
    }else if ([key isEqualToString:@"low"]) {
        self.low=value;
    }else if ([key isEqualToString:@"usl"]) {
        self.usl=value;
    }else if ([key isEqualToString:@"lsl"]) {
        self.lsl=value;
    }

}


-(void)setCpkOrig:(NSString *)cpkOrig low:(NSString *)low high:(NSString *)high{
    _cpkOrig = cpkOrig;
    if (![cpkOrig.lowercaseString isEqualToString:@"null"]) {
        float int_cpkOrig = cpkOrig.floatValue;
        float float_low = low.floatValue;
        float float_high = high.floatValue;
        if (int_cpkOrig<float_high &&int_cpkOrig>float_low) {
            _isCpkPass = CpkOrigResultTypeGreen;
        }else if(int_cpkOrig>=float_high){
            _isCpkPass = CpkOrigResultTypeYellow;
        }else if(int_cpkOrig<=float_low){
            _isCpkPass = CpkOrigResultTypeRed;
        }
    }else{
    
        _isCpkPass = CpkOrigResultTypeNull;
    }

}

-(NSString *)lsl{
    if (_lsl == nil) {
        _lsl = @"";
    }
    return _lsl;
}

-(NSString *)usl{
    if (_usl == nil) {
        _usl = @"";
    }
    return _usl;
}


-(BOOL)isNotApply{
    if ((_lsl.length || _usl.length) &&_needUpdate==NO) {
        
        
        return YES;
    }else{
        return NO;
    }
}

@end
