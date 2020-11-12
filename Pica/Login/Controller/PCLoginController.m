//
//  PCLoginController.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCLoginController.h" 
#import "AppDelegate.h"

@interface PCLoginController ()

@property (nonatomic, strong) QMUITextField *accountTextField;
@property (nonatomic, strong) QMUITextField *passwordTextField;
@property (nonatomic, strong) QMUIButton    *loginButton;

@end

@implementation PCLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
     
}


- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.accountTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
}
 
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.accountTextField.frame = CGRectMake(15, 150, SCREEN_WIDTH - 30, 50);
    self.passwordTextField.frame = CGRectMake(15, 210, SCREEN_WIDTH - 30, 50);
    self.loginButton.frame = CGRectMake(15, 300, SCREEN_WIDTH - 30, 50);
}

#pragma mark - Action
- (void)loginAction:(QMUIButton *)sender {
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (account.length && password.length) {
        PCLoginRequest *request = [[PCLoginRequest alloc] initWithAccount:account password:password];
        [request sendRequest:^(id  _Nonnull response) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate setRootViewControllerToTab];
        } failure:nil];
    } else {
        [QMUITips showError:@"请输入账号或者密码"];
    }
}

#pragma mark - Get
- (QMUITextField *)accountTextField {
    if (!_accountTextField) {
        _accountTextField = [[QMUITextField alloc] init];
        _accountTextField.borderStyle = UITextBorderStyleRoundedRect;
        _accountTextField.placeholder = @"账号";
    }
    return _accountTextField;
}

- (QMUITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[QMUITextField alloc] init];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.placeholder = @"密码";
    }
    return _passwordTextField;
}

- (QMUIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [QMUIButton buttonWithType:UIButtonTypeSystem];
        _loginButton.layer.cornerRadius = 4;
        _loginButton.layer.borderWidth = 0.5;
        _loginButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}


@end
