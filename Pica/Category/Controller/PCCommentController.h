//
//  PCCommentController.h
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewController.h"
#import "PCComment.h"

NS_ASSUME_NONNULL_BEGIN

#define PC_COMMENT_BOARD_ID @"5822a6e3ad7ede654696e482"

typedef NS_ENUM(NSUInteger, PCCommentPrimaryType) {
    PCCommentPrimaryTypeMain,
    PCCommentPrimaryTypeChild
};

@interface PCCommentController : PCTableViewController

@property (nonatomic, assign) PCCommentType commentType;
@property (nonatomic, assign, readonly) PCCommentPrimaryType primaryType;

- (instancetype)initWithComicId:(NSString *)comicId;
- (instancetype)initWithGameId:(NSString *)gameId;
- (instancetype)initWithCommentId:(NSString *)commentId;

@end

NS_ASSUME_NONNULL_END
