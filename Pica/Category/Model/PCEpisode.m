//
//  PCEpisode.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCEpisode.h"

@implementation PCEpisode

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"episodeId" : @[@"_id", @"id"]};
}

@end

@implementation PCComicsEpisode

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"docs" : @"PCEpisode"};
}

@end
