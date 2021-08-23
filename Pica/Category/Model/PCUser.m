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
    if (!PCCharacterImageArray) {
        PCCharacterImageArray = [[NSMutableArray alloc] init];
        [PCCharacterImageArray addObjectsFromArray:@[   @"https://pica-pica.wikawika.xyz/characters/frame_knight_1000.png", @"https://pica-pica.wikawika.xyz/characters/frame_knight_500_999.png", @"https://pica-pica.wikawika.xyz/characters/verified.png", @"https://pica-pica.wikawika.xyz/images/monster.jpg", @"https://pica-pica.wikawika.xyz/images/halloween_bot.png", @"https://pica-pica.wikawika.xyz/images/halloween_f.png", @"https://pica-pica.wikawika.xyz/images/halloween_m.png",
            @"https://pica-pica.wikawika.xyz/special/frame-dirty.png"]];
        for (NSInteger i = 1; i < 491; i++) {
            [PCCharacterImageArray addObject:[NSString stringWithFormat:@"https://pica-pica.wikawika.xyz/special/frame-%@.png", @(i)]];
        }
    }
    return [PCCharacterImageArray copy];
}

+ (NSString *)localCharacterImage {
    BOOL on = [kPCUserDefaults integerForKey:PC_CHAT_AVATAR_CHARACTER_ON];
    NSInteger index = [kPCUserDefaults integerForKey:PC_CHAT_AVATAR_CHARACTER];
    
    if (on) {
        if (index == -1) {
            index = arc4random() % [PCUser characterImageArray].count;
        }
        return [PCUser characterImageArray][index];
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
