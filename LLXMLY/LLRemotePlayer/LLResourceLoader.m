//
//  LLResourceLoader.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLResourceLoader.h"
#import "LLAudioFileTool.h"
#import "NSURL+LLAudio.h"
#import "LLAudioDownLoader.h"

@interface LLResourceLoader ()<LLAudioDownLoaderDelegate>

@property (nonatomic, strong) LLAudioDownLoader *downLoader;

@property (nonatomic, strong) NSMutableArray <AVAssetResourceLoadingRequest *>*loadingRequests;

@end

@implementation LLResourceLoader


- (LLAudioDownLoader *)downLoader {
    if(!_downLoader) {
        _downLoader = [[LLAudioDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

- (NSMutableArray<AVAssetResourceLoadingRequest *> *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}


- (void)handleAllRequest {
    
    NSMutableArray *complete = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        
        // 直接拿本地的临时缓存数据, 给请求, 让请求, 帮我们返回给服务器
        NSURL *url = loadingRequest.request.URL;
        // 1. 填充信息头
        loadingRequest.contentInformationRequest.contentType = self.downLoader.contentType;
        loadingRequest.contentInformationRequest.contentLength = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 返回数据
        // 2.1 计算请求的数据区间
        long long requestOffSet = loadingRequest.dataRequest.requestedOffset;
        if (loadingRequest.dataRequest.currentOffset != 0) {
            requestOffSet = loadingRequest.dataRequest.currentOffset;
        }
        long long requestLength = loadingRequest.dataRequest.requestedLength;
        
        // 2.2 根据请求的区间, 看下,本地的临时缓存,能够返回多少
        long long responseOffset = requestOffSet - self.downLoader.offset;
        long long responseLength = MIN(requestLength, self.downLoader.offset + self.downLoader.loadedSize - requestOffSet);
        
        NSData *data = [NSData dataWithContentsOfFile:[LLAudioFileTool tmpPathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
        if (data.length == 0) {
            data = [NSData dataWithContentsOfFile:[LLAudioFileTool cachePathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        if (loadingRequest.dataRequest) {
            [loadingRequest.dataRequest respondWithData:subData];
            // 3. 完成请求(byteRange) (必须, 是这个请求的数据, 全部都给完了, 完成)
            if (requestLength == responseLength) {
                [loadingRequest finishLoading];
                [complete addObject:loadingRequest];
            }
        }
        
        
    }
    
    
    [self.loadingRequests removeObjectsInArray:complete];
    
}

// 只要播放器, 想要播放某个资源, 都会让资源组织者, 命令资源请求者, 调用这个方法, 去发送请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"发送某个请求--%@", loadingRequest);
    
    [self.loadingRequests addObject:loadingRequest];
    
    // 下载的url地址
    NSURL *url = [loadingRequest.request.URL httpURL];
    
    long long requestOffSet = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestOffSet = loadingRequest.dataRequest.currentOffset;
    }
    
    if ([LLAudioFileTool isCacheFileExists:url])
    {
        // 三个步骤, 直接响应数据
        [self handleRequestWithLoadingRequest:loadingRequest];
        
        return YES;
    }
    
    if (self.downLoader.loadedSize == 0) {
        [self.downLoader downLoadWithURL:url offset:0];
        return YES;
    }
    
    if (requestOffSet < self.downLoader.offset || requestOffSet > self.downLoader.offset + self.downLoader.loadedSize + 666) {
        [self.downLoader downLoadWithURL:url offset:0];
        return YES;
    }
    // 请求的数据, 就在正在下载当中
    // 在正在下载数据当中, data -> 播放器
    [self handleAllRequest];
    
    
    return YES;
}

// 取消某个请求的时候调用
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"取消请求");
    [self.loadingRequests removeObject:loadingRequest];
}


#pragma mark - 私有方法

- (void)handleRequestWithLoadingRequest: (AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *url = [loadingRequest.request.URL httpURL];
    // 1. 填充信息头
    loadingRequest.contentInformationRequest.contentType = [LLAudioFileTool contentTypeWithURL:url];
    loadingRequest.contentInformationRequest.contentLength = [LLAudioFileTool cacheFileSizeWithURL:url];
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    
    // 2. 响应数据
    NSData *data = [NSData dataWithContentsOfFile:[LLAudioFileTool cachePathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLen = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLen)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3. 完成这个请求
    [loadingRequest finishLoading];
}

#pragma mark - 下载协议

- (void)downLoaderLoading {
    [self handleAllRequest];
    
}



@end
