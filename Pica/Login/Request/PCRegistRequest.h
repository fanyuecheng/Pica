//
//  PCRegistRequest.h
//  Pica
//
//  Created by 米画师 on 2021/2/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCRegistRequest : PCRequest

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *gender; // m, f, bot
@property (nonatomic, copy) NSString *answer1;
@property (nonatomic, copy) NSString *answer2;
@property (nonatomic, copy) NSString *answer3;
@property (nonatomic, copy) NSString *question1;
@property (nonatomic, copy) NSString *question2;
@property (nonatomic, copy) NSString *question3;


@end

NS_ASSUME_NONNULL_END
