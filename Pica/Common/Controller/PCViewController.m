//
//  PCViewController.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCViewController.h"

@interface PCViewController ()

@end

@implementation PCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)showEmptyView {
    [super showEmptyView];
    self.emptyView.backgroundColor = UIColorWhite;
}

- (void)didInitialize {
    [super didInitialize];
    self.hidesBottomBarWhenPushed = YES;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDWebImageManager sharedManager] cancelAll];
}

@end
