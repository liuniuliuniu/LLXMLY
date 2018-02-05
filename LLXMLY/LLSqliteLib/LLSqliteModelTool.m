//
//  LLSqliteModelTool.m
//  LLXMLY
//
//  Created by liushaohua on 2017/7/3.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLSqliteModelTool.h"
#import "LLSqliteTool.h"
#import "LLModelTool.h"
#import "LLTableTool.h"

@implementation LLSqliteModelTool


#pragma mark - 创建表格
/**
 根据模型, 创建/更新表格(保证相关数据内容存在)
 @param cls 模型
 @param uid 用户ID
 @return 是否创建/更新成功
 */
+ (BOOL)createTableWithModelClass: (Class)cls withUID: (NSString *)uid {
    // 1. 判断 表是否存在
    NSString *tableName = [LLModelTool getTableNameWithModelClass:cls];
    BOOL isTableExists = [LLTableTool isTableExists:tableName uid:uid];
    if (isTableExists && ![self isRequireUpdate:cls uid:uid]) {
        NSLog(@"表格存在, 并且不需要更新");
        return YES;
    }
    if (![cls instancesRespondToSelector:@selector(primaryKey)]) {
        NSLog(@"如果想要操作你这个模型, 必须要通过 - (NSString *)primaryKey; 方法, 来提供一个主键给我");
        return NO;
    }
    // 通过运行时, 获取, 模型,里面所有的成员变量 & 类型
    NSDictionary *ivarNameTypeDic = [LLModelTool getModelIvarNameSqlTypeDic:cls];
    // 获取主键
    NSString *primaryKey = [[cls new] primaryKey];
    NSMutableArray *ivarNameTypeStrArray = [NSMutableArray array];
    [ivarNameTypeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [ivarNameTypeStrArray addObject:[NSString stringWithFormat:@"%@ %@", key, obj]];
    }];
    
    if (!isTableExists) {
        NSString *createTabelSQL = [NSString stringWithFormat:@"create table if not exists %@(%@,primary key(%@))", tableName, [ivarNameTypeStrArray componentsJoinedByString:@","], primaryKey];
        return [LLSqliteTool dealSql:createTabelSQL withUID:uid];
    }
    
    // 表需要更新
    NSString *tmpTableName = [LLModelTool getTempTableNameWithModelClass:cls];
    NSMutableArray *updateSqls = [NSMutableArray array];
    // 1. 创建一个另外临时的表格(new), 里面包含最新的表结构
    NSString *createNewTableSql = [NSString stringWithFormat:@"create table if not exists %@ (%@,primary key(%@));", tmpTableName, [ivarNameTypeStrArray componentsJoinedByString:@","], primaryKey];
    [updateSqls addObject:createNewTableSql];
    // 2. 以旧表, 里面的数据, 为参照, 逐个列, 导入数据到新表
    // 2.1 导入主键
    NSString *insertPrimaryKey = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",tmpTableName, primaryKey, primaryKey, tableName];
    [updateSqls addObject:insertPrimaryKey];
    // 2.2 遍历所有的列(排除主键), 需要更新到新表里面
    NSArray *columnNames = [LLTableTool getTableAllColumnNames:tableName uid:uid];
    NSArray *modelColumnNames = [LLModelTool getModelIvarNames:cls];
    
    
    NSDictionary *renameDic = [[cls new] renameDic];
    
    // 以新表所有字段为参照标准
    for (NSString *columnName in modelColumnNames) {
        
        NSString *oldColumnName = renameDic[columnName];
        if (oldColumnName.length == 0 || ![columnNames containsObject:oldColumnName]) {
            oldColumnName = columnName;
        }
        if ([columnNames containsObject:columnName] || [columnNames containsObject:oldColumnName]) {
            NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@); ", tmpTableName, columnName, oldColumnName, tableName, tmpTableName, primaryKey, tableName, primaryKey];
            [updateSqls addObject:updateSql];
        }
    }
    NSString *dropOldTable = [NSString stringWithFormat:@"drop table if exists %@;", tableName];
    [updateSqls addObject:dropOldTable];
    NSString *alterName = [NSString stringWithFormat:@"alter table %@ rename to %@; ", tmpTableName, tableName];
    [updateSqls addObject:alterName];
    return [LLSqliteTool dealSqls:updateSqls withUID:uid];
}

