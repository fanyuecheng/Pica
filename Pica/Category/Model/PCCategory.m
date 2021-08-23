//
//  PCCategory.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategory.h"
#import "PCIconHeader.h"

@implementation PCCategory

+ (PCCategory *)rankCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"哔咔排行榜";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicsRankController";
    category.desc = ICON_RANK;
    return category;
}

+ (PCCategory *)randomCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"随机本子";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicsListController";
    category.desc = ICON_PICTURE;
    return category;
}

+ (PCCategory *)commentCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"哔咔留言板";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCCommentController";
    category.desc = ICON_COMMENT;
    return category;
}

+ (PCCategory *)aiCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"嗶咔AI推薦";
    category.active = YES;
    category.isWeb = NO;
    PCThumb *thumb = [[PCThumb alloc] init];
    thumb.originalName = @"ai.jpg";
    thumb.path = @"ai.jpg";
    thumb.fileServer = @"https://wikawika.xyz/static/";
    category.thumb = thumb;
    return category;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"categoryId" : @"_id",
             @"desc" : @"description"};
}

@end
