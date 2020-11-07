//
//  LoadingVC.h
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/5.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CWGeneralManager/MyViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface LoadingVC : MyViewController

@property(strong,nonatomic)NSString *showingText;
@property (readonly)BOOL isShowing;


+(LoadingVC *)loadingVC;

@end

NS_ASSUME_NONNULL_END
