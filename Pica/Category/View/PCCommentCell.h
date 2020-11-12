//
//  PCCommentCell.h
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewCell.h"
#import "PCComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCCommentCell : PCTableViewCell

@property (nonatomic, strong) PCComment *comment;

@end

NS_ASSUME_NONNULL_END
