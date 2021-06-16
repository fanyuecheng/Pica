//
//  PCCommentLikeRequest.h
//  Pica
//
//  Created by Fancy on 2021/6/4.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCommentLikeRequest : PCRequest

@property (nonatomic, copy) NSString *commentId;

- (instancetype)initWithCommentId:(NSString *)commentId;

@end

NS_ASSUME_NONNULL_END
