//
//  PCColorSlider.m
//  Pica
//
//  Created by Fancy on 2021/7/14.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCColorSlider.h"
#import "PCVendorHeader.h"

@interface PCColorSlider ()

@property (nonatomic, strong) QMUILabel     *titleLabel;
@property (nonatomic, strong) UISlider      *slider;
@property (nonatomic, strong) QMUITextField *textField;

@end

@implementation PCColorSlider

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
    [self addSubview:self.titleLabel];
    [self addSubview:self.slider];
    [self addSubview:self.textField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.qmui_width;
    CGFloat height = self.qmui_width;
    
    if (width == 0 || height == 0) {
        return;
    }
    
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectSetXY(self.titleLabel.frame, 15, 0);
    self.slider.frame = CGRectMake(15, self.titleLabel.qmui_bottom + 5, width - 110, 40);
    self.textField.frame = CGRectMake(width - 15 - 65, self.titleLabel.qmui_bottom + 5, 65, 40);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, 20 + 40 + 10);
}

#pragma mark - Action
- (void)sliderAction:(UISlider *)sender {
    self.textField.text = [@(ceil(sender.value)) stringValue];
}

- (void)textChangeAction:(QMUITextField *)sender {
    _value = [sender.text integerValue];
    if (self.slider.value != _value) {
        self.slider.value = _value;
    }
    !self.valueBlock ? : self.valueBlock(_value);
}

#pragma mark - Get
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(14) textColor:UIColorGray];
    }
    return _titleLabel;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.qmui_trackHeight = 40;
        _slider.qmui_thumbSize = CGSizeMake(40, 40);
        _slider.qmui_thumbColor = UIColorWhite;
        _slider.layer.cornerRadius = 20;
        _slider.layer.masksToBounds = YES;
        _slider.maximumValue = 225;
        _slider.minimumValue = 0;
        [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (QMUITextField *)textField {
    if (!_textField) {
        _textField = [[QMUITextField alloc] init];
        _textField.backgroundColor = UIColorWhite;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.maximumTextLength = 3;
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = UIFontBoldMake(16);
        _textField.textColor = UIColorBlack;
        _textField.layer.cornerRadius = 4;
        _textField.layer.masksToBounds = YES;
        _textField.text = @"0";
        [_textField addTarget:self action:@selector(textChangeAction:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

#pragma mark - Set
- (void)setType:(PCColorSliderType)type {
    switch (type) {
        case PCColorSliderTypeRed:
            self.titleLabel.text = @"红";
            self.slider.minimumTrackTintColor = [UIColor redColor];
            break;
        case PCColorSliderTypeGreen:
            self.titleLabel.text = @"绿";
            self.slider.minimumTrackTintColor = [UIColor greenColor];
            break;
        case PCColorSliderTypeBlue:
            self.titleLabel.text = @"蓝";
            self.slider.minimumTrackTintColor = [UIColor blueColor];
            break;
        default:
            break;
    }
}

@end
