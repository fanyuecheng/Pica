//
//  PCRegistController.m
//  Pica
//
//  Created by YueCheng on 2021/2/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRegistController.h"
#import "PCRegistRequest.h"

@interface PCRegistController ()

@property (nonatomic, strong) UIScrollView  *contentView;
@property (nonatomic, strong) QMUITextField *nameTextField;
@property (nonatomic, strong) QMUITextField *emailTextField;
@property (nonatomic, strong) QMUITextField *passwordTextField;
@property (nonatomic, strong) QMUIButton    *birthdayButton;
@property (nonatomic, strong) UISegmentedControl *genderControl;
@property (nonatomic, strong) QMUIButton    *questionButton;
@property (nonatomic, strong) QMUITextField *answer1;
@property (nonatomic, strong) QMUITextField *answer2;
@property (nonatomic, strong) QMUITextField *answer3;
@property (nonatomic, strong) QMUITextField *question1;
@property (nonatomic, strong) QMUITextField *question2;
@property (nonatomic, strong) QMUITextField *question3;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) QMUIModalPresentationViewController *modalController;

@end

@implementation PCRegistController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initSubviews {
    [super initSubviews];
   
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.nameTextField];
    [self.contentView addSubview:self.emailTextField];
    [self.contentView addSubview:self.passwordTextField];
    [self.contentView addSubview:self.birthdayButton];
    [self.contentView addSubview:self.genderControl];
    [self.contentView addSubview:self.questionButton];
    
    [self.contentView addSubview:self.question1];
    [self.contentView addSubview:self.answer1];
    [self.contentView addSubview:self.question2];
    [self.contentView addSubview:self.answer2];
    [self.contentView addSubview:self.question3];
    [self.contentView addSubview:self.answer3];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"注册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.contentView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, SCREEN_WIDTH, SCREEN_HEIGHT - self.qmui_navigationBarMaxYInViewCoordinator);
    self.nameTextField.frame = CGRectMake(15, 20, SCREEN_WIDTH - 30, 50);
    self.emailTextField.frame = CGRectMake(15, self.nameTextField.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.passwordTextField.frame = CGRectMake(15, self.emailTextField.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.birthdayButton.frame = CGRectMake(15, self.passwordTextField.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.genderControl.frame = CGRectMake(15, self.birthdayButton.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.questionButton.frame = CGRectMake(15, self.genderControl.qmui_bottom + 5, SCREEN_WIDTH - 30, 40);
    self.question1.frame = CGRectMake(SCREEN_WIDTH + 15, self.nameTextField.qmui_top, SCREEN_WIDTH - 30, 50);
    self.answer1.frame = CGRectMake(SCREEN_WIDTH + 15, self.question1.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.question2.frame = CGRectMake(SCREEN_WIDTH + 15, self.answer1.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.answer2.frame = CGRectMake(SCREEN_WIDTH + 15, self.question2.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.question3.frame = CGRectMake(SCREEN_WIDTH + 15, self.answer2.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
    self.answer3.frame = CGRectMake(SCREEN_WIDTH + 15, self.question3.qmui_bottom + 5, SCREEN_WIDTH - 30, 50);
}

#pragma mark - Action
- (void)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction:(UIBarButtonItem *)sender {
    NSString *name = self.nameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *birthday = self.birthdayButton.currentTitle;
    NSString *gender = nil;
    switch (self.genderControl.selectedSegmentIndex) {
        case 0:
            gender = @"m";
            break;
        case 1:
            gender = @"f";
            break;
        default:
            gender = @"bot";
            break;
    }
    NSString *question1 = self.question1.text;
    NSString *question2 = self.question2.text;
    NSString *question3 = self.question3.text;
    NSString *answer1 = self.answer1.text;
    NSString *answer2 = self.answer2.text;
    NSString *answer3 = self.answer3.text;
    
    if (name.length < 2 || name.length > 50) {
        [QMUITips showError:@"请输入正确昵称（2-50字）"];
        return;
    }
    if (email.length < 2 || name.length > 30) {
        [QMUITips showError:@"请输入正确ID（0-9，a-z，2-30字）"];
        return;
    }
    if (password.length < 8) {
        [QMUITips showError:@"请输入正确密码（8字以上）"];
        return;
    }
    if ([birthday isEqualToString:@"生日"]) {
        [QMUITips showError:@"请设置生日"];
        return;
    }
    if (!question1.length) {
        [QMUITips showError:@"请输入问题1"];
        return;
    }
    if (!question2.length) {
        [QMUITips showError:@"请输入问题2"];
        return;
    }
    if (!question3.length) {
        [QMUITips showError:@"请输入问题3"];
        return;
    }
    if (!answer1.length) {
        [QMUITips showError:@"请输入答案1"];
        return;
    }
    if (!answer2.length) {
        [QMUITips showError:@"请输入答案2"];
        return;
    }
    if (!answer3.length) {
        [QMUITips showError:@"请输入答案3"];
        return;
    }
    
    QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
    
    PCRegistRequest *request = [[PCRegistRequest alloc] init];
    request.name = name;
    request.email = email;
    request.password = password;
    request.birthday = birthday;
    request.gender = gender;
    request.question1 = question1;
    request.question2 = question2;
    request.question3 = question3;
    request.answer1 = answer1;
    request.answer2 = answer2;
    request.answer3 = answer3;
    
    [request sendRequest:^(id  _Nonnull response) {
        [loading hideAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:PCRegistSuccessNotification object:@{@"email" : email, @"password" : password}];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError * _Nonnull error) {
        [loading hideAnimated:NO];
    }];
}

- (void)questionAction:(QMUIButton *)sender {
    [self.contentView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
}

- (void)birthdayAction:(QMUIButton *)sender {
    QMUIModalPresentationViewController *modal = [[QMUIModalPresentationViewController alloc] init];
    modal.contentView = self.datePicker;
    @weakify(self)
    modal.willHideByDimmingViewTappedBlock = ^{
        @strongify(self)
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setLocale:[NSLocale currentLocale]];
        
        [self.birthdayButton setTitle:[formatter stringFromDate:self.datePicker.date] forState:UIControlStateNormal];
    };
     
    [modal showWithAnimated:YES completion:nil];
}

#pragma mark - Get
- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _contentView.pagingEnabled = YES;
        _contentView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _contentView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, 0);
    }
    return _contentView;
}

- (QMUITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[QMUITextField alloc] init];
        _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextField.placeholder = @"昵称（2-50字）";
    }
    return _nameTextField;
}

- (QMUITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[QMUITextField alloc] init];
        _emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        _emailTextField.placeholder = @"登录ID（小写英文 1-30字）";
    }
    return _emailTextField;
}

