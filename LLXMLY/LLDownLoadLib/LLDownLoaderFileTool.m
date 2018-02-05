//
//  LLDownLoaderFileTool.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoaderFileTool.h"

@implementation LLDownLoaderFileTool

+ (BOOL)isFileExists: (NSString *)path {
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (long long)fileSizeWithPath: (NSString *)path {
    if (![self isFileExists:path]) {
        return 0;
    }
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    long long size = [fileInfo[NSFileSize] longLongValue];
    return size;
}

+ (void)moveFile:(NSString *)fromPath toPath: (NSString *)toPath {
    if (![self isFileExists:fromPath]) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removeFileAtPath: (NSString *)path {
    if (![self isFileExists:path]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];    
}

@end
