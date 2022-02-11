//
//  PCVoiceMessageCell.m
//  Pica
//
//  Created by Fancy on 2021/6/17.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCVoiceMessageCell.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"
#import "PCMessageBubbleView.h"
#import "PCChatMessage.h"
#import "PCIconHeader.h"
#import "PCPopupContainerView.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>

@interface PCVoiceMessageCell ()

@property (nonatomic, strong) QMUIButton *playButton;
@property (nonatomic, strong) QMUILabel  *durationLabel;
@property (nonatomic, strong) QMUILabel  *wordLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadView;

@end

@implementation PCVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.messageContentView addSubview:self.playButton];
        [self.messageContentView addSubview:self.durationLabel];
        [self.messageContentView addSubview:self.wordLabel];
        [self.messageContentView addSubview:self.loadView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat textMaxWidth = SCREEN_WIDTH - 70 - 10 - 10 - 6;
    CGSize wordSize = self.message.audioString.length ? [self.wordLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)] : CGSizeZero;
    CGFloat maxWidth = wordSize.width < textMaxWidth ? wordSize.width : textMaxWidth;
    if (maxWidth < 116) {
        maxWidth = 116;
    }
    
    if ([self messageOwnerIsMyself]) {
        self.durationLabel.frame = CGRectMake(116 - 50, 0, 50, 50);
        self.playButton.frame = CGRectMake(6, 0, 50, 50);
        if (self.message.audioString) {
            self.wordLabel.frame = CGRectMake(6, 50, maxWidth, QMUIViewSelfSizingHeight);
            self.messageContentView.frame = CGRectMake(SCREEN_WIDTH - 70 - maxWidth - 16, self.nameLabel.qmui_bottom + 5, maxWidth + 16, 50 + self.wordLabel.qmui_height + 10);
        } else {
            self.wordLabel.frame = CGRectZero;
            self.messageContentView.frame = CGRectMake(SCREEN_WIDTH - 70 - 116, self.nameLabel.qmui_bottom + 5, 116, 50);
        }
    } else {
        self.playButton.frame = CGRectMake(10, 0, 50, 50);
        self.durationLabel.frame = CGRectMake(60, 0, 50, 50);
        if (self.message.audioString) {
            self.wordLabel.frame = CGRectMake(10, 50, maxWidth, QMUIViewSelfSizingHeight);
            self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, maxWidth + 16, 50 + self.wordLabel.qmui_height + 10);
        } else {
            self.wordLabel.frame = CGRectZero;
            self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, 116, 50);
        }
    }
    self.loadView.frame = self.playButton.frame;
    self.messageBubbleView.frame = self.messageContentView.frame;
}

- (void)setMessage:(PCChatMessage *)message {
    [super setMessage:message];
  
    self.durationLabel.text = [NSString stringWithFormat:@"%.2fs", message.audioPlayer.duration];
    self.playButton.selected = message.isPlaying;
    self.wordLabel.text = message.audioString;
    self.wordLabel.contentEdgeInsets = message.audioString ? UIEdgeInsetsMake(5, 0, 0, 0) : UIEdgeInsetsZero;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
    height += 50 + 10;
    if (self.message.audioString) {
        CGFloat textMaxWidth = SCREEN_WIDTH - 70 - 10 - 10 - 6;
        height += [self.wordLabel sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)].height + 10;
    }
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - Action
- (void)playAction:(QMUIButton *)sender {
    sender.selected = !sender.selected;
    
    if (!self.message.playStateBlock) {
        @weakify(self)
        self.message.playStateBlock = ^(BOOL isPlaying) {
            @strongify(self)
            self.playButton.selected = isPlaying;
        };
    } 
    
    if (sender.selected) {
        [self.message playVoiceMessage];
    } else {
        [self.message pauseVoiceMessage];
    }
}
 
#pragma mark - Action
- (void)menuAction:(UIControl *)sender {
    if (!self.message || self.message.audioString) {
        return;
    }
    PCPopupContainerView *popupView = [[PCPopupContainerView alloc] init];
    popupView.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionAbove;
    popupView.automaticallyHidesWhenUserTap = YES;
    popupView.sourceView = sender;
    popupView.titleArray = @[@"转文字"];
    @weakify(self)
    popupView.actionBlock = ^(PCPopupContainerView *view, NSInteger index) {
        @strongify(self)
        [self toWord];
        [view hideWithAnimated:YES];
    };
    [popupView showWithAnimated:YES];
}

- (void)toWord {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"status = %zd", status);
    }];
     
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.wav"];
    BOOL success = [self.message.audioData writeToFile:path atomically:YES];
    
    if (!success) {
        return;
    }
   
    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:[NSURL fileURLWithPath:path]];
    request.shouldReportPartialResults = NO;
    
    self.loadView.hidden = NO;
    [self.loadView startAnimating];
    self.playButton.alpha = 0;
    UITableView *tableView = self.qmui_tableView;
    @weakify(self)
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        @strongify(self)
        self.playButton.alpha = 1;
        if (result.final) {
            [kDefaultFileManager removeItemAtPath:path error:nil];
            [self.loadView stopAnimating];
            self.message.audioString = result.bestTranscription.formattedString;
            [tableView reloadData];
        } else if (error) {
            [self.loadView stopAnimating];
        }
    }];
}

#pragma mark - Get
- (QMUIButton *)playButton {
    if (!_playButton) {
        _playButton = [[QMUIButton alloc] init];
        _playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _playButton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:40];
        [_playButton setTitle:ICON_PLAY forState:UIControlStateNormal];
        [_playButton setTitle:ICON_SUSPEND forState:UIControlStateSelected];
        [_playButton setTitleColor:UIColorBlack forState:UIControlStateSelected];
        [_playButton setTitleColor:UIColorBlack forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (QMUILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
    }
    return _durationLabel;
}

- (QMUILabel *)wordLabel {
    if (!_wordLabel) {
        _wordLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
        _wordLabel.qmui_borderColor = UIColorWhite;
        _wordLabel.qmui_borderPosition = QMUIViewBorderPositionTop;
        _wordLabel.numberOfLines = 0;
    }
    return _wordLabel;
}

- (UIActivityIndicatorView *)loadView {
    if (!_loadView) {
        _loadView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium size:CGSizeMake(30, 30)];
        _loadView.hidesWhenStopped = YES;
        _loadView.hidden = YES;
    }
    return _loadView;
}

@end
