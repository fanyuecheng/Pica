//
//  PCUser.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCUser.h"
#import "PCProfileRequest.h"
#import <YYModel/YYModel.h>
 
@implementation PCUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @[@"_id", @"id"],
             @"desc" : @"description"};
}

+ (PCUser *)localUser {
    return [PCUser yy_modelWithJSON:[[NSUserDefaults standardUserDefaults] objectForKey:PC_LOCAL_USER]];
}

+ (void)requsetMyself:(void (^)(PCUser *user, NSError *error))finished {
    PCProfileRequest *profileRequest = [[PCProfileRequest alloc] init];
    [profileRequest sendRequest:^(PCUser *user) { 
        !finished ? : finished(user, nil);
    } failure:^(NSError * _Nonnull error) {
        !finished ? : finished(nil, error);
    }];
}

@end
