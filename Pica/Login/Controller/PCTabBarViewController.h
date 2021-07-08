//
//  PCTabBarViewController.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PC_TAB_GAME_HIDDEN   @"PC_TAB_GAME_HIDDEN"

@interface PCTabBarViewController : QMUITabBarViewController

- (void)reloadViewControllers;

@end

NS_ASSUME_NONNULL_END
