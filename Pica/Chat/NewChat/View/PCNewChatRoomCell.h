//
//  PCNewChatRoomCell.h
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class PCNewChatRoom;
@interface PCNewChatRoomCell : PCTableViewCell

@property (nonatomic, strong) PCNewChatRoom *room;

@end

NS_ASSUME_NONNULL_END
