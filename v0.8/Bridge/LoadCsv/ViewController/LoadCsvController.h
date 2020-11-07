//
//  LoadCsvController.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/27.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CWGeneralManager/MyViewController.h>

NS_ASSUME_NONNULL_BEGIN
@protocol LoadCsvControllerDelegate< NSObject>

-(void)LoadCsvControllerApplyClickWithDataPath:(NSString *)dataPath scriptPath:(NSString *)scriptPath cpkLTHL:(NSString *)cpkLTHL cpkHTHL:(NSString *)cpkHTHL;

@end
@interface LoadCsvController : MyViewController
@property(weak)id<LoadCsvControllerDelegate>loadCsvDelegate;
@end

NS_ASSUME_NONNULL_END
