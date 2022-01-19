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
#import "PCImagePreviewView.h"

@interface PCPictureCell ()

@property (nonatomic, strong) QMUILabel          *titleLabel;
@property (nonatomic, strong) PCImagePreviewView *imageView;

@end

@implementation PCPictureCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    [self.picture cancelLoadImage];
    self.imageView.imageView.image = nil;
    [self.imageView recover];
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
        self.imageView.imageView.image = picture.image;
    } else {
        self.titleLabel.text = picture.media.originalName;
        self.imageView.imageView.image = nil;
        @weakify(self)
        [picture loadImage:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
            @strongify(self)
            if (image) {
                self.titleLabel.text = nil;
                self.imageView.imageView.image = image;
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
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.picture.media.imageURL]];
        NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:cacheKey];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            QMUISaveImageAtPathToSavedPhotosAlbumWithAlbumAssetsGroup(path, nil, ^(QMUIAsset *asset, NSError *error) {
                if (asset) {
                    [QMUITips showSucceed:@"图片已保存到相册"];
                }
            });
        }
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

- (PCImagePreviewView *)imageView {
    if (!_imageView) {
        _imageView = [[PCImagePreviewView alloc] init];
        @weakify(self)
        _imageView.tapBlock = ^{
            @strongify(self)
            !self.clickBlock ? : self.clickBlock();
        };
        _imageView.longPressBlock = ^{
            @strongify(self)
            [self showSaveAlert];
        };
    }
    return _imageView;
}

@end
