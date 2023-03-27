//
//  PCNewChatViewController.m
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatViewController.h"
#import "PCNewChatManager.h"
#import "PCNewChatMentionView.h"
#import "PCNewChatTextMessageCell.h"
#import "PCNewChatImageMessageCell.h"
#import "UIImage+PCAdd.h"

static CGFloat const kChatBarTextViewBottomOffset = 10;
static CGFloat const kChatBarTextViewMinHeight = 37.f;
static CGFloat const kChatBarTextViewMaxHeight = 102.f;

@interface PCNewChatViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, QMUITextViewDelegate>

@property (nonatomic, copy)   NSString         *roomId;
@property (nonatomic, strong) PCNewChatManager *manager;
@property (nonatomic, strong) PCNewChatMessage *replyMessage;
@property (nonatomic, strong) NSMutableArray   <PCUser *> *atArray;

@property (nonatomic, strong) UITableView      *tableView;
@property (nonatomic, strong) QMUIButton       *replyButton;
@property (nonatomic, strong) PCNewChatMentionView *mentionView;
@property (nonatomic, strong) UIView           *toolbarView;
@property (nonatomic, strong) QMUITextView     *textView;
@property (nonatomic, strong) QMUIButton       *imageButton;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, assign) CGFloat          textViewHeight;
@property (nonatomic, assign) CGFloat          keyboardHeight;
@property (nonatomic, strong) NSMutableArray   *messageArray;
@property (nonatomic, strong) NSMutableArray   *localMessageArray;

@property (nonatomic, strong) QMUIModalPresentationViewController *modalController;

@end

@implementation PCNewChatViewController

- (void)dealloc {
    [self.manager disconnect];
}

- (instancetype)initWithRoomId:(NSString *)roomId {
    if (self = [super init]) {
        self.roomId = roomId;
        self.textViewHeight = kChatBarTextViewMinHeight;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self connect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self localMessageArray];
    });
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.replyButton];
    [self.view addSubview:self.mentionView];
    [self.view addSubview:self.toolbarView];
    
    [self.toolbarView addSubview:self.textView];
    [self.toolbarView addSubview:self.imageButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat naviBottom = self.qmui_navigationBarMaxYInViewCoordinator;
    CGFloat safeAreaBottom = SafeAreaInsetsConstantForDeviceWithNotch.bottom;
    
    CGFloat toolbarBottom = self.keyboardHeight ? self.keyboardHeight : 0;
    CGFloat toolbarHeight = self.textViewHeight + kChatBarTextViewBottomOffset * 2 + (self.keyboardHeight ? 0 : safeAreaBottom);
    self.toolbarView.frame = CGRectMake(0, SCREEN_HEIGHT - toolbarBottom - toolbarHeight, SCREEN_WIDTH, toolbarHeight);
    self.textView.frame = CGRectMake(16, kChatBarTextViewBottomOffset, SCREEN_WIDTH - kChatBarTextViewBottomOffset * 2 - kChatBarTextViewMinHeight - 16, self.textViewHeight);
    self.imageButton.frame = CGRectMake(SCREEN_WIDTH - kChatBarTextViewMinHeight - 10, self.textView.qmui_bottom - kChatBarTextViewMinHeight, kChatBarTextViewMinHeight, kChatBarTextViewMinHeight);
    self.replyButton.frame = self.replyMessage ? CGRectMake(0, self.toolbarView.qmui_top - 44, SCREEN_WIDTH, 44) : CGRectZero;
    self.mentionView.frame = self.atArray.count ? CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight) : CGRectZero;
    self.mentionView.qmui_top = self.replyMessage ? self.replyButton.qmui_top - self.mentionView.qmui_height : self.toolbarView.qmui_top - self.mentionView.qmui_height;
    self.tableView.frame = CGRectMake(0, naviBottom, SCREEN_WIDTH, self.toolbarView.qmui_top - naviBottom - (self.replyMessage ? 44 : 0) - (self.atArray.count ? self.mentionView.qmui_height : 0));
}

#pragma mark - Method
- (void)connect {
    [self showEmptyViewWithLoading];
    [self.manager connect];
}
 
