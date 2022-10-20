//
//  UMAPMConfig.h
//  UMAPM
//
//  Created by zhangjunhua on 2021/6/21.
//  Copyright © 2021 wangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMAPMConfig : NSObject<NSCopying>



+(UMAPMConfig*)defaultConfig;

/**
 *  crash&卡顿监控开关，默认开启
 */
@property (nonatomic,assign) BOOL crashAndBlockMonitorEnable;


/**
 *  启动模块监控开关，默认开启
 */
@property (nonatomic,assign) BOOL launchMonitorEnable;


/**
 *  内存模块监控开关，默认开启
 */
@property (nonatomic,assign) BOOL memMonitorEnable;


/**
 *  OOM模块监控开关，默认开启
 */
@property (nonatomic,assign) BOOL oomMonitorEnable;


/**
 *  网络模块监控开关，默认开启
 */
@property (nonatomic,assign) BOOL networkEnable;

/**
 *  H5打通模块开关，默认开启
 */
@property (nonatomic,assign) BOOL javaScriptBridgeEnable;


/**
 *  页面分析打通模块开关，默认开启
 */
@property (nonatomic,assign) BOOL pageMonitorEnable;

/**
 *集成测试。
 */
+ (BOOL)handleUrl:(NSURL *)url;


/*
 *  卡顿监控参数
 *  发送检测心跳的时间间隔。单位：秒。
 *  区间范围[1,4],超过就用默认值2
 */
@property (nonatomic, assign) float sendBeatInterval;

/*
 *  卡顿监控参数
 *  检测卡顿的时间间隔 单位是秒。 （发送心跳后checkBeatInterval秒进行检测）
 *  区间范围[1,4],超过就用默认值2
 */
@property (nonatomic, assign) float checkBeatInterval;
 

/*
 *  卡顿监控参数
 *  连续多少次没心跳 认为触发卡顿
 *  区间范围[1,4],超过就用默认值3，注意此参数必须为整数
 */
@property (nonatomic, assign) NSInteger toleranceBeatMissingCount;


@end

NS_ASSUME_NONNULL_END
