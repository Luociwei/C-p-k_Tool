//
//  ColorBy2Mode.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/7/3.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "ColorBy2Mode.h"

@implementation ColorBy2Mode

//diagsVersionArr
- (NSMutableSet*)diagsVersionArr{
    if(!_diagsVersionArr){
        _diagsVersionArr = [[NSMutableSet alloc]init];
    }
    
    return _diagsVersionArr;
}



- (NSMutableSet*)productArray{
    if(!_productArray){
        _productArray = [[NSMutableSet alloc]init];
    }
    
    return _productArray;
}

- (NSMutableSet*)versionArray{
    if(!_versionArray){
        _versionArray = [[NSMutableSet alloc]init];
    }
    

    return _versionArray;
}

- (NSMutableSet*)channelIDArray{
    if(!_channelIDArray){
        _channelIDArray = [[NSMutableSet alloc]init];
    }

    return _channelIDArray;
}

- (NSMutableSet*)specialBuildNameArr{
    if(!_specialBuildNameArr){
        _specialBuildNameArr = [[NSMutableSet alloc]init];
    }

    return _specialBuildNameArr;
}

- (NSMutableSet*)stationIDArr{
    if(!_stationIDArr){
        _stationIDArr = [[NSMutableSet alloc]init];
    }

    return _stationIDArr;
}
@end
