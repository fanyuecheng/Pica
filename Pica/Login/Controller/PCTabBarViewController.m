//
//  PCTabBarViewController.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTabBarViewController.h"
#import "PCNavigationController.h"
#import "PCCategoryController.h"
#import "PCProfileController.h"
#import "PCNewChatListController.h"
#import "PCGameListController.h"
#import "UIImage+PCAdd.h"
#import "PCLocalKeyHeader.h"

@interface PCTabBarViewController ()

@property (nonatomic, strong) PCCategoryController    *categoryController;
@property (nonatomic, strong) PCNewChatListController *chatController;
@property (nonatomic, strong) PCGameListController    *gameController;
@property (nonatomic, strong) PCProfileController     *profileController;
@property (nonatomic, copy)   NSArray *controllerArray;

@end

@implementation PCTabBarViewController

- (void)didInitialize {
    [super didInitialize];
    
    self.selectedIndex = 0;
    PCNavigationController *category = [[PCNavigationController alloc] initWithRootViewController:self.categoryController];
    category.tabBarItem = [self tabBarItemWithTitle:@"分类"
                                              image:[UIImage pc_iconWithText:ICON_MODULAR size:22 color:UIColorGrayLighten]
                                      selectedImage:[UIImage pc_iconWithText:ICON_MODULAR size:22 color:UIColorBlue]
                                                tag:0];
     
    PCNavigationController *chat = [[PCNavigationController alloc] initWithRootViewController:self.chatController];
    chat.tabBarItem = [self tabBarItemWithTitle:@"聊天"
                                        image:[UIImage pc_iconWithText:ICON_CHAT size:22 color:UIColorGrayLighten]
                                selectedImage:[UIImage pc_iconWithText:ICON_CHAT size:22 color:UIColorBlue]
                                          tag:1];
    
    PCNavigationController *game = [[PCNavigationController alloc] initWithRootViewController:self.gameController];
    game.tabBarItem = [self tabBarItemWithTitle:@"游戏"
                                        image:[UIImage pc_iconWithText:ICON_GAME size:22 color:UIColorGrayLighten]
                                selectedImage:[UIImage pc_iconWithText:ICON_GAME size:22 color:UIColorBlue]
                                          tag:2];
    
    PCNavigationController *me = [[PCNavigationController alloc] initWithRootViewController:self.profileController];
    me.tabBarItem = [self tabBarItemWithTitle:@"我的"
                                        image:[UIImage pc_iconWithText:ICON_USER size:22 color:UIColorGrayLighten]
                                selectedImage:[UIImage pc_iconWithText:ICON_USER size:22 color:UIColorBlue]
                                          tag:3];
    self.controllerArray = @[category, chat, game, me];
    
    [self reloadViewControllers];
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
      
}

- (void)reloadViewControllers {
    NSMutableArray *controllerArray = [NSMutableArray arrayWithArray:self.controllerArray];
    
    if ([kPCUserDefaults boolForKey:PC_TAB_GAME_HIDDEN]) {
        [controllerArray removeObjectAtIndex:2];
    }
    self.viewControllers = controllerArray;
}
 
#pragma mark - Method
- (UITabBarItem *)tabBarItemWithTitle:(NSString *)title
                                image:(UIImage *)image
                        selectedImage:(UIImage *)selectedImage
                                  tag:(NSInteger)tag {
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:tag];
    tabBarItem.selectedImage = selectedImage;
    return tabBarItem;
}

#pragma mark - Get
 
- (PCCategoryController *)categoryController {
    if (!_categoryController) {
        _categoryController = [[PCCategoryController alloc] init];
        _categoryController.hidesBottomBarWhenPushed = NO;
    }
    return _categoryController;
}
 
- (PCProfileController *)profileController {
    if (!_profileController) {
        _profileController = [[PCProfileController alloc] init];
        _profileController.hidesBottomBarWhenPushed = NO;
    }
    return _profileController;
}

- (PCNewChatListController *)chatController {
    if (!_chatController) {
        _chatController = [[PCNewChatListController alloc] init];
        _chatController.hidesBottomBarWhenPushed = NO;
    }
    return _chatController;
}

- (PCGameListController *)gameController {
    if (!_gameController) {
        _gameController = [[PCGameListController alloc] init];
        _gameController.hidesBottomBarWhenPushed = NO;
    }
    return _gameController;
}

@end
