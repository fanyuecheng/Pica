//
//  PCZoomImageView.h
//  Pica
//
//  Created by Fancy on 2022/7/14.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PCZoomImageView;
@protocol PCZoomImageViewDelegate <NSObject>

@optional
- (void)singleTouchInZoomingImageView:(PCZoomImageView *)imageView
                             location:(CGPoint)location;
- (void)doubleTouchInZoomingImageView:(PCZoomImageView *)imageView
                             location:(CGPoint)location;
- (void)longPressInZoomingImageView:(PCZoomImageView *)imageView;
- (BOOL)enabledZoomViewInZoomImageView:(PCZoomImageView *)imageView;

@end

@interface PCZoomImageView : UIView  <UIScrollViewDelegate>

@property (nonatomic, weak) id <PCZoomImageViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) CGRect viewportRect;

@property (nonatomic, assign) CGFloat maximumZoomScale;

@property (nonatomic, weak) UIImage *image;
 
@property (nonatomic, strong, readonly) UIImageView *imageView;

@property(nonatomic, weak, readonly) __kindof UIView *contentView;

- (CGRect)contentViewRectInZoomImageView;

- (void)revertZooming;

@end

NS_ASSUME_NONNULL_END
