/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDImageVideoCoder.h"
#import "AVAssetImageGenerator+SDAdditions.h"

@interface SDImageVideoCoder ()

@property (nonatomic, strong) AVAssetImageGenerator *generator;

@end

@implementation SDImageVideoCoder

+ (SDImageVideoCoder *)sharedCoder {
    static SDImageVideoCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDImageVideoCoder alloc] init];
    });
    return coder;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxFramePerSecond = 10;
        self.maxFrameSize = CGSizeZero;
    }
    return self;
}

#pragma mark - Helper

- (AVFileType)videoContentTypeWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    // Current supported formats
    if (data.length >= 8) {
        // MPEG4
        NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
        if ([testString isEqualToString:@"ftypMSNV"]
            || [testString isEqualToString:@"ftypisom"]) {
            return AVFileTypeMPEG4;
        }
        // M4V
        if ([testString isEqualToString:@"ftypmp42"]) {
            return AVFileTypeAppleM4V;
        }
        // MOV
        if ([testString hasPrefix:@"ftypqt"] || [testString isEqualToString:@"moov"]) {
            return AVFileTypeQuickTimeMovie;
        }
    }
    return nil;
}

#pragma mark - SDImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    return [self videoContentTypeWithData:data] != nil;
}

- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    return NO;
}

- (nullable UIImage *)decodedImageWithData:(nullable NSData *)data options:(nullable SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    AVFileType contentType = [self videoContentTypeWithData:data];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator sd_assetImageGeneratorWithVideoData:data contentType:contentType];
    return [generator animatedImageFrameAtIndex:0];
}

- (nullable NSData *)encodedDataWithImage:(nullable UIImage *)image format:(SDImageFormat)format options:(nullable SDImageCoderOptions *)options {
    return nil;
}

#pragma mark - SDAnimatedImageCoder

- (nullable instancetype)initWithAnimatedImageData:(nullable NSData *)data options:(nullable SDImageCoderOptions *)options {
    self = [self init];
    if (self) {
        if (!data) {
            return nil;
        }
        AVFileType contentType = [self videoContentTypeWithData:data];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator sd_assetImageGeneratorWithVideoData:data contentType:contentType];
        if (!generator) {
            return nil;
        }
        if (generator.sd_framePerSecond > self.maxFramePerSecond) {
            generator.sd_framePerSecond = self.maxFramePerSecond;
        }
        generator.maximumSize = self.maxFrameSize;
        self.generator = generator;
    }
    return self;
}

- (NSData *)animatedImageData {
    return [self.generator animatedImageData];
}

- (NSUInteger)animatedImageLoopCount {
    return [self.generator animatedImageLoopCount];
}

- (NSUInteger)animatedImageFrameCount {
    return [self.generator animatedImageFrameCount];
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    return [self.generator animatedImageDurationAtIndex:index];
}

- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    return [self.generator animatedImageFrameAtIndex:index];
}

@end
