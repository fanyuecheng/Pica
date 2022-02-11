#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AVAssetImageGenerator+SDAdditions.h"
#import "SDImageVideoCoder.h"
#import "SDWebImageVideoCoder.h"

FOUNDATION_EXPORT double SDWebImageVideoCoderVersionNumber;
FOUNDATION_EXPORT const unsigned char SDWebImageVideoCoderVersionString[];

