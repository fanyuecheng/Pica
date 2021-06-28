//
//  PCGame.m
//  Pica
//
//  Created by Fancy on 2021/6/25.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGame.h"

@implementation PCGame

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"gameId" : @"_id", @"desc" : @"description"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"screenshots" : @"PCThumb"};
}

@end

@implementation PCGameList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"docs" : @"PCGame"};
}

@end

