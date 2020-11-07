//
//  SnVauleMode.h
//  OPP_Tool
//
//  Created by ciwei luo on 2020/5/27.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
static NSString * const title_site = @"Site";
static NSString * const title_product = @"Product";
static NSString * const title_sn = @"SerialNumber";
static NSString * const title_specialBN = @"Special Build Name";

static NSString * const title_specialBD = @"Special Build Description";
static NSString * const title_unitN = @"Unit Number";
static NSString * const title_stationId = @"Station ID";
static NSString * const title_totalResult = @"Test Pass/Fail Status";


static NSString * const title_startTime = @"StartTime";
static NSString * const title_endTime = @"EndTime";
static NSString * const title_version = @"Version";
static NSString * const title_listFailTests = @"List of Failing Tests";

static NSString * const title_diagsVersion = @"Diags_Version";


@interface SnVauleMode : NSObject
@property (nonatomic)NSInteger index;
@property (nonatomic,copy)NSString *sn;
@property (nonatomic,copy)NSString *value;
-(NSString *)getVauleWithKey:(NSString *)key;

@property (nonatomic,copy)NSString *upper;
@property (nonatomic,copy)NSString *low;
@property (nonatomic,copy)NSString *result;



@property (nonatomic,copy)NSString *site;
@property (nonatomic,copy)NSString *product;
@property (nonatomic,copy)NSString *specialBuildName;//Special Build Description
@property (nonatomic,copy)NSString *specialBuildDescription;//Unit Number
@property (nonatomic,copy)NSString *unitNumber;
@property (nonatomic,copy)NSString *stationId;
@property (nonatomic,copy)NSString *totalResult;
@property (nonatomic,copy)NSString *startTime;
@property (nonatomic,copy)NSString *endTime;
@property (nonatomic,copy)NSString *version;
@property (nonatomic,copy)NSString *diagsVersion;
@property (nonatomic,copy)NSString *listOfFailingTests;
@property (nonatomic,copy)NSString *itemName;
@property (nonatomic,copy)NSString *stationFxitureChannelId;
//@"SerialNumber",@"Version",@"Station ID",@"Special Build Name"
@end

NS_ASSUME_NONNULL_END
