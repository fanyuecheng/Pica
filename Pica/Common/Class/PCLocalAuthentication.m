//
//  PCLocalAuthentication.m
//  Pica
//
//  Created by Fancy on 2022/1/21.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCLocalAuthentication.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface PCLocalAuthentication ()

@property (nonatomic, strong) LAContext *context;

@end

@implementation PCLocalAuthentication

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PCLocalAuthentication *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)authenticationWithDescribe:(NSString *)desc
                        stateBlock:(void (^)(NSError *error))stateBlock {
    BOOL faceIDEnabled = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil];
    if (faceIDEnabled) {
        [self showFaceIDWithDescribe:desc
                          stateBlock:stateBlock];
    } else {
        [self showTouchIDWithDescribe:desc
                           stateBlock:stateBlock];
    }
}

- (void)showTouchIDWithDescribe:(NSString *)desc
                     stateBlock:(void (^)(NSError *error))stateBlock {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            stateBlock([NSError errorWithDomain:@"LAErrorAuthenticationNotSuppot" code:999 userInfo:nil]);
        });
        return;
    }
     
    self.context.localizedFallbackTitle = desc;
    NSError *error = nil;
        
    if ([self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:desc == nil ? @"通过Home键验证已有指纹" : desc
                          reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    stateBlock(nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    stateBlock(error);
                });
            }
        }];
    } else {
        [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                     localizedReason:@"用来验证指纹"
                               reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    stateBlock(nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    stateBlock(error);
                });
            }
        }];
    }
}

- (void)showFaceIDWithDescribe:(NSString *)desc stateBlock:(void (^)(NSError *error))stateBlock {
    NSError *error;
    BOOL canAuthentication = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
    if (canAuthentication) {
        [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                     localizedReason:desc
                               reply:^(BOOL success, NSError * _Nullable error) {
            //注意iOS 11.3之后需要配置Info.plist权限才可以通过Face ID验证 不然只能输密码
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    stateBlock(nil);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    stateBlock(error);
                });
            }
        }];
    }
}

- (LAContext *)context {
    if (!_context) {
        _context = [[LAContext alloc] init];
    }
    return _context;
}


@end
