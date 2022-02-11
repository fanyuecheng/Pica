//
//  PCChatViewController.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatViewController.h"
#import "PCChatManager.h"
#import "PCRecordView.h"
#import "PCTextMessageCell.h"
#import "PCImageMessageCell.h"
#import "PCVoiceMessageCell.h"
#import "PCMessageNotificationView.h"
#import "PCUser.h"
#import "PCChatMessage.h"
#import "UIImage+PCAdd.h"
#import "PCOrderListController.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat const kChatBarTextViewBottomOffset = 10;
static CGFloat const kChatBarTextViewMinHeight = 37.f;
static CGFloat const kChatBarTextViewMaxHeight = 102.f;

@interface PCChatViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, QMUITextViewDelegate>

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) PCChatManager *manager;
@property (nonatomic, strong) PCChatMessage *replyMessage;
@property (nonatomic, strong) PCUser        *atUser;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QMUIButton   *replyButton;
@property (nonatomic, strong) UIView       *toolbarView;
@property (nonatomic, strong) QMUITextView *textView;
@property (nonatomic, strong) QMUIButton   *imageButton;
@property (nonatomic, strong) QMUIButton   *voiceButton;
@property (nonatomic, strong) QMUIButton   *recordButton;
@property (nonatomic, strong) PCRecordView *recordView;
@property (nonatomic, copy)   NSString     *cacheText;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSDate       *recordStartTime;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer         *recordTimer;

@property (nonatomic, assign) CGFloat        textViewHeight;
@property (nonatomic, assign) CGFloat        keyboardHeight;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic, strong) NSMutableArray *localMessageArray;

@property (nonatomic, strong) QMUIModalPresentationViewController *modalController;

@end

@implementation PCChatViewController

- (void)dealloc {
    [self.manager disconnect];
}

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
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
    [self.view addSubview:self.toolbarView];
    
    [self.toolbarView addSubview:self.voiceButton];
    [self.toolbarView addSubview:self.textView];
    [self.toolbarView addSubview:self.recordButton];
    [self.toolbarView addSubview:self.imageButton];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.titleView.style = QMUINavigationTitleViewStyleSubTitleVertical;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"指令" target:self action:@selector(orderAction:)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat naviBottom = self.qmui_navigationBarMaxYInViewCoordinator;
    CGFloat safeAreaBottom = SafeAreaInsetsConstantForDeviceWithNotch.bottom;
    
    CGFloat toolbarBottom = self.keyboardHeight ? self.keyboardHeight : 0;
    CGFloat toolbarHeight = self.textViewHeight + kChatBarTextViewBottomOffset * 2 + (self.keyboardHeight ? 0 : safeAreaBottom);
    self.toolbarView.frame = CGRectMake(0, SCREEN_HEIGHT - toolbarBottom - toolbarHeight, SCREEN_WIDTH, toolbarHeight);
    self.textView.frame = CGRectMake(57, kChatBarTextViewBottomOffset, SCREEN_WIDTH - kChatBarTextViewBottomOffset * 2 - kChatBarTextViewMinHeight - 57, self.textViewHeight);
    self.recordButton.frame = self.textView.frame;
    self.imageButton.frame = CGRectMake(SCREEN_WIDTH - kChatBarTextViewMinHeight - 10, self.textView.qmui_bottom - kChatBarTextViewMinHeight, kChatBarTextViewMinHeight, kChatBarTextViewMinHeight);
    self.voiceButton.frame = CGRectMake(kChatBarTextViewBottomOffset, self.textView.qmui_bottom - kChatBarTextViewMinHeight, kChatBarTextViewMinHeight, kChatBarTextViewMinHeight); 
    self.replyButton.frame = self.replyMessage ? CGRectMake(0, self.toolbarView.qmui_top - 44, SCREEN_WIDTH, 44) : CGRectZero;
 
    self.tableView.frame = CGRectMake(0, naviBottom, SCREEN_WIDTH, self.toolbarView.qmui_top - naviBottom - (self.replyMessage ? 44 : 0));
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
    PCChatMessage *message = self.messageArray[indexPath.row];
    PCChatMessageCell *cell = nil;
    @weakify(self)
    if (message.messageType == PCChatMessageTypeDefault) {
        PCTextMessageCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"PCTextMessageCell" forIndexPath:indexPath];
        textCell.message = message;
        @weakify(self)
        textCell.privateBlock = ^(PCChatMessage * _Nonnull msg) {
            @strongify(self)
            self.atUser = [self atUserWithId:msg.user_id name:msg.name];
            self.textView.text = [NSString stringWithFormat:@"%@@%@ %@", self.textView.text, msg.name, @"@悄悄话"];
        };
        textCell.replayBlock = ^(PCChatMessage * _Nonnull msg) {
            @strongify(self)
            self.replyMessage = msg;
        };
        
        cell = textCell;
    } else if (message.messageType == PCChatMessageTypeImage) {
        PCImageMessageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"PCImageMessageCell" forIndexPath:indexPath];
        imageCell.message = message;
        cell = imageCell;
    } else if (message.messageType == PCChatMessageTypeAudio) {
        PCVoiceMessageCell *voiceCell = [tableView dequeueReusableCellWithIdentifier:@"PCVoiceMessageCell" forIndexPath:indexPath];
        voiceCell.message = message;
        cell = voiceCell;
    }
    
    cell.atBlock = ^(PCChatMessage * _Nonnull msg) {
        @strongify(self)
        self.atUser = [self atUserWithId:nil name:msg.name];
        self.textView.text = [NSString stringWithFormat:@"%@@%@ ", self.textView.text, msg.name];
    };
    
    if (cell) {
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCChatMessage *message = self.messageArray[indexPath.row];
    if (message.messageType == PCChatMessageTypeDefault) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCTextMessageCell" configuration:^(PCTextMessageCell *cell) {
            cell.message = message;
        }];
    } else if (message.messageType == PCChatMessageTypeImage) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCImageMessageCell" configuration:^(PCImageMessageCell *cell) {
            cell.message = message;
        }];
    } else if (message.messageType == PCChatMessageTypeAudio) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCVoiceMessageCell" configuration:^(PCVoiceMessageCell *cell) {
            cell.message = message;
        }];
    }
    return 0;
}

