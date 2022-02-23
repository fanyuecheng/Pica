//
//  PCCategory.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategory.h"
#import "PCIconHeader.h"
#import "PCComicListController.h"

@implementation PCCategory

+ (PCCategory *)rankCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"哔咔排行榜";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicRankController";
    category.desc = ICON_RANK;
    return category;
}

+ (PCCategory *)randomCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"随机本子";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicListController";
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

+ (PCCategory *)recommendCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"本子推荐";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"PCComicListController";
    category.desc = ICON_GOOD;
    category.categoryId = [@(PCComicListTypeRecommend) stringValue];
    return category;
}

+ (PCCategory *)nsfwCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"NSFW";
    category.active = YES;
    category.isCustom = YES;
    category.controllerClass = @"NSFWViewController";
    
    CGFloat width = floorf((SCREEN_WIDTH - 40) / 3);
    UIView *customThumb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    customThumb.backgroundColor = UIColorWhite;
    QMUILabel *label = [[QMUILabel alloc] initWithFrame:CGRectMake(0, 0, 38, 34)];
    label.layer.borderWidth = 2.5;
    label.layer.borderColor = PCColorPink.CGColor;
    label.layer.cornerRadius = 4;
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = [[NSAttributedString alloc] initWithString:@"R18" attributes:@{NSFontAttributeName : UIFontBoldMake(18), NSForegroundColorAttributeName : PCColorPink}];
    label.center = customThumb.center;
    [customThumb addSubview:label];
    category.customThumb = [UIImage qmui_imageWithView:customThumb];
    return category;
}

+ (PCCategory *)sanctuaryCategory {
    PCCategory *category = [[PCCategory alloc] init];
    category.title = @"iOS庇护所";
    category.active = YES;
    category.isWeb = YES;
    category.link = @"https://ios.bb10.xyz/";
    category.desc = ICON_IOS;
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
