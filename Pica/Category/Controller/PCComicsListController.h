//
//  PCComicsListController.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCComicsListType) {
    PCComicsListTypeRandom,
    PCComicsListTypeSearch,
    PCComicsListTypeHistory,
    PCComicsListTypeCategory,
    PCComicsListTypeFavourite,
    PCComicsListTypeTag,
    PCComicsListTypeTranslate,
    PCComicsListTypeCreator,
    PCComicsListTypeAuthor 
};

@interface PCComicsListController : PCTableViewController

@property (nonatomic, assign, readonly) PCComicsListType type;
@property (nonatomic, copy) NSString *keyword;
 
- (instancetype)initWithType:(PCComicsListType)type;


@end

NS_ASSUME_NONNULL_END
