//
//  UMZid.h
//  UMZid
//
//  Created by UMZid on 8/29/20.
//  Copyright © 2020 UMZid. All rights reserved.
// v3.6.0

#import <Foundation/Foundation.h>

@interface UMZid : NSObject

/// SDK初始化，异步请求uToken
/// @param appkey     appkey
/// @param completion 请求uToken的回调，uToken为返回值，如果失败，uToken为空字符串@“”
+ (void)initWithAppKey:(NSString *)appkey completion:(void (^)(NSString *uToken))completion;

/// 同步获得uToken，失败返回空字符串@“”
+ (NSString *)getZID;

/// 获取SDK版本号
+ (NSString *)getSDKVersion;

/// 获得resetToken
+ (NSString *)getResetToken;

/// 获得at
+ (NSString *)getATStr;

/// 配置自定义域名（需在初始化之前设置,本地会缓存）
/// @param domain 域名字符串 如：https://www.xxxxxx.com
+ (void)configureDomain:(NSString *)domain;
@end
