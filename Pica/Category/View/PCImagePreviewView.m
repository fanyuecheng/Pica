//
//  PCImagePreviewView.m
//  Pica
//
//  Created by Fancy on 2022/1/19.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCImagePreviewView.h"
#import "PCVendorHeader.h"

@interface PCImagePreviewView () <UIScrollViewDelegate>

@end

@implementation PCImagePreviewView

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
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.imageView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
    UILongPressGestureRecognizer *tap3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:tap3];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    [self recover];
}

#pragma mark - Method
- (void)recover {
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    self.containerView.frame = CGRectMake(0, 0, self.scrollView.qmui_width, self.containerView.qmui_height);

    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.qmui_height / self.scrollView.qmui_width) {
        CGFloat width = image.size.width / image.size.height * self.scrollView.qmui_height;
        if (width < 1 || isnan(width)) width = self.qmui_width;
        width = floor(width);
        
        self.containerView.frame = CGRectSetSize(self.containerView.frame, CGSizeMake(width, self.qmui_height));
        self.containerView.center = CGPointMake(self.scrollView.qmui_width / 2, self.containerView.center.y);
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.qmui_width;
        if (height < 1 || isnan(height)) height = self.qmui_height;
        height = floor(height);
        self.containerView.qmui_height = height;
        self.containerView.center = CGPointMake(self.containerView.center.x, self.qmui_height / 2);
    }
    if (self.containerView.qmui_height > self.qmui_height && self.containerView.qmui_height - self.qmui_height <= 1) {
        self.containerView.qmui_height = self.qmui_height;
    }
    CGFloat contentSizeH = MAX(self.containerView.qmui_height, self.qmui_height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.qmui_width, contentSizeH);
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.containerView.qmui_height <= self.qmui_height ? NO : YES;
    self.imageView.frame = self.containerView.bounds;
}

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (self.scrollView.qmui_width > self.scrollView.contentSize.width) ? ((self.scrollView.qmui_width - self.scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.qmui_height > self.scrollView.contentSize.height) ? ((self.scrollView.qmui_height - self.scrollView.contentSize.height) * 0.5) : 0.0;
    self.containerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Action
- (void)doubleTapAction:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTapAction:(UITapGestureRecognizer *)tap {
    !self.tapBlock ? : self.tapBlock();
}

- (void)longPressAction:(UILongPressGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateBegan) {
        !self.longPressBlock ? : self.longPressBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Get
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        if (@available(iOS 11, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.clipsToBounds = YES;
        _containerView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _containerView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
