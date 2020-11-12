//
//  UIImage+PCAdd.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "UIImage+PCAdd.h"
#import <QMUIKit/QMUIKit.h>

@implementation UIImage (PCAdd)

+ (UIImage *)pc_iconWithText:(NSString *)text
                        size:(NSInteger)size
                       color:(UIColor *)color {
    return [UIImage pc_iconWithText:text
                               size:size
                              color:color
                        orientation:UIImageOrientationUp
                    extensionInsets:UIEdgeInsetsZero];
}

+ (UIImage *)pc_iconWithText:(NSString *)text
                        size:(NSInteger)size
                       color:(UIColor *)color
             extensionInsets:(UIEdgeInsets)extensionInsets {
    return [UIImage pc_iconWithText:text
                               size:size
                              color:color
                        orientation:UIImageOrientationUp
                    extensionInsets:extensionInsets];
}

+ (UIImage *)pc_iconWithText:(NSString *)text
                        size:(NSInteger)size
                       color:(UIColor *)color
                 orientation:(UIImageOrientation)orientation
             extensionInsets:(UIEdgeInsets)extensionInsets {
    QMUILabel *label = [[QMUILabel alloc] qmui_initWithFont:[UIFont fontWithName:@"iconfont" size:size] textColor:color];
    label.text = text;
    if (!UIEdgeInsetsEqualToEdgeInsets(extensionInsets, UIEdgeInsetsZero)) {
        label.contentEdgeInsets = extensionInsets;
    }
    [label sizeToFit];
     
    UIImage *image = [UIImage qmui_imageWithView:label];
    
    switch (orientation) {
        case UIImageOrientationUp:
            return image;
            break;
            
        default:
            return [image qmui_imageWithOrientation:orientation];
            break;
    }
}

+ (CGSize)pc_sizeWithURL:(id)URL {
    NSURL *url = nil;
    if ([URL isKindOfClass:[NSURL class]]) {
        url = URL;
    }
    if ([URL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:URL];
    }
    if (!URL) {
        return CGSizeZero;
    }
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    
    if (imageSourceRef) {
        // 获取图像属性
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        //以下是对手机32位、64位的处理
        if (imageProperties != NULL) {
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            
#if defined(__LP64__) && __LP64__
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
#else
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
            }
            
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
            }
#endif
            // 图像旋转的方向属性
            NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyOrientation) integerValue];
            CGFloat temp = 0;
            switch (orientation) {  // 如果图像的方向不是正的，则宽高互换
                case UIImageOrientationLeft: // 向左逆时针旋转90度
                case UIImageOrientationRight: // 向右顺时针旋转90度
                case UIImageOrientationLeftMirrored: // 在水平翻转之后向左逆时针旋转90度
                case UIImageOrientationRightMirrored: { // 在水平翻转之后向右顺时针旋转90度
                    temp = width;
                    width = height;
                    height = temp;
                }
                    break;
                default:
                    break;
            } 
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}

@end

