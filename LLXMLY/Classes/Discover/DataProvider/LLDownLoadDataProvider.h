//
//  LLDownLoadDataProvider.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/4.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLCategoryModel.h"
#import "LLDownLoadVoiceModel.h"



@interface LLDownLoadDataProvider : NSObject


+ (instancetype)shareInstance;

- (void)getTodayFireCategoryMs: (void(^)(NSArray <LLCategoryModel *>*categoryMs))resultBlock;

- (void)getTodayFireVoiceMsWithKey: (NSString *)key result: (void(^)(NSArray <LLDownLoadVoiceModel *>*voiceMs)) resultBlock;


@end
