//
//  LLModelTool.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLModelTool.h"
#import <objc/message.h>

@implementation LLModelTool

/**
 获取表格名称
 */
+ (NSString *)getTableNameWithModelClass: (Class)cls {
    return [NSStringFromClass(cls) lowercaseString];
}

/**
 获取临时表格名称
 */
+ (NSString *)getTempTableNameWithModelClass: (Class)cls {
    return [[NSStringFromClass(cls) lowercaseString] stringByAppendingString:@"_tmp"];
}

/**
 获取模型会被创建成为表格的  成员变量名称和类型组成的字典
 {key: 成员变量名称,取出下划线  value: 值}
 类型: runtime获取的类型
 */
+ (NSDictionary *)getModelIvarNameIvarTypeDic: (Class)cls {
    
    unsigned int outCount;
    Ivar *varList = class_copyIvarList(cls, &outCount);
    NSMutableDictionary *varNameType = [NSMutableDictionary dictionary];
    
    NSArray *ignoreNames;
    if ([cls instancesRespondToSelector:@selector(ignoreIvarNames)]) {
        ignoreNames = [[cls new] ignoreIvarNames];
    }
    
    for (int i = 0; i < outCount; i ++) {
        Ivar var  = varList[i];
        // 名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(var)];;
        if ([[ivarName substringToIndex:1] isEqualToString:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        // 类型
        NSString *ivarType = [[NSString stringWithUTF8String:ivar_getTypeEncoding(var)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        if (![ignoreNames containsObject:ivarName]) {
            [varNameType setValue:ivarType forKey:ivarName];
        }
    }
    return varNameType;
}

/**
 获取模型里面, 需要创建表格的所有字段/类型, 组成的数组
 */
+ (NSDictionary *)getModelIvarNameSqlTypeDic: (Class)cls {
    
    NSMutableDictionary *ivarNameIvarTypeDic = [[self getModelIvarNameIvarTypeDic:cls] mutableCopy];
    NSDictionary *rTTSt = [self runtimeTypeToSqlTypeDic];
    [ivarNameIvarTypeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [ivarNameIvarTypeDic setValue:rTTSt[obj] forKey:key];
    }];
    return ivarNameIvarTypeDic;
}

/**
 获取模型里面所有的字段
 */
+ (NSArray <NSString *> *)getModelIvarNames: (Class)cls {
    return [[self getModelIvarNameIvarTypeDic:cls] allKeys];
}

/**
 runtime的字段类型到sql字段类型的映射表
 */
+ (NSDictionary *)runtimeTypeToSqlTypeDic {    
    return @{
             @"d": @"real", // double
             @"f": @"real", // float
             @"i": @"integer",  // int
             @"q": @"integer", // long
             @"Q": @"integer", // long long
             @"B": @"integer", // bool
             @"NSData": @"blob",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             @"NSString": @"text",
             @"NSMutableString": @"text"
             };
}




@end
