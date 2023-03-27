//
//  PCNewChatMentionView.h
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatMentionView : UIView

@property (nonatomic, copy) void (^removeBlock)(PCUser *user);

- (void)addMentionUser:(PCUser *)user;
- (void)removeMentionUser:(PCUser *)user;
- (void)clearMention;

@end

NS_ASSUME_NONNULL_END
