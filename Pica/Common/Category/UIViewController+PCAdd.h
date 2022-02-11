//
//  UIViewController+PCAdd.h
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIAlertController.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PCAdd)

+ (QMUIAlertController *)pc_alertWithTitle:(nullable NSString *)title
                                   message:(nullable NSString *)message
                                   confirm:(nullable void (^)(void))confirm
                                    cancel:(nullable void (^)(void))cancel;

+ (QMUIAlertController *)pc_actionSheetWithTitle:(nullable NSString *)title
                                         message:(nullable NSString *)message
                                         confirm:(nullable void (^)(void))confirm
                                          cancel:(nullable void (^)(void))cancel;
+ (QMUIAlertController *)pc_actionSheetWithTitle:(nullable NSString *)title
                                         message:(nullable NSString *)message
                                    confirmTitle:(nullable NSString *)confirmTitle
                                         confirm:(nullable void (^)(void))confirm
                                     cancelTitle:(nullable NSString *)cancelTitle
                                          cancel:(nullable void (^)(void))cancel;

+ (QMUIAlertController *)pc_alertWithTitle:(nullable NSString *)title
                                   message:(nullable NSString *)message
                              confirmTitle:(nullable NSString *)confirmTitle
                                   confirm:(nullable void (^)(void))confirm
                               cancelTitle:(nullable NSString *)cancelTitle
                                    cancel:(nullable void (^)(void))cancel;

@end

NS_ASSUME_NONNULL_END
