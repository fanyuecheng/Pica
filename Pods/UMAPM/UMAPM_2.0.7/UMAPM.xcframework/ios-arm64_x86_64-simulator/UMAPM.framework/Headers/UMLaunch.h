//
//  UMLaunch.h
//  WPKCore
//
//  Created by zhangjunhua on 2021/4/20.
//  Copyright © 2021 uc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//冷启动的预定义类型
typedef NS_ENUM(NSInteger,UMPredefineLaunchType){
    UMPredefineLaunchType_DidFinishLaunchingEnd,//在didFinishLaunchingWithOptions的最后一句设置
    UMPredefineLaunchType_ViewDidLoadEnd,//在第一个ViewController的viewDidLoad函数的最后调用
    UMPredefineLaunchType_ViewDidAppearEnd//在第一个ViewController的viewDidAppear函数的最后调用
};

@interface UMLaunch : NSObject

+(instancetype)shareInstance;

+(void)setRootVCCls:(Class)cls;//在DidFinishLaunching第一句代码提前设置RootViewController

/*
 *  手动设置三个预定义时间结束时间(初始化耗时结束，应用构建耗时结束,页面加载耗时结束)
 */
+(void)setPredefineLaunchType:(UMPredefineLaunchType)predefineLaunchType;


/*
 *  用户在冷启动阶段设置自己的自定义阶段
 *  @note beginLaunch和endLaunch必须要配对调用
 *  如果调用时间段，不在页面加载耗时结束前调用，是不会上报的
 */
+ (void)beginLaunch:(NSString *)methodName;
+ (void)endLaunch:(NSString *)methodName;


/*
 *  开启关闭启动模块采集
 */
+(void)setLaunchEnable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
