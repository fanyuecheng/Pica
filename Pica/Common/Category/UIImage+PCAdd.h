//
//  UIImage+PCAdd.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCIconHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PCAdd)

+ (UIImage *)pc_iconWithText:(NSString *)text
                        size:(NSInteger)size
                       color:(UIColor *)color;

+ (UIImage *)pc_iconWithText:(NSString *)text
                        size:(NSInteger)size
                       color:(UIColor *)color
             extensionInsets:(UIEdgeInsets)extensionInsets;

+ (UIImage *)pc_iconWithText:(NSString *)text
                        size:(NSInteger)size
                       color:(UIColor *)color
                 orientation:(UIImageOrientation)orientation
             extensionInsets:(UIEdgeInsets)extensionInsets;

+ (CGSize)pc_sizeWithURL:(id)URL;

@end

NS_ASSUME_NONNULL_END
