//
//  PCLocalAuthentication.h
//  Pica
//
//  Created by Fancy on 2022/1/21.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCLocalAuthentication : NSObject

+ (instancetype)sharedInstance;

- (void)authenticationWithDescribe:(NSString *)desc
                        stateBlock:(void (^)(NSError *error))stateBlock;

- (void)showTouchIDWithDescribe:(NSString *)desc
                     stateBlock:(void (^)(NSError *error))stateBlock;

- (void)showFaceIDWithDescribe:(NSString *)desc
                    stateBlock:(void (^)(NSError *error))stateBlock;

@end

NS_ASSUME_NONNULL_END
