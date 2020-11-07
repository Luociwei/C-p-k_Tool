//
//  PythonTask.h
//  TestDemo
//
//  Created by ciwei luo on 2020/4/20.
//  Copyright © 2017 ciwei luo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PythonTask : NSObject
-(instancetype)initWithPythonPath:(NSString*)path parArr:(NSArray *)parArr lauchPath:(NSString *)lauchPath;
//-(BOOL)Init:(NSString*)path port:(NSString*) portName;
//-(instancetype)initWithPythonPath:(NSString*)path parArr:(NSArray *)parArr;
-(void)setParArr:(NSArray *)parArr  pythonPath:(NSString*)path;
-(NSString*)send:(NSString*)command;
//-(NSString*)timeoutsend:(NSString*)command;
-(BOOL)close;
-(BOOL)isOpen;
-(NSString*)read;
-(instancetype)initWithShellPath:(NSString*)filePath parArr:(NSArray *)parArr pythonPath:(NSString *)pythonPath;
@property (nonatomic,strong) NSFileHandle *writeHandle;
@end

NS_ASSUME_NONNULL_END
