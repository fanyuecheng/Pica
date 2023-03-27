//
//  PCNewChatImageMessageCell.m
//  Pica
//
//  Created by 米画师 on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatImageMessageCell.h"
#import "PCVendorHeader.h"
#import "UIViewController+PCAdd.h"
#import "UIImageView+PCAdd.h"

@interface PCNewChatImageMessageCell () <QMUIImagePreviewViewDelegate>

@property (nonatomic, strong) QMUIImagePreviewViewController *previewViewController;

@end

@implementation PCNewChatImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.messageBubbleView.hidden = YES;
        [self.messageContentView addSubview:self.messageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.message.image) {
        self.messageView.frame = CGRectMake(0, 0, 200, 200 * (self.message.image.size.height / self.message.image.size.width));
    }
    
    if ([self messageOwnerIsMyself]) {
        self.messageContentView.frame = CGRectMake(self.qmui_width - self.messageView.qmui_width - 70, self.nameLabel.qmui_bottom + 5, self.messageView.qmui_width, self.messageView.qmui_height);
    } else {
        self.messageContentView.frame = CGRectMake(70, self.nameLabel.qmui_bottom + 5, self.messageView.qmui_width, self.messageView.qmui_height);
    }
    self.messageBubbleView.frame = self.messageContentView.frame;
}

- (void)setMessage:(PCNewChatMessage *)message {
    [super setMessage:message];
    
    if (message.image) {
        self.messageView.image = message.image;
    } else {
        [self.messageView pc_setImageWithURL:message.medias.firstObject
                                   completed:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
            if (image) {
                message.image = image;
                NSIndexPath *indexPath = [self.qmui_tableView indexPathForCell:self];
                if (indexPath) {
                    [self.qmui_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } 
            }
        }];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.message.image) {
        CGFloat height = 10 + [self.levelLabel sizeThatFits:CGSizeMax].height + 5 + [self.nameLabel sizeThatFits:CGSizeMax].height + 5;
        height += 200 * (self.message.image.size.height / self.message.image.size.width) + 10;
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
    zoomImageView.image = self.message.image;
}

- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    return QMUIImagePreviewMediaTypeImage;
}
 
#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    // 退出图片预览
    [[QMUIHelper visibleViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView {
    if (zoomImageView.image == nil) {
        return;
    }
    [UIViewController pc_actionSheetWithTitle:@"保存图片到相册" message:nil confirm:^{
        QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(zoomImageView.image, nil, ^(QMUIAsset *asset, NSError *error) {
            if (asset) {
                [QMUITips showSucceed:@"已保存到相册"];
            }
        });
    } cancel:nil];
}

@end