#pragma mark - 查询模型
+ (NSArray *)queryAllModels:(Class)cls uid: (NSString *)uid {
    
    NSString *tableName = [LLModelTool getTableNameWithModelClass:cls];
    NSString *sql = [NSString stringWithFormat:@"select * from %@", tableName];
    NSArray *rowDicArray = [LLSqliteTool querySql:sql withUID:uid];
    NSArray *resultM = [self parseRowDicArray:rowDicArray withModelClass:cls];
    return resultM;
}

+ (NSArray *)queryModels:(Class)cls key: (NSString *)key relation: (LLSqliteModelToolRelationType)relation value: (id)value uid: (NSString *)uid  {
    NSString *tableName = [LLModelTool getTableNameWithModelClass:cls];
    NSString *relationStr = [self relationTypeSQLRelation][@(relation)];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ %@ '%@'", tableName, key, relationStr, value];
    NSArray *rowDicArray = [LLSqliteTool querySql:sql withUID:uid];
    NSArray *resultM = [self parseRowDicArray:rowDicArray withModelClass:cls];
    return resultM;
}

+ (NSArray *)queryModels:(Class)cls keys: (NSArray *)keys relations: (NSArray *)relations values: (NSArray *)values nao: (NSArray *)naos uid: (NSString *)uid {
    
    NSMutableString *resultStr = [NSMutableString string];
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        NSString *relationStr = [self relationTypeSQLRelation][relations[i]];
        id value = values[i];
        NSString *tempStr = [NSString stringWithFormat:@"%@ %@ '%@'", key, relationStr, value];
        [resultStr appendString:tempStr];
        if (i != keys.count - 1) {
            NSString *naoStr = [self naoTypeSQLRelation][naos[i]];
            [resultStr appendString:[NSString stringWithFormat:@" %@ ", naoStr]];
        }
    }
    NSString *tableName = [LLModelTool getTableNameWithModelClass:cls];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@", tableName, resultStr];
    NSArray *rowDicArray = [LLSqliteTool querySql:sql withUID:uid];
    NSArray *resultM = [self parseRowDicArray:rowDicArray withModelClass:cls];
    return resultM;
}

+ (NSArray *)queryModels:(Class)cls sql: (NSString *)sql uid: (NSString *)uid {
    NSArray *array = [LLSqliteTool querySql:sql withUID:uid];
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        id model = [[cls alloc] init];
        [model setValuesForKeysWithDictionary:dic];
        [models addObject:model];
    }
    return models;
}

+ (BOOL)deleteModel: (id)model uid: (NSString *)uid {
    NSString *tableName = [LLModelTool getTableNameWithModelClass:[model class]];
    NSString *primaryKey = [model primaryKey];
    NSString *sql = [NSString stringWithFormat:@"delete  from %@ where  %@ = '%@'", tableName, primaryKey, [model valueForKeyPath:primaryKey]];
    return [LLSqliteTool dealSql:sql withUID:uid];
}

+ (BOOL)deleteModel:(Class)cls key: (NSString *)key relation: (LLSqliteModelToolRelationType)relation value: (id)value uid: (NSString *)uid {
    
    NSString *tableName = [LLModelTool getTableNameWithModelClass:cls];
    NSString *relationStr = [self relationTypeSQLRelation][@(relation)];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ %@ '%@'", tableName, key, relationStr, value];
    return  [LLSqliteTool dealSql:sql withUID:uid];
}

+ (BOOL)deleteModel:(Class)cls keys: (NSArray *)keys relations: (NSArray *)relations values: (NSArray *)values nao: (NSArray *)naos uid: (NSString *)uid {
    NSMutableString *resultStr = [NSMutableString string];
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        NSString *relationStr = [self relationTypeSQLRelation][relations[i]];
        id value = values[i];
        NSString *tempStr = [NSString stringWithFormat:@"%@ %@ '%@'", key, relationStr, value];
        [resultStr appendString:tempStr];
        if (i != keys.count - 1) {
            NSString *naoStr = [self naoTypeSQLRelation][naos[i]];
            [resultStr appendString:[NSString stringWithFormat:@" %@ ", naoStr]];
        }
    }
    NSString *tableName = [LLModelTool getTableNameWithModelClass:cls];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@", tableName, resultStr];
    return  [LLSqliteTool dealSql:sql withUID:uid];
}

+ (BOOL)deleteWithSql: (NSString *)sql uid: (NSString *)uid {
    return  [LLSqliteTool dealSql:sql withUID:uid];
}


