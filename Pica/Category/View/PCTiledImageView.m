//
//  PCTiledImageView.m
//  Pica
//
//  Created by Fancy on 2021/8/16.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCTiledImageView.h"

@implementation PCTiledImageView

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (void)drawRect:(CGRect)rect {
    if (self.image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextScaleCTM(context, 1, 1);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(self.image.CGImage), CGImageGetHeight(self.image.CGImage)), self.image.CGImage);
        CGContextRestoreGState(context);
    } else {
        [super drawRect:rect];
    }
}

@end
