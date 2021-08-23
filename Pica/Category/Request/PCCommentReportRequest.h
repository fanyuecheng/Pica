//
//  PCCommentReportRequest.h
//  Pica
//
//  Created by Fancy on 2021/7/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCommentReportRequest : PCRequest

@property (nonatomic, strong) NSString *commentId;

- (instancetype)initWithCommentId:(NSString *)commentId;

@end

NS_ASSUME_NONNULL_END
