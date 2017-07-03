//
//  LLAudioFileTool.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLAudioFileTool.h"
#import <MobileCoreServices/MobileCoreServices.h>


#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()


@implementation LLAudioFileTool


+ (NSString *)cachePathWithURL: (NSURL *)url {
    return [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (NSString *)tmpPathWithURL: (NSURL *)url {
    return [kTmpPath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (BOOL)isCacheFileExists: (NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:url]];
}

+ (BOOL)isTmpFileExists: (NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self tmpPathWithURL:url]];
}

+ (NSString *)contentTypeWithURL: (NSURL *)url {
    
    NSString *fileExtension = url.absoluteString.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    
    return contentType;
    
}

+ (long long)cacheFileSizeWithURL: (NSURL *)url {
    
    
    if (![self isCacheFileExists:url]) {
        return 0;
    }
    
    NSString *path = [self cachePathWithURL:url];
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfo[NSFileSize] longLongValue];
    
}

+ (long long)tmpFileSizeWithURL: (NSURL *)url {
    
    if (![self isTmpFileExists:url]) {
        return 0;
    }
    NSString *path = [self tmpPathWithURL:url];
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfo[NSFileSize] longLongValue];
    
    
}

+ (void)removeTmpFileWithURL: (NSURL *)url {
    if ([self isTmpFileExists:url]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[self tmpPathWithURL:url] error:nil];
    }
}


+ (void)moveTmpPathToCachePath: (NSURL *)url {
    
    
    if ([self isTmpFileExists:url]) {
        NSString *tmpPath = [self tmpPathWithURL:url];
        NSString *cachePath = [self cachePathWithURL:url];
        
        [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:cachePath error:nil];
    }
    
}



@end
