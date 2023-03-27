//
//  PCNewChatMessageBubbleView.m
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatMessageBubbleView.h"
#import "PCVendorHeader.h"
#import "PCCommonUI.h"

@implementation PCNewChatMessageBubbleView


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
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.backgroundColor = PCColorLightPink;
}


@end
