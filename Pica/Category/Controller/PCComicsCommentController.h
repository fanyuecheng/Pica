//
//  PCComicsCommentController.h
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define PC_COMMENT_BOARD_ID @"5822a6e3ad7ede654696e482"

typedef NS_ENUM(NSUInteger, PCComicsCommentType) {
    PCComicsCommentTypeMain,
    PCComicsCommentTypeChild
};

@interface PCComicsCommentController : PCTableViewController

@property (nonatomic, assign, readonly) PCComicsCommentType type;

- (instancetype)initWithComicsId:(NSString *)comicsId;
- (instancetype)initWithCommentId:(NSString *)commentId;

@end

NS_ASSUME_NONNULL_END