#pragma mark - Action
- (void)orderAction:(id)sender {
    PCOrderListController *orderList = [[PCOrderListController alloc] init];
    @weakify(self)
    orderList.orderBlock = ^(NSString * _Nonnull order) {
        @strongify(self)
        self.textView.text = order;
        [self.modalController hideWithAnimated:YES completion:nil];
    };
    
    QMUIModalPresentationViewController *modalController = [[QMUIModalPresentationViewController alloc] init];
    modalController.contentViewController = orderList;
    modalController.contentViewMargins = UIEdgeInsetsZero;
    modalController.maximumContentViewWidth = SCREEN_WIDTH;
    
    @weakify(modalController)
    modalController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        @strongify(modalController)
        modalController.contentView.qmui_frameApplyTransform = CGRectSetY(contentViewDefaultFrame, CGRectGetHeight(containerBounds) - modalController.contentViewMargins.bottom - CGRectGetHeight(contentViewDefaultFrame) - (keyboardHeight ? 0 : modalController.view.safeAreaInsets.bottom) - keyboardHeight);
    };
    
    modalController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        @strongify(modalController)
        dimmingView.alpha = 0;
        modalController.contentView.frame = CGRectSetY(contentViewFrame, CGRectGetHeight(containerBounds));
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^(void) {
            dimmingView.alpha = 1;
            modalController.contentView.frame = CGRectSetY(contentViewFrame, contentViewFrame.origin.y - keyboardHeight);
        } completion:^(BOOL finished) {
            !completion ? : completion(finished);
        }];
    };
    
    modalController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        @strongify(modalController)
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^(void) {
            dimmingView.alpha = 0;
            modalController.contentView.frame = CGRectSetY(modalController.contentView.frame, CGRectGetHeight(containerBounds));
        } completion:^(BOOL finished) {
            !completion ? : completion(finished);
        }];
    };

    [modalController showWithAnimated:YES completion:nil];
    self.modalController = modalController;
}

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

- (void)clickVoiceBtn:(QMUIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        self.recordButton.hidden = NO;
        self.textView.hidden = YES;
        self.cacheText = self.textView.text;
        self.textView.text = @"";
        [self.textView resignFirstResponder];
    } else {
        self.recordButton.hidden = YES;
        self.textView.hidden = NO;
        self.textView.text = self.cacheText;
        [self.textView becomeFirstResponder];
    }
}

