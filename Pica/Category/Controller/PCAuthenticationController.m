//
//  PCAuthenticationController.m
//  Pica
//
//  Created by Fancy on 2022/1/21.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCAuthenticationController.h"
#import "PCLocalAuthentication.h"
 
@interface PCAuthenticationController ()

@property (nonatomic, strong) QMUIButton *authenticateButton;

@end

@implementation PCAuthenticationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self authenticateAction];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.authenticateButton];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"验证";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.authenticateButton.frame = self.view.bounds;
}

#pragma mark - Action
- (void)authenticateAction {
    [[PCLocalAuthentication sharedInstance] authenticationWithDescribe:@"验证以用于解锁Pica" stateBlock:^(NSError * _Nonnull error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Get
- (QMUIButton *)authenticateButton {
    if (!_authenticateButton) {
        _authenticateButton = [[QMUIButton alloc] init];
        _authenticateButton.titleLabel.font = UIFontBoldMake(15);
        [_authenticateButton setTitle:@"开始验证" forState:UIControlStateNormal];
        [_authenticateButton setTitleColor:UIColorBlack forState:UIControlStateNormal];
        [_authenticateButton addTarget:self action:@selector(authenticateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _authenticateButton;
}

@end
