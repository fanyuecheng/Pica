//
//  PCSettingController.m
//  Pica
//
//  Created by YueCheng on 2021/5/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCSettingController.h"
#import "PCPasswordSetRequest.h"

@interface PCSettingController ()

@property (nonatomic, copy)   NSArray *dataSource;
@property (nonatomic, strong) PCPasswordSetRequest *passwordSetRequest;

@end

@implementation PCSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"设置";
}

- (void)initTableView {
    [super initTableView];
    
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    if (indexPath.row == 0) {
        long long fileSize = [[SDImageCache sharedImageCache] totalDiskSize];
        cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self showClearCacheAlert];
            break;
        case 1:
            [self showUpdatePasswordAlert];
            break;
        default:
            break;
    }
}

#pragma mark - Method
- (void)showClearCacheAlert {
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [self.tableView reloadData];
        }];
    }];
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"确认清除缓存?" message:nil preferredStyle:QMUIAlertControllerStyleAlert];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}
 
- (void)showUpdatePasswordAlert {
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        self.passwordSetRequest.passwordOld = aAlertController.textFields.firstObject.text;
        self.passwordSetRequest.passwordNew = aAlertController.textFields.lastObject.text;
        [self updatePassword];
    }];
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"修改密码" message:@"请输入旧密码和新密码" preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(QMUITextField * _Nonnull textField) {
        textField.placeholder = @"旧密码";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(QMUITextField * _Nonnull textField) {
        textField.placeholder = @"新密码";
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

#pragma mark - Net
- (void)updatePassword {
    if (self.passwordSetRequest.passwordOld.length &&
        self.passwordSetRequest.passwordNew.length) {
        QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
        [self.passwordSetRequest sendRequest:^(id  _Nonnull response) {
            [loading hideAnimated:YES];
            [QMUITips showSucceed:@"修改密码成功"];
        } failure:^(NSError * _Nonnull error) {
            [loading hideAnimated:YES];
        }];
    }
}

#pragma mark - Get
- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"清除缓存", @"修改密码"];
    }
    return _dataSource;
}

- (PCPasswordSetRequest *)passwordSetRequest {
    if (!_passwordSetRequest) {
        _passwordSetRequest = [[PCPasswordSetRequest alloc] init];
    }
    return _passwordSetRequest;
}

@end
