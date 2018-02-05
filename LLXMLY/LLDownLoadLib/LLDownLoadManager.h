//
//  LLDownLoadManager.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLDownLoader.h"

@interface LLDownLoadManager : NSObject

// 单例
+ (instancetype)shareInstance;

// 根据URL下载资源
- (LLDownLoader *)downLoadWithURL: (NSURL *)url;

// 获取url对应的downLoader
- (LLDownLoader *)getDownLoaderWithURL: (NSURL *)url;

// 根据URL下载资源
// 监听下载信息, 成功, 失败回调
- (void)downLoadWithURL: (NSURL *)url downLoadInfo: (DownLoadInfoType)downLoadBlock success: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failBlock;

// 根据URL暂停资源
- (void)pauseWithURL: (NSURL *)url;

// 根据URL取消资源
- (void)cancelWithURL: (NSURL *)url;
- (void)cancelAndClearWithURL: (NSURL *)url;

// 暂停所有
- (void)pauseAll;

// 恢复所有
- (void)resumeAll;





@end