#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCNewChatMessage *message = self.messageArray[indexPath.row];
    PCNewChatMessageCell *cell = nil;
    
    if (message.messageType == PCNewChatMessageTypeText) {
        PCNewChatTextMessageCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"PCNewChatTextMessageCell" forIndexPath:indexPath];
        textCell.message = message;
        cell = textCell;
    } else if (message.messageType == PCNewChatMessageTypeImage) {
        PCNewChatImageMessageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"PCNewChatImageMessageCell" forIndexPath:indexPath];
        imageCell.message = message;
        cell = imageCell;
    }
    @weakify(self)
    cell.atBlock = ^(PCNewChatMessage * _Nonnull msg) {
        @strongify(self)
        __block BOOL contain = NO;
        [self.atArray enumerateObjectsUsingBlock:^(PCUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:msg.profile.userId]) {
                contain = YES;
                *stop = YES;
            }
        }];
        if (!contain) {
            [self.atArray addObject:msg.profile];
            [self.mentionView addMentionUser:msg.profile];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } 
    };
    
    if (cell) {
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCNewChatMessage *message = self.messageArray[indexPath.row];
    if (message.messageType == PCNewChatMessageTypeText) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCNewChatTextMessageCell" configuration:^(PCNewChatTextMessageCell *cell) {
            cell.message = message;
        }];
    } else if (message.messageType == PCNewChatMessageTypeImage) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCNewChatImageMessageCell" configuration:^(PCNewChatImageMessageCell *cell) {
            cell.message = message;
        }];
    } else {
        return 0;
    }
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCNewChatMessage *message = self.messageArray[indexPath.row];
    BOOL isMyself = [message.profile.userId isEqualToString:[PCUser localUser].userId];
    if (isMyself) {
        return nil;
    }
    @weakify(self)
    UIContextualAction *replyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"回复" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        @strongify(self)
        self.replyMessage = message;
        completionHandler(YES);
    }];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[replyAction]];
    
    return config;
}

#pragma mark - Action

- (void)pictureAction:(QMUIButton *)sender {
    [self.textView endEditing:YES];
    
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"拍照" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [self takePhoto];
    }];
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"从手机相册选择" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [self pickImage];
    }];
    
    QMUIAlertAction *action3 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:nil message:nil preferredStyle:QMUIAlertControllerStyleActionSheet];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController showWithAnimated:YES];
}

#pragma mark - Private Method
- (void)showKeyboardWithUserInfo:(QMUIKeyboardUserInfo *)info {
    if (info) {
        // 相对于键盘
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:info animations:^{
            CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:self.view keyboardRect:info.endFrame];
            self.keyboardHeight = distanceFromBottom;
        } completion:NULL];
    } else {
        // TODO
        
    }
}

- (void)hideKeyboardWithUserInfo:(QMUIKeyboardUserInfo *)info {
    if (info) {
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:info animations:^{
            self.keyboardHeight = 0;
        } completion:NULL];
    } else {
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.keyboardHeight = 0;
        } completion:NULL];
    }
}

- (void)insertMessage:(PCNewChatMessage *)message scrollToBottom:(BOOL)scroll {
    BOOL isBottom = self.tableView.contentOffset.y >= self.tableView.contentSize.height + self.tableView.adjustedContentInset.bottom - CGRectGetHeight(self.tableView.bounds) - 300;
    
    [self.messageArray addObject:message];
    [self.tableView reloadData];
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isBottom && scroll && !(self.tableView.isDragging || self.tableView.isTracking)) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

- (void)forceScrollToBottom {
    [self.tableView qmui_scrollToBottomAnimated:YES];
}

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) {
                //第一次不允许的操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
                });
                return ;
            }
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        //允许权限之后的操作
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //不允许权限之后的操作 & 系统受限制之后的操作
        QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"去设置" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }];
        
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
        
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"请允许Pica访问您的相机" message:nil preferredStyle:QMUIAlertControllerStyleAlert];
        
        [alertController addAction:action1];
        [alertController addAction:action2];
        [alertController showWithAnimated:YES];
        return;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //相机不可用
        return;
    }
    
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)pickImage {
    if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotDetermined) {
        [QMUIAssetsManager requestAuthorization:^(QMUIAssetAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentAlbumViewController];
            });
        }];
    } else {
        [self presentAlbumViewController];
    }
}

