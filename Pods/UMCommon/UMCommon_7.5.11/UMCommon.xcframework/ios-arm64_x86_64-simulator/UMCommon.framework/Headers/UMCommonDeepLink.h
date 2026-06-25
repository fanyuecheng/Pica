//
//  UMCommonDeepLink.h
//  UMMobClick
//
//  Created by yanke on 2026/5/18.
//  Copyright © 2026 UMeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// In app event names constants
#define UMEventUserRegister            @"um_onUMengUserRegister"
#define UMEventInAppConvert            @"um_onUMengInAppConvert"
#define UMEventOrderRefund             @"um_onUMengOrderRefund"
#define UMEventAdRevenueEvent          @"um_onUMengAdRevenueEvent"


// In app event parameter names
#define UMEventParamRegisterMethod                 @"register_method"
#define UMEventParamRegisterTime                   @"register_time"
#define UMEventParamInviteCode                     @"invite_code"
#define UMEventParamOrderId                        @"order_id"
#define UMEventParamTransactionType                @"transaction_type"
#define UMEventParamProductId                      @"product_id"
#define UMEventParamProductType                    @"product_type"
#define UMEventParamProductName                    @"product_name"
#define UMEventParamProductPrice                   @"product_price"
#define UMEventParamTime                           @"time"
#define UMEventParamPaymentMethod                  @"payment_method"
#define UMEventParamIsFirstPurchase                @"is_first_purchase"
#define UMEventParamDiscountAmount                 @"discount_amount"
#define UMEventParamCouponId                       @"coupon_id"
#define UMEventParamCurrency                       @"currency"
#define UMEventParamRefundAmount                   @"refund_amount"
#define UMEventParamAdActionType                   @"ad_action_type"
#define UMEventParamAdPosition                     @"ad_position"
#define UMEventParamAdId                           @"ad_id"
#define UMEventParamAdFormat                       @"ad_format"
#define UMEventParamAdNetwork                      @"ad_network"
#define UMEventParamPrice                          @"price"
#define UMEventParamAdDuration                     @"ad_duration"



@protocol UMCommonDeepLinkDelegate<NSObject>

@optional

- (void)didResolveDeepLink:(NSDictionary *)params;

@end

@interface UMCommonDeepLink : NSObject

@property(weak, nonatomic) id<UMCommonDeepLinkDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)getInstallParams:(void (^)(NSDictionary * _Nullable params, NSError * _Nullable error))completion;

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity;

- (BOOL)handleOpenURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
