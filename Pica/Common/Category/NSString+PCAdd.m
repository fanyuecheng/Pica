//
//  NSString+PCAdd.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "NSString+PCAdd.h"
#import "NSData+PCAdd.h"
#import <QMUIKit/QMUIKit.h>

@implementation NSString (PCAdd)

- (NSString *)pc_hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            pc_hmacSHA256StringWithKey:key];
}

- (CGSize)pc_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result = CGSizeZero;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr
                                         context:nil];
        result = rect.size;
    }
    return result;
}

- (CGFloat)pc_widthForFont:(UIFont *)font {
    CGSize size = [self pc_sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)pc_heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self pc_sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}
 
- (UIImage *)pc_imageWithTextColor:(UIColor *)color
                              font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] init];
    label.text = self;
    label.textColor = color;
    label.font = font;
    [label sizeToFit];
    
    return [UIImage qmui_imageWithView:label];
}

+ (NSString *)pc_randomTextWithLength:(NSUInteger)length {
    NSString *parentString = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIGKLMNOPQRSTUVWXYZ";
    NSArray *parentArray = [parentString qmui_toArray];
    if (length) {
        NSMutableString *nameString = [NSMutableString string];
        
        for (NSInteger i = 0; i < length; i++) {
            NSInteger index = arc4random() % parentString.length;
            [nameString appendString:[parentArray objectAtIndex:index]];
        }
        return nameString;
    } else {
        return @"";
    }
}

@end