- (void)presentAlbumViewController {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)messageDidSent:(PCNewChatMessage *)message {
    self.textView.text = @"";
    BOOL updateLayout = NO;
    if (self.replyMessage) {
        self.replyMessage = nil;
        updateLayout = YES;
    }
    if (self.atArray.count) {
        [self.atArray removeAllObjects];
        updateLayout = YES;
    }
    if (updateLayout) {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - TextViewDelegate
- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height {
    height = ceilf(height);
    
    if (self.textViewHeight == height) {
        return;
    }
    
    if (height < kChatBarTextViewMinHeight) {
        height = kChatBarTextViewMinHeight;
    }
    
    //Min 37
    if (height >= kChatBarTextViewMinHeight && height < kChatBarTextViewMaxHeight) {
        self.textViewHeight = height;
        [self.view setNeedsLayout];
        
        if (textView.isFirstResponder) {
            [UIView animateWithDuration:0.25f animations:^{
                [self.view layoutIfNeeded];
            }];
        } else {
            [self.view layoutIfNeeded];
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self forceScrollToBottom];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
//发送文本
- (BOOL)textViewShouldReturn:(QMUITextView *)textView {
    NSString *text = [self.textView.text copy];
    //替换 \r
    while ([text containsString:@"\r"]) {
        text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    }
    
    if (text.length != 0) {
        [self.manager sendMessage:text image:nil replay:self.replyMessage mention:self.atArray finished:^(PCNewChatMessage * _Nonnull message, NSError * _Nonnull error) {
            if (message) {
                [self messageDidSent:message];
            }
        }];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        if (textView.text.length > range.location) {
            // 一次性删除 @xxx 这种 @ 消息
            if ([textView.text characterAtIndex:range.location] == ' ') {
                NSUInteger location = range.location;
                NSUInteger length = range.length;
                int at = 64;    // '@' 对应的ascii码
                while (location != 0) {
                    location --;
                    length ++ ;
                    int c = (int)[textView.text characterAtIndex:location]; // 将字符转成ascii码，复制给int,避免越界
                    if (c == at) {
//                        NSString *atText = [textView.text substringWithRange:NSMakeRange(location, length)];
                        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                        return NO;
                    }
                }
            }
        }
    }
    // 监听 @ 字符的输入
    else if ([text isEqualToString:@"@"]) {
         
    } else if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
 
    NSURL *imageURL = info[UIImagePickerControllerImageURL];
    NSData *data = [NSData dataWithContentsOfURL:imageURL];
 
    QMUIDialogViewController *dialogViewController = [[QMUIDialogViewController alloc] init];
    dialogViewController.headerViewHeight = 0;
    dialogViewController.maximumContentViewWidth = SCREEN_WIDTH - 40;
      
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH - 40 + 100)];
    contentView.backgroundColor = UIColorWhite;
     
    UIImageView *imageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_WIDTH - 40)];
    SDAnimatedImage *image = [[SDAnimatedImage alloc] initWithData:data];
    imageView.image = image;
    [contentView addSubview:imageView];
    
    QMUITextView *textView = [[QMUITextView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH - 40, SCREEN_WIDTH - 40, 100)];
    textView.placeholder = @"说明文字";
    textView.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15);
    [contentView addSubview:imageView];
    [contentView addSubview:textView];
    dialogViewController.contentView = contentView;
    [dialogViewController addCancelButtonWithText:@"取消" block:nil];
    [dialogViewController addSubmitButtonWithText:@"发送" block:^(QMUIDialogViewController *controller) {
        [controller hide];
        [self.manager sendMessage:textView.text image:data replay:self.replyMessage mention:self.atArray finished:^(PCNewChatMessage * _Nonnull message, NSError * _Nonnull error) {
            if (message) {
                [self messageDidSent:message];
            }
        }];
    }];
    [dialogViewController show];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Get
- (PCNewChatManager *)manager {
    if (!_manager) {
        _manager = [[PCNewChatManager alloc] initWithRoomId:self.roomId];
         
        @weakify(self)
        _manager.messageBlock = ^(PCNewChatMessage * _Nonnull message) {
            @strongify(self)
            if (message) {
                [self insertMessage:message scrollToBottom:YES];
            }
        };
        
        _manager.stateBlock = ^(NSString * _Nonnull state) {
            @strongify(self)
            if ([state isEqualToString:@"connecting"]) {
                [self showEmptyViewWithLoading];
            } else if ([state isEqualToString:@"open"]) {
                [self hideEmptyView];
            } else {
                [self showEmptyViewWithText:[state isEqualToString:@"error"] ? @"连结失败" : @"连结关闭" detailText:nil buttonTitle:@"重新连接" buttonAction:@selector(connect)];
            }
        };
    }
    return _manager;
}
 
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PCNewChatTextMessageCell class] forCellReuseIdentifier:@"PCNewChatTextMessageCell"];
        [_tableView registerClass:[PCNewChatImageMessageCell class] forCellReuseIdentifier:@"PCNewChatImageMessageCell"];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        @weakify(self);
        _tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            @strongify(self);
            if (self.localMessageArray.count) {
                NSArray *msgArray = nil;
                if (self.localMessageArray.count > 20) {
                    msgArray = [self.localMessageArray subarrayWithRange:NSMakeRange(self.localMessageArray.count - 20, 20)];
                    [self.localMessageArray removeObjectsInArray:msgArray];
                } else {
                    msgArray = self.localMessageArray.copy;
                    [self.localMessageArray removeAllObjects];
                }
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [msgArray count])];
                [self.messageArray insertObjects:msgArray atIndexes:indexes];
                [self.tableView reloadData];
            }
            [self.tableView.mj_header endRefreshing];
        }];
    }
    return _tableView;
}

