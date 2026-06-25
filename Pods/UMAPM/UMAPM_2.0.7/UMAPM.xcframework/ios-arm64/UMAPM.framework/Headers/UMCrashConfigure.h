//
//  UMCrashConfigure.h
//  UMCrash
//
//  Created by wangkai on 2020/9/3.
//  Copyright © 2020 wangkai. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NSString *_Nullable(^CallbackBlock)(void);
FOUNDATION_EXPORT NSString * _Nonnull const UMReportExceptionNameForCSharp;
@class UMAPMConfig,UMAPMCustomData;;

typedef NS_ENUM(NSInteger, UMCrashType)
{
    /* 崩溃 */
    UMCrashTypeException      = 0x01,
    
    /* 卡顿 */
    UMCrashTypeBlock          = 0x02,
    
    /* 自定义错误 */
    UMCrashTypeUserReported   = 0x03,
    
    /* 其他 */
    UMCrashTypeOther           = 0x04,
};
typedef NSString *_Nullable(^CrashCallBackBlock)(UMCrashType type);

typedef NSString * UMAPMPerfTypeName NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXTERN UMAPMPerfTypeName const _Nonnull UMAPMPerfTypeLaunch;

@interface UMCrashConfigure : NSObject
//获取sdk版本号
+ (NSString *_Nonnull)getVersion;

/**
 *  异常回调，随异常信息一起上报。return字符串不能大于256字节
 */
+ (void)setCrashCBBlock:(CallbackBlock _Nullable )cbBlock;
/**
 *  异常回调，随异常信息一起上报。不同于“setCrashCBBlock:”方法，回调中提供了异常类型，两个方法按需取一个实现即可。return字符串不能大于256字节。
 */
+ (void)setCrashCallBackBlock:(CrashCallBackBlock _Nullable )cbBlock;

/**
 *  设置自定义版本号和build版本号即子版本号 (需要在初始化appkey方法之前调用)
 */
+ (void)setAppVersion:( NSString * __nonnull )appVersion buildVersion:(NSString* __nullable)buildVersion;


/**
 *  设置APM的各个模块的开启/关闭配置(需要在初始化appkey方法之前调用)
 */
+(void)setAPMConfig:(UMAPMConfig*_Nonnull)config;

/**
 *  @brief 设置APM的网络模块针对iOS13及以下系统的单独开关，以避免在同时集成NSURLProtocol和APM的网络模块的本身冲突引起崩溃。
 *  如果需要调用，在初始化UAPM网络模块前调用。
 *
 *  @param enable 指定开关。YES：(捕获iOS13及以下特定网络请求，默认开启)。NO:不捕获iOS13及以下特定网络请求。
 *
 *  @note 问题原因：同时集成NSURLProtocol和APM的网络模块的场景，先初始化APM的网络模块，再初始化NSURLProtocol的registerClass，会导致崩溃在iOS13及以下版本会崩溃，目前可以确定为iOS系统API引起的问题，iOS14无此问题。（先初始化NSURLProtocol的registerClass，再初始化APM的网络模块，是不会出现问题的）
 *  兼容iOS13及以下的初始化代码如下：
 *  @example:
 *  //确保NSURLProtocol的初始化在UMAPM的上面
 *  [NSURLProtocol registerClass:[UMURLProtocol class]];
 *  UMAPMConfig* config = [UMAPMConfig defaultConfig];
 *  config.networkEnable = YES;
 *  [UMCrashConfigure setAPMConfig:config];
 *  [UMConfigure initWithAppkey:UMAPPKEY channel:@"App Store"];
 *
 *  @note
 *  此开关默认打开，在同时集成NSURLProtocol和APM的网络模块的场景时候，根据需要调用，如果按照上述初始化顺序，不需要调用。
 *  
 *  @note 此函数关闭生效后，不会完全关闭网络模块，只是针对特定网络请求不再捕获，如果开发者能知道同时集成NSURLProtocol和APM的网络模块的场景的时候，最好通过调整初始化顺利来兼容所有场景，并在iOS13及以下版本测试兼容性。
 *  @note:其他场景下，不需要调用此函数。
 */
+(void)enableNetworkForProtocol:(BOOL)enable;

/**
 *  上报自定义错误
 *  用户可以用SDK预定义的字符串UMReportExceptionNameForCSharp来传递csharp类型的自定义异常
 *  @name  名称   长度限制256字符以内，超过截断。
 *  @reason  错误原因 长度限制256字符以内，超过截断。
 *  @stackTrace  堆栈 长度累计限制5000字符以内，超过部分的数组项会丢弃。
 *
 *  @example:
 *  // 日志类型唯一标识
 NSString* name = @"csharp";
 NSString* reason = @"csharp exception";

 NSArray* stackTrace = [NSArray arrayWithObjects:
                        @"msg: Exception: Exception, Attempted to divide by zero.",
                        @"UnityDemo+ExceptionProbe.NormalException () (at <unknown>:0)",
                        @"UnityDemo.TrigException (System.Int32 selGridInt) (at <unknown>:0)",
                        @"UnityDemo.OnGUI () (at <unknown>:0)",
                        nil];
 *
 *[UMCrashConfigure reportExceptionWithName:name reason:reason stackTrace:stackTrace];
 *
 *
 */
+(void)reportExceptionWithName:(NSString* _Nonnull)name
                        reason:(NSString* _Nonnull)reason
                    stackTrace:(NSArray* _Nonnull)stackTrace;

/**
 *  增加自定义信息
 *  设置此接口后，当发生崩溃、卡顿、自定义错误时会携带相应信息。如用户ID、直播房间号。注：一个生命周期最多支持设置10对
 *  @key  NSString 键。
 *  @value  NSString 值。
 *
 */
+ (void)addCustomInfoKey:(NSString *_Nonnull)key value:(NSString *_Nonnull)value;

/**
 * 添加自定义维度，SDK初始化前调用无效
 * @param data 需要更新的自定义维度
 */
+ (void)updateCustomData:(UMAPMCustomData *_Nonnull)data;

/**
 * 获取当前自定标维度信息，若未设置，返回空
 * @return 已设置的自定义维度
 */
+ (nullable UMAPMCustomData *)currentCustomData;

/**
 * 性能日志回调 目前仅支持启动（UMAPMPerfTypeLaunch）
 */
+ (void)setPerfCallBackBlock:(void(^_Nullable)(UMAPMPerfTypeName _Nonnull type))cbBlock;

/**
 *  设置网络分析Response，用于补齐网络分析中的Response
 * */
+ (void)setResponse:(NSString *_Nonnull)responseStr forTaskDesc:(NSString *_Nonnull)taskDesc;

/**
 *  网络分析环境状态
 *  Yes：环境可用 NO：环境不可用
 *
 */
+ (BOOL)networkMonitorStatus;

/**
 * 控制写入日志回捞写入频率，使用前请联系开发者，自行修改可能产生未知问题
 *
 */
+ (void)setLogCollectSaveSize:(long) size;

+ (void)setLogCollectInitImmediately:(BOOL) initImmediately;

@end

