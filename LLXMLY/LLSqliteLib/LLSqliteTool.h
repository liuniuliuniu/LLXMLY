//
//  LLSqliteTool.h
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLSqliteTool : NSObject

+ (BOOL)dealSql: (NSString *)sql withUID: (NSString *)uid;

+ (BOOL)dealSqls: (NSArray <NSString *>*)sqls withUID: (NSString *)uid;

+ (NSArray <NSDictionary *>*)querySql: (NSString *)sql withUID: (NSString *)uid;

@end
