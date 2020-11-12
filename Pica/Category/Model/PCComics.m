//
//  PCComics.m
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComics.h"

@implementation PCComics

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"comicsId" : @[@"_id", @"id"],
             @"desc" : @"description",
             @"creator" : @"_creator"};
}

@end

@implementation PCComicsList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"docs" : @"PCComics"};
}

@end

