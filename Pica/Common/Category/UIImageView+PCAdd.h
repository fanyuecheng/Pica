//
//  UIImageView+PCAdd.h
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (PCAdd)

- (void)pc_setImageWithURL:(NSString *)url;

- (void)pc_setImageWithURL:(NSString *)url
          placeholderImage:(nullable UIImage *)placeholderImage;

- (void)pc_setImageWithURL:(NSString *)url
                 completed:(nullable void (^)(UIImage *image, NSError *error))completed;

- (void)pc_setImageWithURL:(NSString *)url
          placeholderImage:(nullable UIImage *)placeholderImage
                 completed:(nullable void (^)(UIImage *image, NSError *error))completed;

- (void)pc_setImageWithURL:(NSString *)url
          placeholderImage:(nullable UIImage *)placeholderImage
                  progress:(nullable void (^)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL))progress
                 completed:(nullable void (^)(UIImage *image, NSError *error))completed;

- (void)pc_setImageWithURL:(NSString *)url
          placeholderImage:(nullable UIImage *)placeholderImage
                   options:(SDWebImageOptions)options
                   context:(nullable SDWebImageContext *)context 
                  progress:(nullable void (^)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL))progress
                 completed:(nullable void (^)(UIImage *image, NSError *error))completed;

@end

NS_ASSUME_NONNULL_END
