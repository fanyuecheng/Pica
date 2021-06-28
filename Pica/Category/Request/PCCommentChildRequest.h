//
//  PCCommentChildRequest.h
//  Pica
//
//  Created by Fancy on 2021/6/4.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCommentChildRequest : PCRequest

@property (nonatomic, assign) PCCommentType type;
@property (nonatomic, copy)   NSString  *commentId;
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithCommentId:(NSString *)commentId;

@end

NS_ASSUME_NONNULL_END
