//
//  PCMessageNotificationView.h
//  Pica
//
//  Created by Fancy on 2021/6/18.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCMessageNotificationView : UIView

+ (PCMessageNotificationView *)showWithMessage:(NSString *)message
                                      animated:(BOOL)animated;
 
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated
          afterDelay:(NSTimeInterval)delay;

@end

@interface PCMessageNotificationView (PCMessageNotificationTool)

+ (BOOL)hideAllNotificationInView:(UIView * _Nullable)view animated:(BOOL)animated;

+ (nullable PCMessageNotificationView *)notificationInView:(UIView *)view;

+ (nullable NSArray <PCMessageNotificationView *> *)allNotificationInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
