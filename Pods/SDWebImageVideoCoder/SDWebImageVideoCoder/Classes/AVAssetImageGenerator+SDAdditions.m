/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "AVAssetImageGenerator+SDAdditions.h"
#import <objc/runtime.h>
#if SD_UIKIT
#import <MobileCoreServices/MobileCoreServices.h>
#endif

#define AVDataAssetClass @"AVDataAsset"
#define AVDataAssetMaxLength 1048576
@protocol AVDataAssetProtocol <NSObject>

- (instancetype)initWithData:(NSData *)data contentType:(AVFileType)type;

@end

@interface AVAssetImageGenerator ()

@property (nonatomic, strong) NSData *sd_videoData;

@end

@implementation AVAssetImageGenerator (SDAdditions)

+ (instancetype)sd_assetImageGeneratorWithVideoData:(NSData *)data contentType:(AVFileType)type {
    if (!data) {
        return nil;
    }
    
    AVAsset *asset;
    Class cls = NSClassFromString(AVDataAssetClass);
    if ([cls instancesRespondToSelector:@selector(initWithData:contentType:)] && data.length < AVDataAssetMaxLength && type.length > 0) {
        // Prefer Data Asset if available
        asset = [[cls alloc] initWithData:data contentType:type];
    } else {
        // Random file name
        NSString *uuid = [NSUUID UUID].UUIDString;
        // File extention
        NSString *extname = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(type), kUTTagClassFilenameExtension));
        if (!extname) {
            extname = @"mp4";
        }
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", uuid, extname];
        NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [data writeToURL:fileURL atomically:NO];
        asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    }
    if (!asset) {
        return nil;
    }
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    if (!generator) {
        return nil;
    }
    generator.sd_videoData = data;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    return generator;
}

#pragma mark  - SDImageCoder

- (NSData *)animatedImageData {
    NSData *data = [self sd_videoData];
    if (data) {
        return data;
    }
    if ([self.asset isKindOfClass:AVURLAsset.class]) {
        NSURL *url = ((AVURLAsset *)self.asset).URL;
        data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
    }
    return data;
}

- (NSUInteger)animatedImageLoopCount {
    return 0;
}

- (NSUInteger)animatedImageFrameCount {
    CMTime time = self.asset.duration;
    NSTimeInterval totalDuration = CMTimeGetSeconds(time);
    return totalDuration * [self sd_framePerSecond];
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    return 1.0 / [self sd_framePerSecond];
}

- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    NSError *error;
    CMTime time = [self sd_frameTimeAtIndex:index];
    CMTime actualTime;
    CGImageRef imageRef = [self copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (!imageRef) {
        NSLog(@"AVAssetImageGenerator frame generate failed: %@", error);
        return nil;
    }
    
    // AVFoundation force decode
    CGImageRef newImageRef = [SDImageCoderHelper CGImageCreateDecoded:imageRef];
    if (!newImageRef) {
        newImageRef = imageRef;
    } else {
        CGImageRelease(imageRef);
    }
#if SD_MAC
    UIImage *image = [[UIImage alloc] initWithCGImage:newImageRef scale:1 orientation:kCGImagePropertyOrientationUp];
#else
    UIImage *image = [[UIImage alloc] initWithCGImage:newImageRef scale:1 orientation:UIImageOrientationUp];
#endif
    CGImageRelease(newImageRef);
    return image;
}

#pragma mark - Helper

- (CMTime)sd_frameTimeAtIndex:(NSUInteger)index {
    NSTimeInterval duration = [self animatedImageDurationAtIndex:index] * index;
    CMTime time = CMTimeMakeWithSeconds(duration, 1000);
    return time;
}

- (NSTimeInterval)sd_framePerSecond {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sd_framePerSecond));
    if (!value) {
        AVAssetTrack *videoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo].lastObject;
        NSTimeInterval framePerSecond = videoTrack.nominalFrameRate;
        objc_setAssociatedObject(self, @selector(sd_framePerSecond), @(framePerSecond), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return framePerSecond;
    }
    return value.doubleValue;
}

- (void)setSd_framePerSecond:(NSTimeInterval)sd_framePerSecond {
    objc_setAssociatedObject(self, @selector(sd_framePerSecond), @(sd_framePerSecond), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSData *)sd_videoData {
    return objc_getAssociatedObject(self, @selector(sd_videoData));
}

- (void)setSd_videoData:(NSData *)sd_videoData {
    objc_setAssociatedObject(self, @selector(sd_videoData), sd_videoData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
