//
//  PCCommentPublishRequest.h
//  Pica
//
//  Created by Fancy on 2021/6/4.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCommentPublishRequest : PCRequest

@property (nonatomic, copy) NSString *comicId;
@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *content;

- (instancetype)initWithComicId:(NSString *)comicId;
- (instancetype)initWithGameId:(NSString *)gameId;
- (instancetype)initWithCommentId:(NSString *)commentId;

@end

NS_ASSUME_NONNULL_END
