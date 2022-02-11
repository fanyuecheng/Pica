//
//  UIViewController+PCAdd.m
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "UIViewController+PCAdd.h"

@implementation UIViewController (PCAdd)

+ (QMUIAlertController *)pc_actionSheetWithTitle:(nullable NSString *)title
                                         message:(nullable NSString *)message
                                    confirmTitle:(nullable NSString *)confirmTitle
                                         confirm:(nullable void (^)(void))confirm
                                     cancelTitle:(nullable NSString *)cancelTitle
                                          cancel:(nullable void (^)(void))cancel {
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:title message:message preferredStyle:QMUIAlertControllerStyleActionSheet];
    
    QMUIAlertAction *confirmAction = [QMUIAlertAction actionWithTitle:confirmTitle style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        !confirm ? : confirm();
    }];
    QMUIAlertAction *cancelAction = [QMUIAlertAction actionWithTitle:cancelTitle style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        !cancel ? : cancel();
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [alertController showWithAnimated:YES];
    
    return alertController;
}

+ (QMUIAlertController *)pc_alertWithTitle:(nullable NSString *)title
                                   message:(nullable NSString *)message
                              confirmTitle:(nullable NSString *)confirmTitle
                                   confirm:(nullable void (^)(void))confirm
                               cancelTitle:(nullable NSString *)cancelTitle
                                    cancel:(nullable void (^)(void))cancel {
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:title message:message preferredStyle:QMUIAlertControllerStyleAlert];
    
    QMUIAlertAction *confirmAction = [QMUIAlertAction actionWithTitle:confirmTitle style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        !confirm ? : confirm();
    }];
    QMUIAlertAction *cancelAction = [QMUIAlertAction actionWithTitle:cancelTitle style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        !cancel ? : cancel();
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [alertController showWithAnimated:YES];
    
    return alertController;
}
 
+ (QMUIAlertController *)pc_actionSheetWithTitle:(NSString *)title
                                         message:(NSString *)message
                                         confirm:(void (^)(void))confirm
                                          cancel:(void (^)(void))cancel {
    return [UIViewController pc_actionSheetWithTitle:title message:message confirmTitle:@"确定" confirm:confirm cancelTitle:@"取消" cancel:cancel];
}

+ (QMUIAlertController *)pc_alertWithTitle:(NSString *)title
                                   message:(NSString *)message
                                   confirm:(void (^)(void))confirm
                                    cancel:(void (^)(void))cancel {
    return [UIViewController pc_alertWithTitle:title message:message confirmTitle:@"确定" confirm:confirm cancelTitle:@"取消" cancel:cancel];
}

@end