- (void)recordBtnDown:(UIButton *)sender {
    AVAudioSessionRecordPermission permission = AVAudioSession.sharedInstance.recordPermission;
    //在此添加新的判定 undetermined，否则新安装后的第一次询问会出错。新安装后的第一次询问为 undetermined，而非 denied。
    if (permission == AVAudioSessionRecordPermissionDenied || permission == AVAudioSessionRecordPermissionUndetermined) {
        [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
            if (!granted) {
                QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"去开启" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
                    UIApplication *app = [UIApplication sharedApplication];
                    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([app canOpenURL:settingsURL]) {
                        [app openURL:settingsURL options:@{} completionHandler:nil];
                    }
                }];
                
                QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"以后再说" style:QMUIAlertActionStyleCancel handler:nil];
                
                QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"无法访问麦克风" message:@"开启麦克风权限才能发送语音消息" preferredStyle:QMUIAlertControllerStyleAlert];
                
                [alertController addAction:action1];
                [alertController addAction:action2];
                 
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertController showWithAnimated:YES];
                });
            }
        }];
        return;
    }
    //在此包一层判断，添加一层保护措施。
    if (permission == AVAudioSessionRecordPermissionGranted){
        if(!_recordView){
            _recordView = [[PCRecordView alloc] init];
            _recordView.frame = [UIScreen mainScreen].bounds;
        }
        [self.view.window addSubview:_recordView];
        _recordStartTime = [NSDate date];
        [_recordView setStatus:PCVoiceRecordStatusRecording];
        _recordButton.backgroundColor = [UIColor lightGrayColor];
        [_recordButton setTitle:@"松开 结束" forState:UIControlStateNormal];
        [self startRecord];
    }
}

- (void)recordBtnUp:(UIButton *)sender {
    if (AVAudioSession.sharedInstance.recordPermission == AVAudioSessionRecordPermissionDenied) {
        return;
    }
    _recordButton.backgroundColor = [UIColor clearColor];
    [_recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_recordStartTime];
    if (interval < 1 || interval > 60) {
        if (interval < 1){
            [_recordView setStatus:PCVoiceRecordStatusTooShort];
        } else{
            [_recordView setStatus:PCVoiceRecordStatusTooLong];
        }
        [self cancelRecord];
        __weak typeof(self) ws = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.recordView removeFromSuperview];
        });
    } else {
        [_recordView removeFromSuperview];
        NSString *path = [self stopRecord];
        _recordView = nil;
        if (path) {
            PCChatMessage *message = [self.manager sendAudio:path];
            if (message) {
                [self insertMessage:message scrollToBottom:YES];
            }
        }
    }
}

- (void)recordBtnCancel:(UIButton *)sender {
    [_recordView removeFromSuperview];
    _recordButton.backgroundColor = UIColorClear;
    [_recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self cancelRecord];
}

- (void)recordBtnExit:(UIButton *)sender {
    [_recordView setStatus:PCVoiceRecordStatusCancel];
    [_recordButton setTitle:@"松开 取消" forState:UIControlStateNormal];
}

- (void)recordBtnEnter:(UIButton *)sender {
    [_recordView setStatus:PCVoiceRecordStatusRecording];
    [_recordButton setTitle:@"松开 结束" forState:UIControlStateNormal];
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

- (void)insertMessage:(PCChatMessage *)message scrollToBottom:(BOOL)scroll {
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

- (PCUser *)atUserWithId:(NSString *)userId
                    name:(NSString *)name {
    PCUser *user = [[PCUser alloc] init];
    user.userId = userId;
    user.name = name;
    return user;
}

#pragma mark - Record
- (void)startRecord {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive:YES error:&error];

    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];

    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"PC_AUDIO"];
    if (![kDefaultFileManager fileExistsAtPath:cachePath]) {
        [kDefaultFileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", @([[NSDate date] timeIntervalSince1970])]];
    NSURL *url = [NSURL fileURLWithPath:path];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder record];
    [_recorder updateMeters];

    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordTick:) userInfo:nil repeats:YES];
}

- (void)recordTick:(NSTimer *)timer{
    [_recorder updateMeters];
    float power = [_recorder averagePowerForChannel:0];
    [_recordView setPower:power];
    
    //在此处添加一个时长判定，如果时长超过60s，则取消录制，提示时间过长,同时不再显示 recordView。
    //此处使用 recorder 的属性，使得录音结果尽量精准。注意：由于语音的时长为整形，所以 60.X 秒的情况会被向下取整。但因为 ticker 0.5秒执行一次，所以因该都会在超时时显示为60s
    NSTimeInterval interval = _recorder.currentTime;
    if (interval >= 55 && interval < 60) {
        NSInteger seconds = 60 - interval;
        //此处加long，是为了消除编译器警告。此处 +1 是为了向上取整，优化时间逻辑。
        NSString *secondsString = [NSString stringWithFormat:@"将在 %ld 秒后结束录制", (long)seconds + 1];
        _recordView.titleLabel.text = secondsString;
    }
    if (interval >= 60) {
        NSString *path = [self stopRecord];
        [_recordView setStatus:PCVoiceRecordStatusTooLong];
        __weak typeof(self) ws = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.recordView removeFromSuperview];
        });
        if (path) {
            PCChatMessage *message = [self.manager sendAudio:path];
            if (message) {
                [self insertMessage:message scrollToBottom:YES];
            }
        }
    }
}

