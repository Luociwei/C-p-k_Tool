//
//  Feed.h
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/6.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feed : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray<FeedItem *> *children;

- (instancetype)initWithName:(NSString *)name;
+ (NSMutableArray<Feed *> *)pathList:(NSString *)fileName;

+ (void)addToPathWrite:(NSString *)fileName withAddPath:(NSString *)addPath with:(int)flag;
+ (void)addToItemClick:(NSString *)fileName withLine:(int)line ItemClick:(int)state with:(int)flag;

@end

NS_ASSUME_NONNULL_END
