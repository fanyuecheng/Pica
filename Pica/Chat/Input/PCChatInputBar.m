//
//  PCChatInputBar.m
//  Pica
//
//  Created by Fancy on 2021/6/18.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatInputBar.h"
#import "PCRecordView.h"
#import "PCVendorHeader.h"
#import "UIImage+PCAdd.h"
#import <AVFoundation/AVFoundation.h>

#define PCTextView_Height (49)
#define PCTextView_Button_Size CGSizeMake(30, 30)
#define PCTextView_Margin 6
#define PCTextView_TextView_Height_Min (PCTextView_Height - 2 * PCTextView_Margin)
#define PCTextView_TextView_Height_Max 80

@interface PCChatInputBar() <QMUITextViewDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) PCRecordView *recordView;
@property (nonatomic, strong) NSDate       *recordStartTime;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer         *recordTimer;

@end

@implementation PCChatInputBar

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self setupViews];
    [self defaultLayout];
}

- (void)setupViews {
    self.backgroundColor = UIColorMakeWithRGBA(246, 246, 246, 1.0);

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = UIColorMakeWithRGBA(188, 188, 188, 0.6);
    [self addSubview:_lineView];

    _micButton = [[QMUIButton alloc] init];
    [_micButton addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_micButton setImage:[UIImage pc_iconWithText:ICON_SOUND_PLAY size:15 color:UIColorGray] forState:UIControlStateNormal];
    [_micButton setImage:[UIImage pc_iconWithText:ICON_SOUND_PLAY size:15 color:UIColorBlue] forState:UIControlStateSelected];
    [self addSubview:_micButton];

    _picButton = [[QMUIButton alloc] init];
    [_picButton addTarget:self action:@selector(clickPicBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_picButton setImage:[UIImage pc_iconWithText:ICON_PICTURE size:15 color:UIColorBlue] forState:UIControlStateNormal];
    [self addSubview:_picButton];

    _recordButton = [[QMUIButton alloc] init];
    [_recordButton.titleLabel setFont:UIFontMake(15)];
    [_recordButton.layer setMasksToBounds:YES];
    [_recordButton.layer setCornerRadius:4.0f];
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
    [self addSubview:_recordButton];

    _inputTextView = [[QMUITextView alloc] init];
    _inputTextView.delegate = self;
    [_inputTextView setFont:UIFontMake(16)];
    [_inputTextView.layer setMasksToBounds:YES];
    [_inputTextView.layer setCornerRadius:4.0f];
    [_inputTextView.layer setBorderWidth:0.5f];
    [_inputTextView.layer setBorderColor:UIColorMakeWithRGBA(188, 188, 188, 0.6).CGColor];
    [_inputTextView setReturnKeyType:UIReturnKeySend];
    [self addSubview:_inputTextView];
}

- (void)defaultLayout {
    _lineView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.5);
    CGSize buttonSize = PCTextView_Button_Size;
    CGFloat buttonOriginY = (PCTextView_Height - buttonSize.height) * 0.5;
    _micButton.frame = CGRectMake(PCTextView_Margin, buttonOriginY, buttonSize.width, buttonSize.height);
    _picButton.frame = CGRectMake(SCREEN_WIDTH - buttonSize.width - PCTextView_Margin, buttonOriginY, buttonSize.width, buttonSize.height);

    CGFloat beginX = _micButton.frame.origin.x + _micButton.frame.size.width + PCTextView_Margin;
    CGFloat endX = _picButton.frame.origin.x - PCTextView_Margin;
    _recordButton.frame = CGRectMake(beginX, (PCTextView_Height - PCTextView_TextView_Height_Min) * 0.5, endX - beginX, PCTextView_TextView_Height_Min);
    _inputTextView.frame = _recordButton.frame;
}


- (void)layoutButton:(CGFloat)height {
    CGRect frame = self.frame;
    CGFloat offset = height - frame.size.height;
    frame.size.height = height;
    self.frame = frame;

    CGSize buttonSize = PCTextView_Button_Size;
    CGFloat bottomMargin = (PCTextView_Height - buttonSize.height) * 0.5;
    CGFloat originY = frame.size.height - buttonSize.height - bottomMargin;
 
    CGRect moreFrame = _picButton.frame;
    moreFrame.origin.y = originY;
    _picButton.frame = moreFrame;

    CGRect voiceFrame = _micButton.frame;
    voiceFrame.origin.y = originY;
    _micButton.frame = voiceFrame;

    if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didChangeInputHeight:)]){
        [_delegate inputBar:self didChangeInputHeight:offset];
    }
}

