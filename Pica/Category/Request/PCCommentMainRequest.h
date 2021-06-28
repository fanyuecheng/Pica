//
//  PCCommentMainRequest.h
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCommentMainRequest : PCRequest

@property (nonatomic, assign) PCCommentType type;
@property (nonatomic, copy)   NSString  *objectId;
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithObjectId:(NSString *)objectId;

@end

NS_ASSUME_NONNULL_END
