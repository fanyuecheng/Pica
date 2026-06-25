//
//  UAPMLog.h
//  WPKCore
//
//  Created by baxiong on 2024/7/2.
//  Copyright © 2024 uc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UAPMLog : NSObject

+ (void)verbose:(NSString *)tag msg:(NSString *)msg;

+ (void)debug:(NSString *)tag msg:(NSString *)msg;

+ (void)info:(NSString *)tag msg:(NSString *)msg;

+ (void)warn:(NSString *)tag msg:(NSString *)msg;

+ (void)error:(NSString *)tag msg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