- (QMUITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[QMUITextField alloc] init];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.placeholder = @"密码（8+字）";
    }
    return _passwordTextField;
}

- (QMUIButton *)birthdayButton {
    if (!_birthdayButton) {
        _birthdayButton = [QMUIButton buttonWithType:UIButtonTypeSystem];
        _birthdayButton.layer.cornerRadius = 4;
        _birthdayButton.layer.borderWidth = 0.5;
        _birthdayButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_birthdayButton setTitle:@"生日" forState:UIControlStateNormal];
        [_birthdayButton addTarget:self action:@selector(birthdayAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _birthdayButton;
}

- (UISegmentedControl *)genderControl {
    if (!_genderControl) {
        _genderControl = [[UISegmentedControl alloc] initWithItems:@[@"绅士", @"淑女", @"机器人"]];
        _genderControl.selectedSegmentIndex = 0;
    }
    return _genderControl;
}
 
- (QMUITextField *)question1 {
    if (!_question1) {
        _question1 = [[QMUITextField alloc] init];
        _question1.borderStyle = UITextBorderStyleRoundedRect;
        _question1.placeholder = @"问题1";
    }
    return _question1;
}

- (QMUITextField *)question2 {
    if (!_question2) {
        _question2 = [[QMUITextField alloc] init];
        _question2.borderStyle = UITextBorderStyleRoundedRect;
        _question2.placeholder = @"问题2";
    }
    return _question2;
}

- (QMUITextField *)question3 {
    if (!_question3) {
        _question3 = [[QMUITextField alloc] init];
        _question3.borderStyle = UITextBorderStyleRoundedRect;
        _question3.placeholder = @"问题3";
    }
    return _question3;
}
    
- (QMUITextField *)answer1 {
    if (!_answer1) {
        _answer1 = [[QMUITextField alloc] init];
        _answer1.borderStyle = UITextBorderStyleRoundedRect;
        _answer1.placeholder = @"答案1";
    }
    return _answer1;
}

- (QMUITextField *)answer2 {
    if (!_answer2) {
        _answer2 = [[QMUITextField alloc] init];
        _answer2.borderStyle = UITextBorderStyleRoundedRect;
        _answer2.placeholder = @"答案2";
    }
    return _answer2;
}

- (QMUITextField *)answer3 {
    if (!_answer3) {
        _answer3 = [[QMUITextField alloc] init];
        _answer3.borderStyle = UITextBorderStyleRoundedRect;
        _answer3.placeholder = @"答案3";
    }
    return _answer3;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.layer.cornerRadius = 4;
        _datePicker.layer.masksToBounds = YES;
        _datePicker.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_GB"];
        _datePicker.maximumDate = [NSDate date];
        _datePicker.qmui_layoutSubviewsBlock = ^(__kindof UIView * _Nonnull view) {
            view.backgroundColor = UIColorWhite;
        };
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
    }
    return _datePicker;
}

- (QMUIButton *)questionButton {
    if (!_questionButton) {
        _questionButton = [QMUIButton buttonWithType:UIButtonTypeSystem];
        [_questionButton setTitle:@"安全问题->" forState:UIControlStateNormal];
        [_questionButton addTarget:self action:@selector(questionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionButton;
}

@end
