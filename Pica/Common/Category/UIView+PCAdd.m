//
//  UIView+PCAdd.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "UIView+PCAdd.h"

@implementation UIView (PCAdd)

- (void)pc_setShadowWithOpacity:(CGFloat)opacity
                         radius:(CGFloat)radius
                         offset:(CGSize)offset
                          color:(UIColor *)color {
    self.layer.shadowOpacity = opacity;    // 阴影透明度
    self.layer.shadowColor = color.CGColor;// 阴影的颜色
    self.layer.shadowRadius = radius;      // 阴影扩散的范围控制
    self.layer.shadowOffset = offset;      // 阴影的范围 shadowOffset阴影偏移,x向右偏移，y向下偏移，默认(0, -3),这个跟shadowRadius配合使用
}

@end