+ (BOOL)saveModel: (id)model uid: (NSString *)uid {
    // 1. 检查表是否需要更新, 如果需要, 更新,
    // 表如果没有, 创建
    BOOL result = [self createTableWithModelClass:[model class] withUID:uid];
    if (!result) {
        NSLog(@"表格错误");
        return NO;
    }
    // 2. 判断, 当前表里面, 是否存在这条记录
    NSString *tableName = [LLModelTool getTableNameWithModelClass:[model class]];
    NSString *primaryKey = [model primaryKey];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableName, primaryKey, [model valueForKeyPath:primaryKey]];
    NSArray *res = [LLSqliteTool querySql:sql withUID:uid];
    // 字段
    NSArray *columnNames = [LLModelTool getModelIvarNames:[model class]];
    // 值
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *columnName in columnNames) {
        id value = [model valueForKeyPath:columnName];
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (value == nil) {
            value = @"";
        }
        [values addObject:value];
    }
    if (res.count > 0) {
        // 存在, ->更新
        NSMutableArray *tempResult = [NSMutableArray array];
        for(int i = 0; i < columnNames.count; i++) {
            NSString *columnName = columnNames[i];
            id value = values[i];
            NSString *str = [NSString stringWithFormat:@"%@ = '%@'", columnName, value];
            [tempResult addObject:str];
        }
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'", tableName, [tempResult componentsJoinedByString:@","], primaryKey, [model valueForKeyPath:primaryKey]];
        return [LLSqliteTool dealSql:sql withUID:uid];
    }else {
        // 不存在, 插入
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(%@) values ('%@')", tableName, [columnNames componentsJoinedByString:@","], [values componentsJoinedByString:@"','"]];
        return [LLSqliteTool dealSql:insertSql withUID:uid];
    }
}

#pragma mark - 私有方法
// 处理结果集
+ (NSArray *)parseRowDicArray: (NSArray *)rowDicArray withModelClass: (Class)cls {
    NSMutableArray *resultM = [NSMutableArray array];
    // 模型真正的字段 - > 类型
    NSDictionary *modelColumnNames = [LLModelTool getModelIvarNameIvarTypeDic:cls];
    for (NSDictionary *rowDic in rowDicArray) {
        id model = [[cls alloc] init];
        [resultM addObject:model];
        [modelColumnNames enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // key, 字段名称
            // obj, 类型
            id value = rowDic[key];
            if ([obj isEqualToString:@"NSArray"] || [obj isEqualToString:@"NSDictionary"]) {
                NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                // NSJSONReadingMutableContainers
                value = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            } else if ([obj isEqualToString:@"NSMutableArray"] || [obj isEqualToString:@"NSMutableDictionary"]) {
                NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            [model setValue:value forKeyPath:key];
        }];
    }
    return resultM;
}

/**
 判断表格是否需要更新
 // 字段个数不一致, 大小写不一致, 均判定为需要更新
 // 目的是为了跟模型的所有字段保持一致
 */
+ (BOOL)isRequireUpdate:(Class)cls uid: (NSString *)uid {
    // 需要更新的情况 删除字段, 增加字段, 改名
    // 1. 现获取, 所有的已经存在的表格内, 的字段, 组成的数组(old)
    NSArray *tableColumnNames = [LLTableTool getTableAllColumnNames:[LLModelTool getTableNameWithModelClass:cls] uid:uid];
    // 2. 获取模型, 应该被创建成为表结构的, 所有字段 (new)
    NSArray *modelColumnNames = [LLModelTool getModelIvarNames:cls];
    tableColumnNames = [tableColumnNames sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    modelColumnNames = [modelColumnNames sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    BOOL isUpdate = ![tableColumnNames isEqualToArray:modelColumnNames];
    if (isUpdate) {
        NSLog(@"需要更新");
    }else {
        NSLog(@"不需要更新");
    }
    return isUpdate;
}

/**
 枚举 -> sql 逻辑运算符 映射表
 */
+ (NSDictionary *)relationTypeSQLRelation {
    return @{
             @(LLSqliteModelToolRelationTypeEqual) : @"=",
             @(LLSqliteModelToolRelationTypeGreater) : @">",
             @(LLSqliteModelToolRelationTypeLess) : @"<",
             @(LLSqliteModelToolRelationTypeEG) : @">=",
             @(LLSqliteModelToolRelationTypeEL) : @"<=",
             @(LLSqliteModelToolRelationTypeNE) : @"!="
             };
}

/**
 枚举 -> sql 逻辑运算符 映射表
 */
+ (NSDictionary *)naoTypeSQLRelation {
    return @{
             @(LLSqliteModelToolNAONot) : @"not",
             @(LLSqliteModelToolNAOAnd) : @"and",
             @(LLSqliteModelToolNAOOr) : @"or"
             };    
}



@end
