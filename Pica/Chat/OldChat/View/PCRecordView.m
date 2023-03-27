//
//  PCRecordView.m
//  Pica
//
//  Created by Fancy on 2021/6/18.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRecordView.h"
#import "PCVendorHeader.h"
#import "UIImage+PCAdd.h"
 
@implementation PCRecordView

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
    [self setupViews];
    [self defaultLayout];
}

- (void)setupViews {
    self.backgroundColor = UIColorClear;
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = UIColorMakeWithRGBA(0, 0, 0, 0.6);
    _backgroundView.layer.cornerRadius = 5;
    [_backgroundView.layer setMasksToBounds:YES];
    [self addSubview:_backgroundView];

    _recordImageView = [[UIImageView alloc] init];
    _recordImageView.image = UIImageMake(@"record_1");
    _recordImageView.alpha = 0.8;
    _recordImageView.contentMode = UIViewContentModeCenter;
    [_backgroundView addSubview:_recordImageView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = UIFontMake(14);
    _titleLabel.textColor = UIColorWhite;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.layer.cornerRadius = 5;
    [_titleLabel.layer setMasksToBounds:YES];
    [_backgroundView addSubview:_titleLabel];
}

- (void)defaultLayout {
    CGSize backSize = CGSizeMake(SCREEN_WIDTH * 0.4, SCREEN_WIDTH * 0.4);
    _titleLabel.text = @"手指上滑，取消发送";
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (titleSize.width > backSize.width){
        backSize.width = titleSize.width + 2 * 8;
    }

    _backgroundView.frame = CGRectMake((SCREEN_WIDTH - backSize.width) * 0.5, (SCREEN_HEIGHT - backSize.height) * 0.5, backSize.width, backSize.height);
    CGFloat imageHeight = backSize.height - titleSize.height - 2 * 8;
    _recordImageView.frame = CGRectMake(0, 0, backSize.width, imageHeight);
    CGFloat titley = _recordImageView.frame.origin.y + imageHeight;
    _titleLabel.frame = CGRectMake(0, titley, backSize.width, backSize.height - titley);
}

- (void)setStatus:(PCVoiceRecordStatus)status {
    switch (status) {
        case PCVoiceRecordStatusRecording:
        {
            _titleLabel.text = @"手指上滑，取消发送";
            _titleLabel.backgroundColor = UIColorClear;
            break;
        }
        case PCVoiceRecordStatusCancel:
        {
            _titleLabel.text = @"松开手指，取消发送";
            _titleLabel.backgroundColor = UIColorMakeWithRGBA(186, 60, 65, 1.0);
            break;
        }
        case PCVoiceRecordStatusTooShort:
        {
            _titleLabel.text = @"说话时间太短";
            _titleLabel.backgroundColor = UIColorClear;
            break;
        }
        case PCVoiceRecordStatusTooLong:
        {
            _titleLabel.text = @"说话时间太长";
            _titleLabel.backgroundColor = UIColorClear;
            break;
        }
        default:
            break;
    }
}

- (void)setPower:(NSInteger)power {
    NSString *imageName = [self getRecordImage:power];
    _recordImageView.image = [UIImage imageNamed:imageName];
}

- (NSString *)getRecordImage:(NSInteger)power {
    // 关键代码
    power = power + 60;
    int index = 0;
    if (power < 25){
        index = 1;
    } else{
        index = ceil((power - 25) / 5.0) + 1;
    }
    return [NSString stringWithFormat:@"record_%d", index];
}

@end
