//
//  LLDownLoadDataProvider.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDownLoadDataProvider.h"
#import "LLSessionManager.h"
#import "MJExtension.h"

#define kBaseUrl @"http://mobile.ximalaya.com/"


@interface LLDownLoadDataProvider ()

@property (nonatomic, strong) LLSessionManager *sessionManager;

@end

@implementation LLDownLoadDataProvider

+ (instancetype)shareInstance{
    
    static LLDownLoadDataProvider *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (LLSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [[LLSessionManager alloc] init];
    }
    return _sessionManager;
}

- (void)getTodayFireCategoryMs: (void(^)(NSArray <LLCategoryModel *>*categoryMs))resultBlock {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseUrl, @"mobile/discovery/v2/rankingList/track"];
    NSDictionary *param = @{
                            @"device": @"iPhone",
                            @"key": @"ranking:track:scoreByTime:1:0",
                            @"pageId": @"1",
                            @"pageSize": @"0"
                            };
    
    [self.sessionManager request:RequestTypeGet urlStr:url parameter:param resultBlock:^(id responseObject, NSError *error) {
        
        LLCategoryModel *categoryM = [[LLCategoryModel alloc] init];
        categoryM.key = @"ranking:track:scoreByTime:1:0";
        categoryM.name = @"总榜";
        
        NSMutableArray <LLCategoryModel *>*categoryMs = [LLCategoryModel mj_objectArrayWithKeyValuesArray:responseObject[@"categories"]];
        if (categoryMs.count > 0) {
            [categoryMs insertObject:categoryM atIndex:0];
        }
        resultBlock(categoryMs);
    }];
}

- (void)getTodayFireVoiceMsWithKey: (NSString *)key result: (void(^)(NSArray <LLDownLoadVoiceModel *>*voiceMs)) resultBlock {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseUrl, @"mobile/discovery/v2/rankingList/track"];
    NSDictionary *param = @{
                            @"device": @"iPhone",
                            @"key": key,
                            @"pageId": @"1",
                            @"pageSize": @"30"
                            };
    [self.sessionManager request:RequestTypeGet urlStr:url parameter:param resultBlock:^(id responseObject, NSError *error) {
        
        NSMutableArray <LLDownLoadVoiceModel *>*voiceyMs = [LLDownLoadVoiceModel mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        resultBlock(voiceyMs);
    }];
    
    
}



@end
