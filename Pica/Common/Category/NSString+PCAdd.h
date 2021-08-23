//
//  NSString+PCAdd.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString (PCAdd)

- (NSString *)pc_hmacSHA256StringWithKey:(NSString *)key;
- (CGFloat)pc_widthForFont:(UIFont *)font;
- (CGFloat)pc_heightForFont:(UIFont *)font width:(CGFloat)width; 
- (UIImage *)pc_imageWithTextColor:(UIColor *)color
                              font:(UIFont *)font;
+ (NSString *)pc_randomTextWithLength:(NSUInteger)length;

- (NSString *)pc_simplifiedChinese;
- (NSString *)pc_traditionalChinese;

@end

NS_ASSUME_NONNULL_END
