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
 
static NSMutableArray <NSString *> *PCCharacterImageArray = nil;

@implementation PCUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @[@"_id", @"id"],
             @"desc" : @"description"};
}

+ (PCUser *)localUser {
    return [PCUser yy_modelWithJSON:[kPCUserDefaults objectForKey:PC_LOCAL_USER]];
}

+ (NSArray *)characterImageArray {
    //host
    //https://www.picacomic.com or https://pica-pica.wikawika.xyz
    if (!PCCharacterImageArray) {
        PCCharacterImageArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 1; i < 636; i++) {
            [PCCharacterImageArray addObject:[NSString stringWithFormat:@"https://bidobido.xyz/special/frame-%@.png", @(i)]];
        }
    }
    return [PCCharacterImageArray copy];
}

+ (NSString *)localCharacterImage {
    BOOL on = [kPCUserDefaults integerForKey:PC_CHAT_AVATAR_CHARACTER_ON];
    NSString *index = [kPCUserDefaults objectForKey:PC_CHAT_AVATAR_CHARACTER];
    
    if (on) {
        if ([index isEqualToString:@"随机"]) {
            return [PCUser characterImageArray][arc4random() % [PCUser characterImageArray].count];
        }
        return [PCUser characterImageArray][[index integerValue]];
    } else {
        return [PCUser localUser].character;
    }
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
