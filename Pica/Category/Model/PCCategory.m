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
    return category;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"categoryId" : @"_id",
             @"desc" : @"description"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    BOOL isWeb = [dic[@"isWeb"] boolValue];
    
    return !isWeb;
}

@end
