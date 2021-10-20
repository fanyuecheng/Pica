//
//  PCChatViewController.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCChatViewController : PCViewController

- (instancetype)initWithURL:(NSString *)url;

+ (PCChatViewController *)chatViewControllerWithURL:(NSString *)url;
+ (void)deleteChatViewControllerWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
