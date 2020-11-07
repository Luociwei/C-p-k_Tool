//
//  ShowingLogVC.h
//  TestPlanEditor
//
//  Created by ciwei luo on 2020/1/17.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowingLogVC : NSViewController
+(void)postNotificationWithLog:(NSString *)log type:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
