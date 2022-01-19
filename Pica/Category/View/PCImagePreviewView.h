//
//  PCImagePreviewView.h
//  Pica
//
//  Created by Fancy on 2022/1/19.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCImagePreviewView : UIView

@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UIView       *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, copy) void (^tapBlock)(void);
@property (nonatomic, copy) void (^longPressBlock)(void);

- (void)recover;

@end

NS_ASSUME_NONNULL_END
