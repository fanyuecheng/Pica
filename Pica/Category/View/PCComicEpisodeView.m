//
//  PCComicEpisodeView.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicEpisodeView.h"
#import "PCVendorHeader.h"
#import "UIView+PCAdd.h"
#import "PCComicPictureController.h"

@interface PCComicEpisodeView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *episodeView;

@end

@implementation PCComicEpisodeView

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
    NSInteger row = self.episode.docs.count % 4 == 0 ? self.episode.docs.count / 4 : self.episode.docs.count / 4 + 1;
    return CGSizeMake(SCREEN_WIDTH, row * 44 + (row - 1) * 10 + 10);
}

#pragma mark - Action
- (void)openEpisodeWithIndex:(NSInteger)index {
    PCComicPictureController *picture = [[PCComicPictureController alloc] initWithComicId:self.episode.comicId];
    picture.episodeArray = self.episode.docs;
    picture.index = index;
    [[QMUIHelper visibleViewController].navigationController pushViewController:picture animated:YES];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.episode.docs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    QMUILabel *label = [cell.contentView viewWithTag:1000];
    if (!label) {
        label = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorBlue];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000;
        label.layer.cornerRadius = 4;
        label.layer.borderWidth = .5;
        label.layer.borderColor = UIColorBlue.CGColor;
        label.backgroundColor = UIColorWhite;
        label.numberOfLines = 2;
        [cell.contentView addSubview:label];
    }
    PCEpisode *ep = self.episode.docs[indexPath.item];
    label.text = ep.title;
    label.frame = cell.bounds;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES]; 
    [self openEpisodeWithIndex:indexPath.item];
}
 
#pragma mark - Get
- (UICollectionView *)episodeView {
    if (!_episodeView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(5, 15, 5, 15);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(floor((SCREEN_WIDTH - 60) * 0.25) , 44);
 
        _episodeView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _episodeView.backgroundColor = UIColorWhite;
        _episodeView.delegate = self;
        _episodeView.dataSource = self;
        [_episodeView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        if (@available(iOS 11, *)) {
            _episodeView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _episodeView;
}

- (void)setEpisode:(PCComicEpisode *)episode {
    _episode = episode;
    
    [self.episodeView reloadData];
}

@end
