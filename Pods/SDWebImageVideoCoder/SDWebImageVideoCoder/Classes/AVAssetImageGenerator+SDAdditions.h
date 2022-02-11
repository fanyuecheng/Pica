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
#import <AVFoundation/AVFoundation.h>

@interface AVAssetImageGenerator (SDAdditions) <SDAnimatedImageProvider>

/// The desired animation image FPS. By default it's the Video FPS, larger value will consume much more CPU (25 FPS may consume 200% CPU)
@property (nonatomic, assign) NSTimeInterval sd_framePerSecond;

/// Create a image generator with video data and desired format type
/// @param data video data
/// @param type video format type
+ (nullable instancetype)sd_assetImageGeneratorWithVideoData:(nonnull NSData *)data contentType:(nullable AVFileType)type;

@end
