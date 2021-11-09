//
//  PCChatSettingController.m
//  Pica
//
//  Created by Fancy on 2021/10/22.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatSettingController.h"
#import "PCLocalKeyHeader.h"
#import "PCColorPickerViewController.h"
#import "PCAvatarDecorateController.h"
#import "PCUser.h"

@interface PCChatSetting : NSObject

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *key;
@property (nonatomic, strong) id       value;
@property (nonatomic, assign) BOOL      on;

@end

@implementation PCChatSetting

+ (PCChatSetting *)chatTextColor {
    PCChatSetting *setting = [[PCChatSetting alloc] init];
    setting.title = @"聊天文字颜色";
    setting.value = [kPCUserDefaults arrayForKey:PC_CHAT_EVENT_COLOR];
    setting.on = [kPCUserDefaults boolForKey:PC_CHAT_EVENT_COLOR_ON];
    setting.key = PC_CHAT_EVENT_COLOR;
    return setting;
}

+ (PCChatSetting *)chatAvatarDecorate {
    PCChatSetting *setting = [[PCChatSetting alloc] init];
    setting.title = @"聊天头像装饰";
    setting.value = [kPCUserDefaults stringForKey:PC_CHAT_AVATAR_CHARACTER];
    setting.on = [kPCUserDefaults boolForKey:PC_CHAT_AVATAR_CHARACTER_ON];
    setting.key = PC_CHAT_AVATAR_CHARACTER;
    return setting;
}

+ (PCChatSetting *)chatTitle {
    PCChatSetting *setting = [[PCChatSetting alloc] init];
    setting.title = @"聊天称号";
    setting.value = [kPCUserDefaults stringForKey:PC_CHAT_TITLE];
    setting.on = [kPCUserDefaults boolForKey:PC_CHAT_TITLE_ON];
    setting.key = PC_CHAT_TITLE;
    return setting;
}

+ (PCChatSetting *)chatLV {
    PCChatSetting *setting = [[PCChatSetting alloc] init];
    setting.title = @"聊天等级";
    setting.value = [kPCUserDefaults stringForKey:PC_CHAT_LV];
    setting.on = [kPCUserDefaults boolForKey:PC_CHAT_LV_ON];
    setting.key = PC_CHAT_LV;
    return setting;
}

@end

@interface PCChatSettingController ()

@property (nonatomic, copy) NSArray <PCChatSetting *> *dataSource;

@end

@implementation PCChatSettingController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dataSource = nil;
    [self.tableView reloadData];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"聊天室设置";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:tableView withStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.textLabel.text = nil;
    cell.textLabel.attributedText = nil;
    
    id value = self.dataSource[indexPath.section].value;
    if (value) {
        if ([value isKindOfClass:[NSString class]]) {
            cell.textLabel.text = value;
        } else  {
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
            for (NSString *color in (NSArray *)value) {
                [attributedText appendAttributedString:[NSAttributedString qmui_attributedStringWithImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(color) size:CGSizeMake(10, 10) cornerRadius:4] margins:UIEdgeInsetsMake(0, 0, 0, 10)]];
            }
            cell.textLabel.attributedText = attributedText;
        }
    } else {
        cell.textLabel.text = @"未设置";
    }
    if (indexPath.section == 3) {
        if (value && ![value isEqualToString:@"随机"]) {
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:[PCUser localCharacterImage]] options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image) {
                    cell.imageView.image = [image qmui_imageResizedInLimitedSize:CGSizeMake(30, 30)];
                }
            }];
        } else {
            cell.imageView.image = nil;
        }
    } else {
        cell.imageView.image = nil;
    }
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    if (!switchView) {
        switchView = [[UISwitch alloc] init];
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }
    
    switchView.on = self.dataSource[indexPath.section].on;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        case 1:
            [self showAlertWithSetting:self.dataSource[indexPath.section]];
            break;
        case 2:
            [self pickColor];
            break;
        case 3:
            [self pickDecorate]; 
            break;
        default:
            break;
    }
}

#pragma mark - Method
- (void)pickColor {
    PCColorPickerViewController *pickColor = [[PCColorPickerViewController alloc] init];
    [self.navigationController pushViewController:pickColor animated:YES];
}

- (void)pickDecorate {
    PCAvatarDecorateController *pickDecorate = [[PCAvatarDecorateController alloc] init];
    [self.navigationController pushViewController:pickDecorate animated:YES];
}

- (void)showAlertWithSetting:(PCChatSetting *)setting {
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        setting.value = aAlertController.textFields.firstObject.text;
        [kPCUserDefaults setObject:setting.value forKey:setting.key];
        [self.tableView reloadData];
    }];

    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];

    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:setting.title message:nil preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(QMUITextField * _Nonnull textField) {
        textField.placeholder = [NSString stringWithFormat:@"请输入%@", setting.title];
    }];
 
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

#pragma mark - Action
- (void)switchAction:(UISwitch *)sender {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:sender];
    PCChatSetting *setting = self.dataSource[indexPath.section];
    setting.on = !setting.on;
    [kPCUserDefaults setBool:setting.on forKey:[NSString stringWithFormat:@"%@_ON", setting.key]];
    [self.tableView reloadData];
}
 
#pragma mark - Get
- (NSArray<PCChatSetting *> *)dataSource {
    if (!_dataSource) {
        _dataSource = @[[PCChatSetting chatLV],
                        [PCChatSetting chatTitle],
                        [PCChatSetting chatTextColor],
                        [PCChatSetting chatAvatarDecorate]];
    }
    return _dataSource;
}

@end
