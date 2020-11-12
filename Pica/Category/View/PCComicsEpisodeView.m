//
//  PCComicsEpisodeView.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsEpisodeView.h"
#import "PCVendorHeader.h"
#import "UIView+PCAdd.h"
#import "PCComicsPictureController.h"

@interface PCComicsEpisodeView ()

@property (nonatomic, strong) QMUIFloatLayoutView *episodeView;

@end

@implementation PCComicsEpisodeView

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
    [self addSubview:self.episodeView];
}
 
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.episodeView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SCREEN_WIDTH, [self.episodeView sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height);
}

#pragma mark - Action
- (void)buttonAction:(QMUIButton *)sender {
    NSInteger index = sender.tag - 1000;
    PCEpisode *ep = self.episode.docs[index];
    
    PCComicsPictureController *picture = [[PCComicsPictureController alloc] initWithComicsId:self.episode.comicsId order:ep.order];
    [[QMUIHelper visibleViewController].navigationController pushViewController:picture animated:YES];
}

#pragma mark - Get
- (QMUIFloatLayoutView *)episodeView {
    if (!_episodeView) {
        _episodeView = [[QMUIFloatLayoutView alloc] init];
        _episodeView.padding = UIEdgeInsetsMake(10, 15, 10, 15);
        _episodeView.itemMargins = UIEdgeInsetsMake(0, 0, 10, 10);
        CGFloat itemWidth = floorf((SCREEN_WIDTH - 60) * 0.25);
        _episodeView.minimumItemSize = CGSizeMake(itemWidth, 44);
        _episodeView.maximumItemSize = CGSizeMake(itemWidth, 44);
    }
    return _episodeView;
}

- (void)setEpisode:(PCComicsEpisode *)episode {
    _episode = episode;
    
    CGFloat itemWidth = floorf((SCREEN_WIDTH - 60) * 0.25);
    
    [episode.docs enumerateObjectsUsingBlock:^(PCEpisode * _Nonnull ep, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIButton *button = [[QMUIButton alloc] initWithFrame:CGRectMake(0, 0, itemWidth, 44)];
        button.tag = idx + 1000;
        button.titleLabel.font = UIFontMake(12);
        button.layer.cornerRadius = 4;
        button.backgroundColor = UIColorWhite;
        [button pc_setShadowWithOpacity:1 radius:4 offset:CGSizeZero color:UIColorSeparator];
        [button setTitle:ep.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.episodeView addSubview:button];
    }];
     
}

@end
