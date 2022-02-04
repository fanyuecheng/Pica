//
//  PCComic.m
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComic.h"

@implementation PCComic

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"comicId" : @[@"_id", @"id"],
             @"desc" : @"description",
             @"creator" : @"_creator"};
}

@end

@implementation PCComicList

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"docs" : @[@"docs", @"comics"]};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"docs" : @"PCComic"};
}

@end

