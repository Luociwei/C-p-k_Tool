//
//  CWFileManager.h
//  Callisto_Charge
//
//  Created by ciwei luo on 2018/7/5.
//  Copyright © 2017 ciwei luo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CWFileManager : NSObject

+(void)cw_createFile:(NSString *)filePath isDirectory:(BOOL)isDirectory;
+(BOOL)cw_isFileExistAtPath:(NSString*)fileFullPath;
//文件是否能够写
+(BOOL)cw_fileCanWrite:(NSString*)filePath;

+(NSString *)cw_readFromFile:(NSString *)filePath;

+(BOOL)cw_writeToFile:(NSString*)filePath content:(NSString*)content;
+(BOOL)cw_fileHandleWriteToFile:(NSString *)filePath content:(NSString *)content;

+(void)cw_removeItemAtPath:(NSString *)filePath;

+(id)cw_serializationWithJsonFilePath:(NSString *)filePath;

+ (id)cw_serializationInMainBundleFile:(NSString *)fileName;
+(void)cw_openFileWithPath:(NSString *)path;

+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;

+(void)cw_copyBundleFileToDestPath:(NSString *)fullName destDir:(NSString *)destDir;

+(void)cw_copySourceFileToDestPath:(NSString *)sourcePath destDir:(NSString *)destDir;
+(void)openPanel:(void(^)(NSString * path))callBack;
+(void)savePanel:(void(^)(NSString * path))callBack;
@end

NS_ASSUME_NONNULL_END
