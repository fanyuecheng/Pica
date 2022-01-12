//
//  PCImageSizeCache.h
//  Pica
//
//  Created by 米画师 on 2022/1/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

#define kPCImageSizeCache  [PCImageSizeCache sharedInstance]

@interface PCImageSizeCache : NSObject

+ (instancetype)sharedInstance;

- (BOOL)storeImageSize:(CGSize)size forKey:(NSString *)key;
- (CGSize)getImageSizeForKey:(NSString *)key;
- (BOOL)containsImageSizeForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
