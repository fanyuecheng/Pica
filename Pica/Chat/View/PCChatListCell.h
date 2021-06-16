//
//  PCChatListCell.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class PCChatList;
@interface PCChatListCell : PCTableViewCell

@property (nonatomic, strong) PCChatList *list;

@end

NS_ASSUME_NONNULL_END
