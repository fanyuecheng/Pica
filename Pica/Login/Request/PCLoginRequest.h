//
//  PCLoginRequest.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCLoginRequest : PCRequest

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;

- (instancetype)initWithAccount:(NSString *)account
                       password:(NSString *)password;
@end

NS_ASSUME_NONNULL_END
