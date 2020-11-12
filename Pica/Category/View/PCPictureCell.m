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
    
    self.titleLabel.text = picture.media.originalName;
    self.imageView.image = nil;
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:picture.media.imageURL]
                                                options:kNilOptions
                                               progress:nil
                                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            self.imageView.image = image;
            picture.picture = image;
            self.titleLabel.text = nil;
            !self.loadBlock ? : self.loadBlock(image);
        }
    }];
}

#pragma mark - QMUIZoomImageViewDelegate
- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    !self.clickBlock ? : self.clickBlock();
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
        _imageView.delegate = self;
    }
    return _imageView;
}

@end
