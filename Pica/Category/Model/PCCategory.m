//
//  PCCategory.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategory.h"

@implementation PCCategory

+ (PCCategory *)rankCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"哔咔排行榜";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicsRankController";
    return category;
}

+ (PCCategory *)randomCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"随机本子";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicsListController";
    return category;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"categoryId" : @"_id",
             @"desc" : @"description"};
}

@end
