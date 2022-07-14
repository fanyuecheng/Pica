//
//  PCPictureCell.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCPictureCell.h"
#import "PCDefineHeader.h"
#import "PCVendorHeader.h"
#import "PCImageSizeCache.h"
#import "PCZoomImageView.h"
#import "UIViewController+PCAdd.h"

@interface PCPictureCell () <PCZoomImageViewDelegate>

@property (nonatomic, strong) QMUILabel       *titleLabel;
@property (nonatomic, strong) PCZoomImageView *imageView;

@end

@implementation PCPictureCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.imageView.image = nil;
    [self.imageView revertZooming];
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
    
    BOOL needReload = ![kPCImageSizeCache containsImageSizeForKey:picture.media.imageURL];
    
    if (picture.image) {
        self.titleLabel.text = nil;
        self.imageView.image = picture.image;
    } else {
        self.titleLabel.text = picture.media.originalName;
        self.imageView.image = nil;
        @weakify(self)
        [picture loadImage:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
            @strongify(self)
            if (image) {
                self.titleLabel.text = nil;
                self.imageView.image = image;
            }
            if (needReload) {
                !self.loadBlock ? : self.loadBlock(picture);
            }
        }];
    }
}

#pragma mark - Method
- (void)showSaveAlert {
    if (self.imageView.imageView.image == nil) {
        return;
    }
    [UIViewController pc_actionSheetWithTitle:@"保存图片到相册" message:nil confirm:^{
        NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.picture.media.imageURL]];
        NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:cacheKey];
        
        if ([kDefaultFileManager fileExistsAtPath:path]) {
            QMUISaveImageAtPathToSavedPhotosAlbumWithAlbumAssetsGroup(path, nil, ^(QMUIAsset *asset, NSError *error) {
                if (asset) {
                    [QMUITips showSucceed:@"图片已保存到相册"];
                }
            });
        }
    } cancel:nil];
}

#pragma mark - PCZoomImageViewDelegate
- (void)singleTouchInZoomingImageView:(PCZoomImageView *)imageView
                             location:(CGPoint)location {
    !self.clickBlock ? : self.clickBlock();
}

- (void)longPressInZoomingImageView:(PCZoomImageView *)imageView {
    [self showSaveAlert];
}
 
#pragma mark - Get
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(40) textColor:UIColorWhite];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (PCZoomImageView *)imageView {
    if (!_imageView) {
        _imageView = [[PCZoomImageView alloc] init];
        _imageView.delegate = self;
    }
    return _imageView;
}

@end
