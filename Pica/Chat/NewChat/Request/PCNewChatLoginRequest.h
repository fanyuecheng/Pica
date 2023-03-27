//
//  PCNewChatLoginRequest.h
//  Pica
//
//  Created by 米画师 on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatLoginRequest : PCNewChatBaseRequest

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

- (instancetype)initWithAccount:(NSString *)account
                       password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
