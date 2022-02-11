/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
@import SDWebImage;
#endif

/// A coder plugin which can play Video format, such as MP4/MOV.
/// For normal image, it generate the poster thumb image of video.
/// For animated image, it use the `AVAssetImageGenerator` to generate individual frames by times.
@interface SDImageVideoCoder : NSObject <SDAnimatedImageCoder>

/// The shared instance of this coder
@property (nonatomic, class, readonly, nonnull) SDImageVideoCoder *sharedCoder;

/// The maximum FPS for animated image playback. This can dramatically impact the performance.
/// By default, this value set to 10, which means the frame duration is 0.1s.
@property (nonatomic, assign) NSTimeInterval maxFramePerSecond;

/// The maximum dimensions for the animated image playback. Zero specifies the asset’s unscaled dimensions.
/// By default, this value set to Zero. You can limit the size to reduce CPU and memory usage.
@property (nonatomic, assign) CGSize maxFrameSize;

@end
