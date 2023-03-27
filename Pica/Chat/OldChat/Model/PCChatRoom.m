//
//  PCChatRoom.m 
//  Pica
//
//  Created by Fancy on 2021/6/11.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatRoom.h"

@implementation PCChatRoom

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"desc" : @"description"};
}

- (NSString *)socketUrl {
    if (self.url) {
        if ([self.url hasPrefix:@"https"]) {
            return [NSString stringWithFormat:@"%@/socket.io/?EIO=3&transport=websocket", [self.url stringByReplacingOccurrencesOfString:@"https" withString:@"wss"]];
        } else if ([self.url hasPrefix:@"http"]) {
            return [NSString stringWithFormat:@"%@/socket.io/?EIO=3&transport=websocket", [self.url stringByReplacingOccurrencesOfString:@"http" withString:@"ws"]];
        } else {
            return self.url;
        }
    } else {
        return nil;
    }
}
//42["broadcast_message",{"at":"","audio":"","avatar":"https://storage.wikawika.xyz/static/e514b0fc-c0cb-4b3d-b573-16dfe56bb4ae.jpg","block_user_id":"","character":"https://pica-pica.wikawika.xyz/special/frame-155.png?g=4?g=2","gender":"f","image":"","level":4,"message":"楼上露点","name":"小潜艇◈","platform":"android","reply":"👋","reply_name":"异世界的女仆Vitual Intelligence","title":"会喷水的小潜艇","type":3,"unique_id":"","user_id":"5fc60e2dd0b16c6a07cd357c","verified":false}]

@end
