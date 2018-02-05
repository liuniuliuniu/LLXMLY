//
//  LLDownLoadManager.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoadManager.h"
#import "NSString+LLDownLoader.h"

@interface LLDownLoadManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, LLDownLoader *>*downLoadInfo;

@end

@implementation LLDownLoadManager

static LLDownLoadManager *_shareInstance;
+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[LLDownLoadManager alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

- (void)downLoadWithURL: (NSURL *)url downLoadInfo: (DownLoadInfoType)downLoadBlock success: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failBlock {
    
    NSString *md5 = [url.absoluteString md5Str];
    
    LLDownLoader *downLoader = self.downLoadInfo[md5];
    if (downLoader) {
        [downLoader resume];
        return ;
    }
    downLoader = [[LLDownLoader alloc] init];
    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoadWithURL:url downLoadInfo:downLoadBlock success:^(NSString *cacheFilePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if(successBlock) {
            successBlock(cacheFilePath);
        }
    } failed:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if (failBlock) {
            failBlock();
        }
    }];
    
    return ;
}

- (LLDownLoader *)downLoadWithURL: (NSURL *)url {
    
    // 文件名称  aaa/a.x  bb/a.x
    NSString *md5 = [url.absoluteString md5Str];
    LLDownLoader *downLoader = self.downLoadInfo[md5];
    if (downLoader) {
        [downLoader resume];
        return downLoader;
    }
    downLoader = [[LLDownLoader alloc] init];
    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoadWithURL:url downLoadInfo:nil success:^(NSString *cacheFilePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    } failed:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    }];
    
    return downLoader;
}

- (LLDownLoader *)getDownLoaderWithURL: (NSURL *)url {
    NSString *md5 = [url.absoluteString md5Str];
    LLDownLoader *downLoader = self.downLoadInfo[md5];
    return downLoader;
}

- (void)pauseWithURL: (NSURL *)url {
    NSString *md5 = [url.absoluteString md5Str];
    LLDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader pause];
}

- (void)cancelWithURL: (NSURL *)url {
    NSString *md5 = [url.absoluteString md5Str];
    LLDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader cancel];
}

- (void)cancelAndClearWithURL: (NSURL *)url {
    NSString *md5 = [url.absoluteString md5Str];
    LLDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader cancelAndClearCache];
}

- (void)pauseAll {
    [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(pause)];
}


- (void)resumeAll {
    [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(resume)];
}

@end
