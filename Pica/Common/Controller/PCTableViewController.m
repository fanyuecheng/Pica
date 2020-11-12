//
//  PCTableViewController.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//

#import "PCTableViewController.h"

@interface PCTableViewController ()

@end

@implementation PCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
}

@end
