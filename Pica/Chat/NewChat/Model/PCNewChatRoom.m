//
//  PCNewChatRoom.m
//  Pica
//
//  Created by 米画师 on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatRoom.h"

@implementation PCNewChatRoom

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"desc" : @"description", @"roomId" : @"id"};
}

@end
