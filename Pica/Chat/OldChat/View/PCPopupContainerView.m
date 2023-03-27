//
//  PCPopupContainerView.m
//  Pica
//
//  Created by Fancy on 2021/7/6.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCPopupContainerView.h"

@interface PCPopupContainerView ()

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation PCPopupContainerView

- (void)didInitialize {
    [super didInitialize];
    
    self.contentEdgeInsets = UIEdgeInsetsZero;
    self.buttonArray = [NSMutableArray array];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    return CGSizeMake(60 * self.titleArray.count, 40);
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    [self.buttonArray enumerateObjectsUsingBlock:^(QMUIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(60 * idx, 0, 60, 40);
    }];
}

- (void)buttonAction:(QMUIButton *)sender {
    !self.actionBlock ? : self.actionBlock(self, sender.tag - 1000);
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    
    [self.buttonArray removeAllObjects];
    [self.contentView qmui_removeAllSubviews];
    
    [titleArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIButton *button = [[QMUIButton alloc] init];
        button.tag = idx + 1000;
        button.titleLabel.font = UIFontMake(14);
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColorBlue forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        [self.buttonArray addObject:button];
    }];
}

@end
