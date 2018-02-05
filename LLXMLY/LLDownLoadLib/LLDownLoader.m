//
//  LLDownLoader.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoader.h"
#import "NSString+LLDownLoader.h"
#import "LLDownLoaderFileTool.h"



#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmp NSTemporaryDirectory()

@interface LLDownLoader ()<NSURLSessionDataDelegate>
{
    // 临时文件的大小
    long long _tmpFileSize;
    // 文件的总大小
    long long _totalFileSize;

}
/** 文件的缓存路径 */
@property (nonatomic, copy) NSString *cacheFilePath;
/** 文件的临时缓存路径 */
@property (nonatomic, copy) NSString *tmpFilePath;
/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;
/** 文件输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;
/** 下载任务 */
@property (nonatomic, weak) NSURLSessionDataTask *task;

@property (nonatomic, weak) NSURL *url;

@end


@implementation LLDownLoader


#pragma mark - 接口

+ (NSString *)downLoadedFileWithURL: (NSURL *)url {
    
    NSString *cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    
    if([LLDownLoaderFileTool isFileExists:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
    
}
+ (long long)tmpCacheSizeWithURL: (NSURL *)url {
    
    NSString *tmpFileMD5 = [url.absoluteString md5Str];
    NSString *tmpPath = [kTmp stringByAppendingPathComponent:tmpFileMD5];
    return  [LLDownLoaderFileTool fileSizeWithPath:tmpPath];
}

+ (void)clearCacheWithURL: (NSURL *)url {
    NSString *cachePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    [LLDownLoaderFileTool removeFileAtPath:cachePath];
}

- (void)downLoadWithURL: (NSURL *)url downLoadInfo: (DownLoadInfoType)downLoadBlock success: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failBlock {
    
    self.downLoadInfo = downLoadBlock;
    self.downLoadSuccess = successBlock;
    self.downLoadError = failBlock;
    
    [self downLoadWithURL:url];
    
}

- (void)downLoadWithURL: (NSURL *)url {
    
    self.url = url;
    // 1. 下载文件的存储
    //    下载中 -> tmp + (url + MD5)
    //    下载完成 -> cache + url.lastCompent
    self.cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [kTmp stringByAppendingPathComponent:[url.absoluteString md5Str]];
    
    
    // 1 首先, 判断, 本地有没有已经下载好, 已经下载完毕, 就直接返回
    // 文件的位置, 文件的大小
    if ([LLDownLoaderFileTool isFileExists:self.cacheFilePath]) {
        NSLog(@"文件已经下载完毕, 直接返回相应的数据--文件的具体路径, 文件的大小");
        
        if (self.downLoadInfo) {
            self.downLoadInfo([LLDownLoaderFileTool fileSizeWithPath:self.cacheFilePath]);
        }
        
        self.state = LLDownLoaderStateSuccess;
        
        if (self.downLoadSuccess) {
            self.downLoadSuccess(self.cacheFilePath);
        }
        
        return;
    }
    
    // 验证: 如果当前任务不存在 -> 开启任务
    if ([url isEqual:self.task.originalRequest.URL]) {
        // 任务存在 -> 状态
        // 状态 -> 正在下载 返回
        if (self.state == LLDownLoaderStateDowning)
        {
            return;
        }
        // 状态 -> 暂停 = 恢复
        if (self.state == LLDownLoaderStatePause)
        {
            [self resume];
            return;
        }
        
        // 取消, 重新下载 == 失败
    }
    
    // 任务不存在, url不一样
    [self cancel];
    // 2. 读取本地的缓存大小
    _tmpFileSize = [LLDownLoaderFileTool fileSizeWithPath:self.tmpFilePath];
    [self downLoadWithURL:url offset:_tmpFileSize];
}

// 暂停了几次, 恢复几次, 才可以恢复
- (void)resume {
    if (self.state == LLDownLoaderStatePause) {
        [self.task resume];
        self.state = LLDownLoaderStateDowning;
    }
}

// 暂停, 暂停任务, 可以恢复, 缓存没有删除
// 恢复了几次, 暂停几次, 才可以暂停
- (void)pause {
    if (self.state == LLDownLoaderStateDowning)
    {
        [self.task suspend];
        self.state = LLDownLoaderStatePause;
    }
    
}

// 取消, 这次任务已经被取消, 缓存删除
- (void)cancel {
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndClearCache {
    [self cancel];
    [LLDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
}

#pragma mark - 私有方法
- (void)downLoadWithURL:(NSURL *)url offset: (long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
    self.task = task;
}


#pragma mark - NSURLSessionDataDelegate
/**
 当发送的请求, 第一次接受到响应的时候调用,
 
 @param completionHandler 系统传递给我们的一个回调代码块, 我们可以通过这个代码块, 来告诉系统,如何处理, 接下来的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpResponse.allHeaderFields[@"Content-Range"] ;
        _totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    if (self.downLoadInfo) {
        self.downLoadInfo(_totalFileSize);
    }
    // 判断, 本地的缓存大小 与 文件的总大小
    // 缓存大小 == 文件的总大小 下载完成 -> 移动到下载完成的文件夹
    if (_tmpFileSize == _totalFileSize) {
        NSLog(@"文件已经下载完成, 移动数据");
        // 移动临时缓存的文件 -> 下载完成的路径
        [LLDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        self.state = LLDownLoaderStateSuccess;
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    if (_tmpFileSize > _totalFileSize) {
        
        NSLog(@"缓存有问题, 删除缓存, 重新下载");
        // 删除缓存
        [LLDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
        
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新发送请求  0
        [self downLoadWithURL:response.URL offset:0];
        return;
    }
    
    // 继续接收数据,什么都不要处理
    NSLog(@"继续接收数据");
    self.state = LLDownLoaderStateDowning;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

// 接收数据的时候调用
// 100M
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 进度 = 当前下载的大小 / 总大小
    _tmpFileSize += data.length;
    self.progress = 1.0 * _tmpFileSize / _totalFileSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self.outputStream close];
    self.outputStream = nil;
    if (error == nil) {
        NSLog(@"下载完毕, 成功");
        // 移动数据  temp - > cache
        [LLDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        self.state = LLDownLoaderStateSuccess;
        if (self.downLoadSuccess) {
            self.downLoadSuccess(self.cacheFilePath);
        }
    }else {
        NSLog(@"有错误---");
        //        error.code
        //        error.localizedDescription;
        self.state = LLDownLoaderStateFailed;
        if (self.downLoadError) {
            self.downLoadError();
        }
    }
}

#pragma mark - 懒加载
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)setState:(LLDownLoaderState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.downLoadStateChange) {
        self.downLoadStateChange(state);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadURLOrStateChangeNotification object:nil userInfo:@{                                                                                                                           @"downLoadURL": self.url,                                                                                                                           @"downLoadState": @(self.state)                                                                                                                           }];
}
- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.downLoadProgress) {
        self.downLoadProgress(progress);
    }
}

@end
