//
//  PCCategory.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategory.h"

@implementation PCCategory

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"categoryId" : @"_id",
             @"desc" : @"description"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    BOOL isWeb = dic[@"isWeb"];
    
    return !isWeb;
}

@end