- (NSString *)stopRecord {
    if (_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    return _recorder.url.path;
}

- (void)cancelRecord {
    if (_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    NSString *path = _recorder.url.path;
    if ([kDefaultFileManager fileExistsAtPath:path]) {
        [kDefaultFileManager removeItemAtPath:path error:nil];
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
        textView.text = @"";
        PCChatMessage *message = [self.manager sendText:text replyMessage:self.replyMessage at:self.atUser];
        if (message) {
            [self insertMessage:message scrollToBottom:YES];
        }
        self.replyMessage = nil;
        self.atUser = nil;
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
                        
                        self.atUser = nil;
                        
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
    PCChatMessage *message = [self.manager sendImage:data];
    if (message) {
        [self insertMessage:message scrollToBottom:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Get
- (PCChatManager *)manager {
    if (!_manager) {
        _manager = [[PCChatManager alloc] initWithURL:self.url];
         
        @weakify(self)
        _manager.messageBlock = ^(PCChatMessage * _Nonnull message) {
            @strongify(self)
            if (message) {
                if (message.messageType == PCChatMessageTypeDefault || message.messageType == PCChatMessageTypeImage ||
                    message.messageType == PCChatMessageTypeAudio) {
                    [self insertMessage:message scrollToBottom:YES];
                } else if (message.messageType == PCChatMessageTypeConnectionCount && self.navigationController.topViewController == self) { 
                    self.titleView.subtitle = [NSString stringWithFormat:@"在线人数:%@", @(message.connections)];
                } else if (message.messageType == PCChatMessageTypeNotification && self.navigationController.topViewController == self) {
                    [PCMessageNotificationView showWithMessage:message.message animated:YES];
                }
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
        [_tableView registerClass:[PCTextMessageCell class] forCellReuseIdentifier:@"PCTextMessageCell"];
        [_tableView registerClass:[PCImageMessageCell class] forCellReuseIdentifier:@"PCImageMessageCell"];
        [_tableView registerClass:[PCVoiceMessageCell class] forCellReuseIdentifier:@"PCVoiceMessageCell"];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        @weakify(self);
        _tableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            @strongify(self);
            if (self.localMessageArray.count) {
                NSArray *msgArray = nil;
                if (self.localMessageArray.count > 20) {
                    msgArray = [self.localMessageArray subarrayWithRange:NSMakeRange(self.localMessageArray.count - 21, 20)];
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

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

- (NSInteger)chatRecordNum {
    return [[PCChatMessage aggregate:@"count(*)" where:nil arguments:nil] integerValue];
}

- (NSMutableArray *)localMessageArray {
    if (!_localMessageArray) {
        NSInteger chatRecordNum = [self chatRecordNum];
        if (chatRecordNum > 10000) {
            chatRecordNum = 10000;
        }
        _localMessageArray = [[PCChatMessage objectsWhere:@"ORDER BY time LIMIT 0,?" arguments:@[@(chatRecordNum)]] mutableCopy];
    }
    return _localMessageArray;
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

- (QMUIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[QMUIButton alloc] init];
        [_voiceButton addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceButton setImage:[UIImage pc_iconWithText:ICON_SOUND_PLAY size:15 color:UIColorGray] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage pc_iconWithText:ICON_SOUND_PLAY size:15 color:UIColorBlue] forState:UIControlStateSelected];
    }
    return _voiceButton;
}
 
- (QMUIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[QMUIButton alloc] init];
        [_recordButton.titleLabel setFont:UIFontMake(15)];
        [_recordButton.layer setMasksToBounds:YES];
        [_recordButton.layer setCornerRadius:18];
        [_recordButton.layer setBorderWidth:0.5f];
        [_recordButton.layer setBorderColor:UIColorMakeWithRGBA(188, 188, 188, 0.6).CGColor];
        [_recordButton addTarget:self action:@selector(recordBtnDown:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recordBtnUp:) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(recordBtnCancel:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [_recordButton addTarget:self action:@selector(recordBtnExit:) forControlEvents:UIControlEventTouchDragExit];
        [_recordButton addTarget:self action:@selector(recordBtnEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [_recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_recordButton setTitleColor:UIColorBlack forState:UIControlStateNormal];
        _recordButton.hidden = YES;
    }
    return _recordButton;
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

- (void)setReplyMessage:(PCChatMessage *)replyMessage {
    _replyMessage = replyMessage;
    if (replyMessage) {
        [self.replyButton setTitle:[NSString stringWithFormat:@"回复 %@:%@", replyMessage.name, replyMessage.message] forState:UIControlStateNormal];
    } else {
        [self.replyButton setTitle:@"" forState:UIControlStateNormal];
    }
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

@end
