//
//  PCComicListController.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCComicListType) {
    PCComicListTypeRandom,
    PCComicListTypeSearch,
    PCComicListTypeHistory,
    PCComicListTypeCategory,
    PCComicListTypeFavourite,
    PCComicListTypeTag,
    PCComicListTypeTranslate,
    PCComicListTypeCreator,
    PCComicListTypeAuthor 
};

@interface PCComicListController : PCTableViewController

@property (nonatomic, assign, readonly) PCComicListType type;
@property (nonatomic, copy) NSString *keyword;
 
- (instancetype)initWithType:(PCComicListType)type;


@end

NS_ASSUME_NONNULL_END
