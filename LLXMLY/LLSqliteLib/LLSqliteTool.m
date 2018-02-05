//
//  LLSqliteTool.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLSqliteTool.h"
#import "sqlite3.h"


#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@implementation LLSqliteTool

static sqlite3 *_ppDb;

+ (BOOL)dealSql: (NSString *)sql withUID: (NSString *)uid {
    [self openDBWithUID:uid];
    BOOL result = sqlite3_exec(_ppDb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    [self closeDBWithUID:uid];
    return result;
}

+ (BOOL)dealSqls: (NSArray <NSString *>*)sqls withUID: (NSString *)uid {
    [self openDBWithUID:uid];
    [self beginTransaction];
    for (NSString *sql in sqls) {
        BOOL result = sqlite3_exec(_ppDb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
        if (!result) {
            [self rollBackTransaction];
            return NO;
        }
    }
    [self commitTransaction];
    [self closeDBWithUID:uid];
    return YES;
}

+ (void)beginTransaction {
    sqlite3_exec(_ppDb, "begin transaction", nil, nil, nil);
}

+ (void)commitTransaction {
    sqlite3_exec(_ppDb, "commit transaction", nil, nil, nil);
}

+ (void)rollBackTransaction {
    sqlite3_exec(_ppDb, "rollback transaction", nil, nil, nil);
}

+ (NSArray <NSDictionary *>*)querySql: (NSString *)sql withUID: (NSString *)uid {
    
    [self openDBWithUID:uid];
    // "select * from t_stu";
    
    // 1. 创建一个准备语句
    sqlite3_stmt *ppStmt;
    if (sqlite3_prepare(_ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        NSLog(@"预处理失败");
        sqlite3_finalize(ppStmt);
        [self closeDBWithUID:uid];
        return nil;
    }
    NSMutableArray *rowDicArray = [NSMutableArray array];
    // 2. 执行
    // 如果下一行有记录, 就会返回 SQLITE_ROW, 会自动移动指针, 到下一行
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        // 一条记录 , 都会执行这个循环
        // 解析一条记录 (列,  每一列的列名, 每一列的值)
        // 1. 获取, 列的个数
        int columnCount = sqlite3_column_count(ppStmt);
        NSMutableDictionary *rowDic = [NSMutableDictionary dictionary];
        [rowDicArray addObject:rowDic];
        // 2. 遍历列 (列名, 值)
        for (int i = 0; i < columnCount; i++) {
            // 这一行的每一列
            // 列名
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(ppStmt, i)];
            // 列的值
            // 不同的列, 如果类型不同, 我们需要使用不同的函数, 获取响应的值
            // 1. 获取这一列对应的类型
            int type = sqlite3_column_type(ppStmt, i);
            // 2. 根据不同的类型, 使用不同的函数,获取相应的值
            //#define SQLITE_INTEGER  1
            //#define SQLITE_FLOAT    2
            //#define SQLITE_BLOB     4
            //#define SQLITE_NULL     5
            //#define SQLITE3_TEXT     3
            id value;
            switch (type) {
                case SQLITE_INTEGER:
                {
                    //                    NSLog(@"整形");
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                }
                case SQLITE_FLOAT:
                {
                    //                    NSLog(@"浮点");
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                }
                case SQLITE_BLOB:
                {
                    //                    NSLog(@"二进制");
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                }
                case SQLITE_NULL:
                {
                    //                    NSLog(@"空");
                    value = @"";
                    break;
                }
                case SQLITE3_TEXT:
                {
                    //                    NSLog(@"文本");
                    const char *valueC = (const char *)sqlite3_column_text(ppStmt, i);
                    value = [NSString stringWithUTF8String:valueC];
                    break;
                }
                default:
                    break;
            }
            //            NSLog(@"%@---%@", columnName, value);
            [rowDic setValue:value forKey:columnName];
        }
    }
    // 3. 释放
    sqlite3_finalize(ppStmt);
    [self closeDBWithUID:uid];
    return rowDicArray;
}

+ (BOOL)openDBWithUID: (NSString *)uid {
    // 确定哪个数据库
    // cache
    NSString *dbPath;
    if (uid.length == 0) {
        dbPath = [kCache stringByAppendingPathComponent:@"common.db"];
    }else {
        dbPath = [kCache stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", uid]];
    }
    // 1. 打开数据库(如果数据库不存在, 创建)
    if (sqlite3_open(dbPath.UTF8String, &_ppDb) != SQLITE_OK) {
        NSLog(@"打开数据库失败");
        return NO;
    }
    return YES;
}

+ (void)closeDBWithUID: (NSString *)uid {
    // 3. 关闭数据库
    sqlite3_close(_ppDb);
}

@end
