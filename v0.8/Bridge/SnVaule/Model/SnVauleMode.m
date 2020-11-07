//
//  SnVauleMode.m
//  OPP_Tool
//
//  Created by ciwei luo on 2020/5/27.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "SnVauleMode.h"

@implementation SnVauleMode

-(NSString *)getVauleWithKey:(NSString *)key{
    NSString *value = @"";
    if ([key isEqualToString:@"index"]) {
        value = [NSString stringWithFormat:@"%ld",self.index];
    }
    else if ([key isEqualToString:@"sn"]) {
        value = self.sn;
    }else if ([key isEqualToString:@"value"]) {
        value = self.value;
        if (!value.length) {
            value = @"";
        }
//        
    }
    
    return value;
}


-(NSString *)result{
    if (_value.length) {
        if ([self isNum:_value]&&[self isNum:_low]&&[self isNum:_upper]) {
            float float_low = [_low floatValue];
            //                if ([self.low.uppercaseString isEqualToString:@"NA"]) {
            //                    float_low = -99999999999999;
            //                }
            float float_upper = [_upper floatValue];
            float float_value = [_value floatValue];
            if (float_value>=float_low && float_value <= float_upper) {
                _result = @"PASS";
            }else{
                _result = @"FAIL";
            }
        }else if ([_low.uppercaseString containsString:@"NA"] || [_upper.uppercaseString containsString:@"NA"] || [self.low.uppercaseString containsString:@"N/A"]){
            _result = @"PASS";
        }
        else{
            
            _result = @"FAIL";
        }
        
    }else{
        _value = @"";
        _result = @"PASS";
    }
    
    return _result;
}


- (BOOL)isNum:(NSString *)checkedNumString {
    NSCharacterSet *str=[[NSCharacterSet characterSetWithCharactersInString:@".1234567890-"] invertedSet];
    NSString *filter=[[checkedNumString componentsSeparatedByCharactersInSet:str] componentsJoinedByString:@""];
    BOOL isNum = [checkedNumString isEqualToString:filter];
    return isNum;
}

@end
