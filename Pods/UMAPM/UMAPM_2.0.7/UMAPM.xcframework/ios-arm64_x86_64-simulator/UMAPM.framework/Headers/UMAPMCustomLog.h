//
//  UMAPMCustomLog.h
//  UMCrash
//
//  Created by 彦克 on 2024/6/5.
//  Copyright © 2024 wangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMAPMCustomLog : NSObject

+ (void)vTag:(NSString *)tag msg:(NSString *)msg;
+ (void)dTag:(NSString *)tag msg:(NSString *)msg;
+ (void)iTag:(NSString *)tag msg:(NSString *)msg;
+ (void)wTag:(NSString *)tag msg:(NSString *)msg;
+ (void)eTag:(NSString *)tag msg:(NSString *)msg;

/// 设置写入日志的缓存大小，日志将根据设置的缓存大小循环写入
/// - Parameter size: 最大缓存条数
+ (void)setMaxCount:(NSInteger)size;
@end

NS_ASSUME_NONNULL_END
