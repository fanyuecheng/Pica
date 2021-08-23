//
//  PCColorGridView.m
//  Pica
//
//  Created by Fancy on 2021/7/14.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCColorGridView.h"
#import "PCVendorHeader.h"

@interface PCColorGridView ()

@property (nonatomic, copy)   NSArray <NSString *>*colorHexArray;
@property (nonatomic, strong) QMUIFloatLayoutView *gridView;

@end

@implementation PCColorGridView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self addSubview:self.gridView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.qmui_width;
    CGFloat height = self.qmui_width;
    
    if (width == 0 || height == 0) {
        return;
    }
    
    self.gridView.minimumItemSize = CGSizeMake(width / 12, width / 12);
    self.gridView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, size.width / 12 * 10);
}

#pragma mark - Action
- (void)colorAction:(QMUIButton *)sender {
    !self.colorBlock ? : self.colorBlock(sender.backgroundColor);
}

#pragma mark - Method
- (QMUIButton *)generateButtonAtIndex:(NSInteger)index {
    QMUIButton *button = [[QMUIButton alloc] init];
    button.backgroundColor = UIColorMakeWithHex(self.colorHexArray[index]);
    button.tag = index + 1000;
    [button addTarget:self action:@selector(colorAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Get
- (QMUIFloatLayoutView *)gridView {
    if (!_gridView) {
        _gridView = [[QMUIFloatLayoutView alloc] init];
        for (NSInteger i = 0, l = self.colorHexArray.count; i < l; i++) {
            [self.gridView addSubview:[self generateButtonAtIndex:i]];
        }
    }
    return _gridView;
}

- (NSArray<NSString *> *)colorHexArray {
    if (!_colorHexArray) {
        _colorHexArray = @[@"#fffefffe",
                           @"#ffeaebeb",
                           @"#ffd6d6d6",
                           @"#ffc2c2c2",
                           @"#ffadadad",
                           @"#ff999999",
                           @"#ff858584",
                           @"#ff6f6f6f",
                           @"#ff5b5b5b",
                           @"#ff474646",
                           @"#ff323232",
                           @"#ff000000",
                           @"#ff003749",
                           @"#ff011c56",
                           @"#ff11053a",
                           @"#ff2d063d",
                           @"#ff3c071b",
                           @"#ff5b0700",
                           @"#ff591b00",
                           @"#ff573200",
                           @"#ff563c00",
                           @"#ff656100",
                           @"#ff4e5503",
                           @"#ff253e0f",
                           @"#ff004c65",
                           @"#ff012f7b",
                           @"#ff1a0a51",
                           @"#ff440c59",
                           @"#ff541028",
                           @"#ff831100",
                           @"#ff7b2900",
                           @"#ff7a4900",
                           @"#ff785700",
                           @"#ff8d8601",
                           @"#ff6f750a",
                           @"#ff37561a",
                           @"#ff016d8f",
                           @"#ff0042a9",
                           @"#ff2c0976",
                           @"#ff61177b",
                           @"#ff791a3d",
                           @"#ffb51a00",
                           @"#ffad3e00",
                           @"#ffa96700",
                           @"#ffa67b00",
                           @"#ffc4bc00",
                           @"#ff9ba50d",
                           @"#ff4d7a26",
                           @"#ff008cb4",
                           @"#ff0055d6",
                           @"#ff361a94",
                           @"#ff79219e",
                           @"#ff99244e",
                           @"#ffe22400",
                           @"#ffda5100",
                           @"#ffd38300",
                           @"#ffd19d00",
                           @"#fff5ec00",
                           @"#ffc3d116",
                           @"#ff659d33",
                           @"#ff00a1d8",
                           @"#ff0060fe",
                           @"#ff4d21b2",
                           @"#ff9829bc",
                           @"#ffb92d5c",
                           @"#ffff4014",
                           @"#ffff6a00",
                           @"#ffffab00",
                           @"#fffdc700",
                           @"#fffefb40",
                           @"#ffd9ec36",
                           @"#ff76bb3f",
                           @"#ff01c7fc",
                           @"#ff3a87fe",
                           @"#ff5e30eb",
                           @"#ffbe38f3",
                           @"#ffe63b7a",
                           @"#ffff624f",
                           @"#ffff8647",
                           @"#fffeb43e",
                           @"#fffecb3d",
                           @"#fffef76b",
                           @"#ffe4ef64",
                           @"#ff96d35f",
                           @"#ff52d6fc",
                           @"#ff74a7ff",
                           @"#ff864efe",
                           @"#ffd357fe",
                           @"#ffee719e",
                           @"#ffff8c82",
                           @"#ffffa57d",
                           @"#ffffc776",
                           @"#ffffd976",
                           @"#fffff994",
                           @"#ffeaf28e",
                           @"#ffb1dd8b",
                           @"#ff93e3fd",
                           @"#ffa7c6ff",
                           @"#ffb18cfe",
                           @"#ffe292fe",
                           @"#fff4a4c0",
                           @"#ffffb5af",
                           @"#ffffc5ab",
                           @"#ffffd9a8",
                           @"#fffee4a8",
                           @"#fffffbb9",
                           @"#fff2f7b7",
                           @"#ffcde8b5",
                           @"#ffcbf0ff",
                           @"#ffd3e2ff",
                           @"#ffd9c8fe",
                           @"#ffefcaff",
                           @"#fff9d3e0",
                           @"#ffffdbd8",
                           @"#ffffe2d6",
                           @"#ffffecd4",
                           @"#fffef2d5",
                           @"#fffefcdd",
                           @"#fff7fadb",
                           @"#ffdfeed4"];
    }
    return _colorHexArray;
}

@end
