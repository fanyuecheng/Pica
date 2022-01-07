//
//  PCMessageBubbleView.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCMessageBubbleView.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"

@interface PCMessageBubbleView ()

@property(nonatomic, strong) CAShapeLayer *backgroundLayer;

@end

@implementation PCMessageBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.arrowSize = CGSizeMake(4, 7);
    self.cornerRadius = 4;
    self.arrowMaxY = 6;
    
    [self.layer addSublayer:self.backgroundLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize arrowSize = self.arrowSize;
    CGFloat cornerRadius = self.cornerRadius;
    CGFloat arrowMaxY = self.arrowMaxY;
    
    CGRect roundedRect = CGRectMake(self.arrowLeft ? arrowSize.width : 0, 0, CGRectGetWidth(self.bounds) - arrowSize.width, CGRectGetHeight(self.bounds));
    
    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    
    if (self.arrowLeft) {
        [path addLineToPoint:CGPointMake(leftTopArcCenter.x - cornerRadius, cornerRadius + arrowMaxY)];
        [path addLineToPoint:CGPointMake(0, cornerRadius + arrowMaxY + arrowSize.height / 2)];
        [path addLineToPoint:CGPointMake(leftTopArcCenter.x - cornerRadius, cornerRadius + arrowMaxY + arrowSize.height)];
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftBottomArcCenter.y)];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
    
    
    [path addLineToPoint:CGPointMake(rightBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];
    
    if (!self.arrowLeft) {
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), cornerRadius + arrowMaxY + arrowSize.height)];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect) + arrowSize.width, cornerRadius + arrowMaxY + arrowSize.height / 2)];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), cornerRadius + arrowMaxY)];
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightTopArcCenter.y)];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];
    
    [path closePath];
    
    self.backgroundLayer.path = path.CGPath;
    self.backgroundLayer.frame = self.bounds;
}


#pragma mark - Get
- (CAShapeLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.fillColor = PCColorLightPink.CGColor;
    }
    return _backgroundLayer;
}

#pragma mark - Set
- (void)setArrowLeft:(BOOL)arrowLeft {
    if (_arrowLeft != arrowLeft) {
        _arrowLeft = arrowLeft;
        [self setNeedsLayout];
    }
}

- (void)setArrowSize:(CGSize)arrowSize {
    if (!CGSizeEqualToSize(_arrowSize, arrowSize)) {
        _arrowSize = arrowSize;
        [self setNeedsLayout];
    }
}

- (void)setArrowMaxY:(CGFloat)arrowMaxY {
    if (_arrowMaxY != arrowMaxY) {
        _arrowMaxY = arrowMaxY;
        [self setNeedsLayout];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        [self setNeedsLayout];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.backgroundLayer.fillColor = fillColor.CGColor;
}

@end
