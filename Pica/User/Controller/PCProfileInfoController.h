//
//  PCProfileInfoController.h
//  Pica
//
//  Created by YueCheng on 2021/5/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, PCProfileInfoType) {
    PCProfileInfoTypeComic,
    PCProfileInfoTypeComment
};

@protocol JXPagerViewListViewDelegate;

@interface PCProfileInfoController : PCTableViewController <JXPagerViewListViewDelegate>

- (instancetype)initWithType:(PCProfileInfoType)type;

@end

NS_ASSUME_NONNULL_END
