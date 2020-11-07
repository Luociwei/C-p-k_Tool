//
//  ColorByMode.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/5.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "ColorByMode.h"

@implementation ColorByMode
-(NSString *)getVauleWithKey:(NSString *)key snVauleMode:(SnVauleMode *)snVauleMode{
    NSString *title = @"";
//    if ([key.lowercaseString containsString:@"serialnumber"]) {
//        title = snVauleMode.sn;
//    }else 
  if ([key.lowercaseString isEqualToString:@"version"]){
        title = snVauleMode.version;
  }else if ([key.lowercaseString containsString:@"product"]){
      title = snVauleMode.product;
  }else if ([key.lowercaseString containsString:@"station id"]){
        title = snVauleMode.stationId;
    }else if ([key.lowercaseString containsString:@"special build name"]){
        title = snVauleMode.specialBuildName;
    }else if ([key.uppercaseString isEqualToString:@"FIXTURE CHANNEL ID"]||[key.uppercaseString isEqualToString:@"FIXTURE INITILIZATION SLOT_ID"]||[key.uppercaseString isEqualToString:@"FIXTURE RESET CALC FIXTURE_CHANNEL"]||[key.uppercaseString isEqualToString:@"HEAD ID"]){
        title = snVauleMode.stationFxitureChannelId;
    }else if ([key.lowercaseString containsString:@"diags"]&&[key.lowercaseString containsString:@"version"]){
        title = snVauleMode.diagsVersion;
    }
    
    return title;
    
}

- (ColorBy2Mode*)colorBy2Mode{
    if(!_colorBy2Mode){
        _colorBy2Mode = [ColorBy2Mode new];
    }
    
    return _colorBy2Mode;
}

//@"SerialNumber",@"Version",@"Station ID",@"Special Build Name"
@end
