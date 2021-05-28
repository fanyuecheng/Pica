//
//  PCRankListController.h
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCRankListType) {
    PCRankListTypeH24,
    PCRankListTypeD7,
    PCRankListTypeD30,
    PCRankListTypeKnight
};

@interface PCRankListController : PCTableViewController

- (instancetype)initWithType:(PCRankListType)type;

- (void)requestData;

@end

NS_ASSUME_NONNULL_END
