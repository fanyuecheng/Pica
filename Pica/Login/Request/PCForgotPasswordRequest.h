//
//  PCForgotPasswordRequest.h
//  Pica
//
//  Created by Fancy on 2021/8/3.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN
// error 不可用
@interface PCForgotPasswordRequest : PCRequest

@property (nonatomic, copy) NSString *email;

@end

NS_ASSUME_NONNULL_END
