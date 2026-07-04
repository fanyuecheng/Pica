//
//  UMAPMCustomData.h
//  UMCrash
//
//  Created by yanke on 2024/10/10.
//  Copyright © 2024 wangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * UMAPMCustomStringDataKey NS_STRING_ENUM;

FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey1;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey2;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey3;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey4;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey5;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey6;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey7;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey8;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey9;
FOUNDATION_EXPORT UMAPMCustomStringDataKey const UMAPMCustomStringDataKey10;

// 字符串不能超过100个字符
FOUNDATION_EXPORT int const UMAPM_CUSTOM_DATA_MAX_STRING_VALUE_LENGTH;

@interface UMAPMCustomData : NSObject

- (NSDictionary *)customDataDictInfo;


/**
  * 获取设置的自定义维度数据
  * @param key 如果KEY不在预设的中，返回nil
  * @return 如果有设置，则返回当前值，如果没有设置，返回nil
  */
- (nullable NSString *)getStringParam:(UMAPMCustomStringDataKey)key;

/**
 * 设置自定义维度数据
 * @param key 如果KEY不在预设的中，则设置失败
 * @param param 长度不能超过 UMAPM_CUSTOM_DATA_MAX_STRING_VALUE_LENGTH
 *     value = null, 则会设置空串
 *     value = 长度超标字符串，则会截取前UMAPM_CUSTOM_DATA_MAX_STRING_VALUE_LENGTH个字符设置
 */
- (BOOL)putStringParam:(nullable NSString *)param forKey:(UMAPMCustomStringDataKey)key;

@end

NS_ASSUME_NONNULL_END