- (void)clickVoiceBtn:(UIButton *)sender {
    _recordButton.hidden = NO;
    _inputTextView.hidden = YES;
    _micButton.selected = YES;
    [_inputTextView resignFirstResponder];
    [self layoutButton:PCTextView_Height];
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchVoice:)]){
        [_delegate inputBarDidTouchVoice:self];
    }
}

- (void)clickPicBtn:(UIButton *)sender {
    _micButton.selected = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchImage:)]){
        [_delegate inputBarDidTouchImage:self];
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
        [self.window addSubview:_recordView];
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
            if (_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendVoice:)]){
                [_delegate inputBar:self didSendVoice:path];
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

#pragma mark - talk

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.micButton.selected = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [_inputTextView sizeThatFits:CGSizeMake(_inputTextView.frame.size.width, PCTextView_TextView_Height_Max)];
    CGFloat oldHeight = _inputTextView.frame.size.height;
    CGFloat newHeight = size.height;

    if (newHeight > PCTextView_TextView_Height_Max){
        newHeight = PCTextView_TextView_Height_Max;
    }
    if (newHeight < PCTextView_TextView_Height_Min){
        newHeight = PCTextView_TextView_Height_Min;
    }
    if (oldHeight == newHeight){
        return;
    }

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect textFrame = ws.inputTextView.frame;
        textFrame.size.height += newHeight - oldHeight;
        ws.inputTextView.frame = textFrame;
        [ws layoutButton:newHeight + 2 * PCTextView_Margin];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendText:)]) {
            NSString *sp = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (sp.length == 0) {
                [QMUITips showError:@"不能发送空白消息"];
            } else {
                [_delegate inputBar:self didSendText:textView.text];
                [self clearInput];
            }
        }
        return NO;
    } else if ([text isEqualToString:@""]) {
        if (textView.text.length > range.location) {
            // 一次性删除 [微笑] 这种表情消息
            if ([textView.text characterAtIndex:range.location] == ']') {
                NSUInteger location = range.location;
                NSUInteger length = range.length;
                int left = 91;     // '[' 对应的ascii码
                int right = 93;    // ']' 对应的ascii码
                while (location != 0) {
                    location --;
                    length ++ ;
                    int c = (int)[textView.text characterAtIndex:location];     // 将字符转换成ascii码，复制给int  避免越界
                    if (c == left) {
                        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                        return NO;
                    }
                    else if (c == right) {
                        return YES;
                    }
                }
            }
            // 一次性删除 @xxx 这种 @ 消息
            else if ([textView.text characterAtIndex:range.location] == ' ') {
                NSUInteger location = range.location;
                NSUInteger length = range.length;
                int at = 64;    // '@' 对应的ascii码
                while (location != 0) {
                    location --;
                    length ++ ;
                    int c = (int)[textView.text characterAtIndex:location]; // 将字符转成ascii码，复制给int,避免越界
                    if (c == at) {
                        NSString *atText = [textView.text substringWithRange:NSMakeRange(location, length)];
                        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didDeleteAt:)]) {
                            [self.delegate inputBar:self didDeleteAt:atText];
                        }
                        return NO;
                    }
                }
            }
        }
    }
    // 监听 @ 字符的输入，包含全角/半角
    else if ([text isEqualToString:@"@"] || [text isEqualToString:@"＠"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidInputAt:)]) {
            [self.delegate inputBarDidInputAt:self];
        }
    }
    return YES;
}

- (void)clearInput {
    _inputTextView.text = @"";
    [self textViewDidChange:_inputTextView];
}

- (NSString *)getInput {
    return _inputTextView.text;
}

- (void)addEmoji:(NSString *)emoji {
    [_inputTextView setText:[_inputTextView.text stringByAppendingString:emoji]];
    if (_inputTextView.contentSize.height > PCTextView_TextView_Height_Max){
        float offset = _inputTextView.contentSize.height - _inputTextView.frame.size.height;
        [_inputTextView scrollRectToVisible:CGRectMake(0, offset, _inputTextView.frame.size.width, _inputTextView.frame.size.height) animated:YES];
    }
    [self textViewDidChange:_inputTextView];
}

- (void)backDelete {
    [self textView:_inputTextView shouldChangeTextInRange:NSMakeRange(_inputTextView.text.length - 1, 1) replacementText:@""];
    [self textViewDidChange:_inputTextView];
}

- (void)updateTextViewFrame {
    [self textViewDidChange:[UITextView new]];
}

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

    NSString *path = [[NSHomeDirectory() stringByAppendingString:@"/Documents/pc_data/voice/"] stringByAppendingString:[NSString stringWithFormat:@"%@.m4a", @([[NSDate date] timeIntervalSince1970])]];
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
            if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendVoice:)]){
                [_delegate inputBar:self didSendVoice:path];
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
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
