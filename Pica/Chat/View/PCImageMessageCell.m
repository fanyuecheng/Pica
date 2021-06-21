//
//  PCImageMessageCell.m
//  Pica
//
//  Created by Fancy on 2021/6/16.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCImageMessageCell.h"
#import "PCVendorHeader.h"
#import "PCChatMessage.h"
#import "PCMessageBubbleView.h"

@interface PCImageMessageCell () <QMUIImagePreviewViewDelegate>

@property (nonatomic, strong) QMUIImagePreviewViewController *previewViewController;

@end

@implementation PCImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.messageBubbleView.hidden = YES;
        [self.messageContentView addSubview:self.messageView]; 
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.message.picture) {
        self.messageView.frame = CGRectMake(0, 0, 200, 200 * (self.message.picture.size.height / self.message.picture.size.width));
    }
    
    if ([self messageOwnerIsMyself]) {
        self.messageContentView.frame = CGRectMake(self.qmui_width - self.messageView.qmui_width - 70, self.nameLabel.qmui_bottom + 5, self.messageView.qmui_width, self.messageView.qmui_height);
    } else {
        self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, self.messageView.qmui_width, self.messageView.qmui_height);
    }
    self.messageBubbleView.frame = self.messageContentView.frame;  
}

- (void)setMessage:(PCChatMessage *)message {
    [super setMessage:message];
    
    self.messageView.image = message.picture;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.message.picture) {
        CGFloat height = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
        height += 200 * (self.message.picture.size.height / self.message.picture.size.width) + 10;
        return CGSizeMake(SCREEN_WIDTH, height);
    } else {
        return CGSizeMake(SCREEN_WIDTH, 200);
    }
}

#pragma mark - Get
- (UIImageView *)messageView {
    if (!_messageView) {
        _messageView = [[SDAnimatedImageView alloc] init];
        _messageView.layer.cornerRadius = 4;
        _messageView.layer.masksToBounds = YES;
        _messageView.userInteractionEnabled = YES;
        [_messageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePreviewAction:)]];
    }
    return _messageView;
}

#pragma mark - Action
- (void)imagePreviewAction:(UITapGestureRecognizer *)sender {
    if (!self.previewViewController) {
        self.previewViewController = [[QMUIImagePreviewViewController alloc] init];
        self.previewViewController.presentingStyle = QMUIImagePreviewViewControllerTransitioningStyleZoom;
        self.previewViewController.imagePreviewView.delegate = self;
    }
    self.previewViewController.sourceImageView = ^UIView *{
        return sender.view;
    };
    
    [[QMUIHelper visibleViewController] presentViewController:self.previewViewController animated:YES completion:nil];
}

#pragma mark - QMUIImagePreviewViewDelegate
- (NSUInteger)numberOfImagesInImagePreviewView:(QMUIImagePreviewView *)imagePreviewView {
    return 1;
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    zoomImageView.reusedIdentifier = @(index);
    zoomImageView.image = self.message.picture;
}

- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    return QMUIImagePreviewMediaTypeImage;
}
 
#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    // 退出图片预览
    [[QMUIHelper visibleViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
