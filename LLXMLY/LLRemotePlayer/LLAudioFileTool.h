//
//  LLAudioFileTool.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLAudioFileTool : NSObject

+ (NSString *)cachePathWithURL: (NSURL *)url;

+ (NSString *)tmpPathWithURL: (NSURL *)url;

+ (BOOL)isCacheFileExists: (NSURL *)url;

+ (BOOL)isTmpFileExists: (NSURL *)url;

+ (NSString *)contentTypeWithURL: (NSURL *)url;

+ (long long)cacheFileSizeWithURL: (NSURL *)url;

+ (long long)tmpFileSizeWithURL: (NSURL *)url;

+ (void)removeTmpFileWithURL: (NSURL *)url;

+ (void)moveTmpPathToCachePath: (NSURL *)url;


@end
