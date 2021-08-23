//  test "sdwojcudd"  
//  PCLoginController.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//
//

#import "PCLoginController.h"
#import "PCRegistController.h"
#import "PCNavigationController.h"
#import "AppDelegate.h"

@interface PCLoginController ()

@property (nonatomic, strong) QMUITextField *accountTextField;
@property (nonatomic, strong) QMUITextField *passwordTextField;
@property (nonatomic, strong) QMUIButton    *loginButton;
@property (nonatomic, strong) QMUIButton    *registButton;
@property (nonatomic, copy)   NSArray       *accountArray;
@property (nonatomic, strong) UIScrollView  *inputAccountView;

@end

@implementation PCLoginController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registSuccess:) name:PCRegistSuccessNotification object:nil];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.accountTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.registButton];
}
 
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.accountTextField.frame = CGRectMake(15, 150, SCREEN_WIDTH - 30, 50);
    self.passwordTextField.frame = CGRectMake(15, 210, SCREEN_WIDTH - 30, 50);
    self.loginButton.frame = CGRectMake(15, 300, SCREEN_WIDTH - 30, 50);
    self.registButton.frame = CGRectMake((SCREEN_WIDTH - 60) * 0.5, self.loginButton.qmui_bottom + 20, 60, 20);
}

- (void)registSuccess:(NSNotification *)notification {
    NSDictionary *data = notification.object;
    
    self.accountTextField.text = data[@"email"];
    self.passwordTextField.text = data[@"password"];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [data yy_modelToJSONString];
    [QMUITips showSucceed:@"注册信息已经复制到剪切板，请注意保存~"];
}

#pragma mark - Action
- (void)loginAction:(QMUIButton *)sender {
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (account.length && password.length) {
        QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
        PCLoginRequest *request = [[PCLoginRequest alloc] initWithAccount:account password:password];
        [request sendRequest:^(id  _Nonnull response) {
            [loading hideAnimated:NO];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate setRootViewControllerToTab];
        } failure:^(NSError * _Nonnull error) {
            [loading hideAnimated:NO];
        }];
    } else {
        [QMUITips showError:@"请输入账号或者密码"];
    }
}

- (void)registAction:(QMUIButton *)sender {
    PCRegistController *regist = [[PCRegistController alloc] init];
    PCNavigationController *navi = [[PCNavigationController alloc] initWithRootViewController:regist];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)accountAction:(QMUIButton *)sender {
    self.accountTextField.text = sender.currentTitle;
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Get
- (QMUITextField *)accountTextField {
    if (!_accountTextField) {
        _accountTextField = [[QMUITextField alloc] init];
        _accountTextField.borderStyle = UITextBorderStyleRoundedRect;
        _accountTextField.placeholder = @"账号";
        _accountTextField.inputAccessoryView = self.inputAccountView;
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

- (QMUIButton *)registButton {
    if (!_registButton) {
        _registButton = [QMUIButton buttonWithType:UIButtonTypeSystem];
        [_registButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registButton addTarget:self action:@selector(registAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registButton;
}

- (NSArray *)accountArray {
    if (!_accountArray) {
        _accountArray = [kPCUserDefaults arrayForKey:PC_LOCAL_ACCOUNT];
    }
    return _accountArray;
}

- (UIScrollView *)inputAccountView {
    if (!_inputAccountView) {
        _inputAccountView = [[UIScrollView alloc] init];
        _inputAccountView.showsHorizontalScrollIndicator = NO;
        _inputAccountView.backgroundColor = UIColorWhite;
        _inputAccountView.qmui_borderPosition = QMUIViewBorderPositionTop;
        _inputAccountView.qmui_width = .5;
        if (self.accountArray.count) {
            __block UIButton *lastButton = nil;
            [self.accountArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                QMUIButton *button = [[QMUIButton alloc] init];
                button.layer.cornerRadius = 4;
                button.layer.masksToBounds = YES;
                button.titleLabel.font = UIFontMake(14);
                [button setTitleColor:UIColorWhite forState:UIControlStateNormal];
                [button setTitle:obj forState:UIControlStateNormal];
                button.backgroundColor = UIColorGray6;
                [button addTarget:self action:@selector(accountAction:) forControlEvents:UIControlEventTouchUpInside];
                [button sizeToFit];
                [_inputAccountView addSubview:button];
                button.frame = CGRectMake(lastButton ? CGRectGetMaxX(lastButton.frame) + 10 : 15, (44 - CGRectGetHeight(button.bounds)) * 0.5, CGRectGetWidth(button.bounds) + 10, CGRectGetHeight(button.bounds));
                lastButton = button;
            }];
            _inputAccountView.contentSize = CGSizeMake(CGRectGetMaxX(lastButton.frame) + 15, 0);
            _inputAccountView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        }
    }
    return _inputAccountView;
}
 
@end
