//
//  PCPictureCell.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCPictureCell.h"
#import "PCVendorHeader.h"

@interface PCPictureCell () <QMUIZoomImageViewDelegate>

@property (nonatomic, strong) QMUILabel         *titleLabel;
@property (nonatomic, strong) QMUIZoomImageView *imageView;

@end

@implementation PCPictureCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = self.contentView.bounds;
    self.imageView.frame = self.contentView.bounds;
}

- (void)setPicture:(PCPicture *)picture {
    _picture = picture;
     
    if (picture.image) {
        self.imageView.image = picture.image;
        self.titleLabel.text = nil;
    } else {
        self.imageView.image = nil;
        self.titleLabel.text = picture.media.originalName;
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:picture.media.imageURL]
                                                    options:kNilOptions
                                                   progress:nil
                                                  completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                picture.image = image;
                !self.loadBlock ? : self.loadBlock(picture);
            }
        }];
    }
}

#pragma mark - QMUIZoomImageViewDelegate
- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    !self.clickBlock ? : self.clickBlock();
}

- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView {
    if (zoomImageView.image == nil) {
        return;
    }
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(zoomImageView.image, nil, ^(QMUIAsset *asset, NSError *error) {
            if (asset) {
                [QMUITips showSucceed:@"已保存到相册"];
            }
        });
    }];
  
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"保存图片到相册" message:nil preferredStyle:QMUIAlertControllerStyleActionSheet];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

#pragma mark - Get
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(40) textColor:UIColorWhite];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (QMUIZoomImageView *)imageView {
    if (!_imageView) {
        _imageView = [[QMUIZoomImageView alloc] init];
        SDAnimatedImageView *contentView = [[SDAnimatedImageView alloc] init];
        [_imageView setValue:contentView forKey:@"_imageView"];
        [_imageView.scrollView addSubview:contentView];
        _imageView.delegate = self;
    }
    return _imageView;
}

@end