- (NSMutableArray<PCUser *> *)atArray {
    if (!_atArray) {
        _atArray = [NSMutableArray array];
    }
    return _atArray;
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

- (NSInteger)chatRecordNum {
    return 0;
//    return [[PCChatMessage aggregate:@"count(*)" where:nil arguments:nil] integerValue];
}

- (NSMutableArray *)localMessageArray {
    return nil;
//    if (!_localMessageArray) {
//        NSInteger chatRecordNum = [self chatRecordNum];
//        if (chatRecordNum > 10000) {
//            chatRecordNum = 10000;
//        }
//        _localMessageArray = [[PCChatMessage objectsWhere:@"ORDER BY time LIMIT 0,?" arguments:@[@(chatRecordNum)]] mutableCopy];
//    }
//    return _localMessageArray;
}

- (UIView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[UIView alloc] init];
        _toolbarView.qmui_borderColor = UIColorSeparator;
        _toolbarView.qmui_borderPosition = QMUIViewBorderPositionTop;
    }
    return _toolbarView;
}

- (QMUITextView *)textView {
    if (!_textView) {
        _textView = [[QMUITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _textView.delegate = self;
        _textView.textContainerInset = UIEdgeInsetsMake(8, 15, 8, 15);
        _textView.backgroundColor = UIColorWhite;
        _textView.font = UIFontMake(14);
        _textView.textColor = UIColorBlack;
        _textView.layer.borderColor = UIColorSeparator.CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.cornerRadius = 18;
        _textView.layer.masksToBounds = YES;
        _textView.returnKeyType = UIReturnKeySend;
        @weakify(self)
        _textView.qmui_keyboardWillChangeFrameNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            @strongify(self)
            [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
                [self showKeyboardWithUserInfo:keyboardUserInfo];
            } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
                [self hideKeyboardWithUserInfo:keyboardUserInfo];
            }];
        };
    }
    return _textView;
}

- (QMUIButton *)imageButton {
    if (!_imageButton) {
        _imageButton = [[QMUIButton alloc] init];
        _imageButton.qmui_outsideEdge = UIEdgeInsetsMake(-5, -5, -5, -5);
        [_imageButton setImage:[UIImage pc_iconWithText:ICON_PICTURE size:20 color:UIColorBlue] forState:UIControlStateNormal];
        [_imageButton addTarget:self action:@selector(pictureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        if (@available(iOS 13.0, *)) {
            _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    }
    return _imagePickerController;
}

- (QMUIButton *)replyButton {
    if (!_replyButton) {
        _replyButton = [[QMUIButton alloc] init];
        _replyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _replyButton.titleLabel.font = UIFontBoldMake(15);
        _replyButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_replyButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _replyButton.backgroundColor = PCColorPink;
        _replyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        @weakify(self)
        _replyButton.qmui_tapBlock = ^(__kindof UIControl *sender) {
            @strongify(self)
            self.replyMessage = nil;
        };
    }
    return _replyButton;
}

- (PCNewChatMentionView *)mentionView {
    if (!_mentionView) {
        _mentionView = [[PCNewChatMentionView alloc] init];
        @weakify(self)
        _mentionView.removeBlock = ^(PCUser * _Nonnull user) {
            @strongify(self)
            [self.atArray removeObject:user];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        };
    }
    return _mentionView;
}

#pragma mark - Set
- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    CGPoint offset = CGPointZero;
    if (keyboardHeight == 0) {
        //隐藏键盘 或 表情 或 相册
        offset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - _keyboardHeight + SafeAreaInsetsConstantForDeviceWithNotch.bottom);
    } else {
        //显示键盘
        if (_keyboardHeight == 0) {
            offset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y  + keyboardHeight - SafeAreaInsetsConstantForDeviceWithNotch.bottom);
        } else if (_keyboardHeight != keyboardHeight) {
            offset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + (keyboardHeight - _keyboardHeight));
        } else {
            offset = self.tableView.contentOffset;
        }
    }
    
    self.tableView.contentOffset = offset;
    
    _keyboardHeight = keyboardHeight;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)setReplyMessage:(PCNewChatMessage *)replyMessage {
    _replyMessage = replyMessage;
    if (replyMessage) {
        [self.replyButton setTitle:[NSString stringWithFormat:@"回复 %@:%@", replyMessage.profile.name, replyMessage.message ? replyMessage.message : @"图片"] forState:UIControlStateNormal];
    } else {
        [self.replyButton setTitle:@"" forState:UIControlStateNormal];
    }
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}
 
@end
