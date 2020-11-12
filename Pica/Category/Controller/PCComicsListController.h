//
//  PCComicsListController.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsListController : PCTableViewController

- (instancetype)initWithCategory:(NSString *)category;
- (instancetype)initWithKeyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
