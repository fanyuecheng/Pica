//
//  PCComicRecommendView.m
//  Pica
//
//  Created by Fancy on 2022/3/2.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCComicRecommendView.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"
#import "PCComic.h"
#import "PCCommonUI.h"
#import "PCComicDetailController.h"
#import "PCComicHistory.h"
#import "UIImageView+PCAdd.h"
 
@interface PCComicRecommendView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) QMUILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PCComicRecommendView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.backgroundColor = UIColorWhite;
    [self addSubview:self.titleLabel];
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.qmui_width;
    self.titleLabel.frame = CGRectMake(15, 20, width - 30, QMUIViewSelfSizingHeight);
    self.collectionView.frame = CGRectMake(0, self.titleLabel.qmui_bottom + 10, width, width / 5 / 9 * 16);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = 0;
    height += 20 + [self.titleLabel sizeThatFits:CGSizeMax].height + 10 + SCREEN_WIDTH / 5 / 9 * 16 + 60 + 15;
    return CGSizeMake(SCREEN_WIDTH, height);
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.comicArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    UIImageView *coverView = [cell.contentView viewWithTag:1000];
    if (!coverView) {
        coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.qmui_width, cell.qmui_height - 60)];
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        coverView.clipsToBounds = YES;
        coverView.tag = 1000;
        [cell.contentView addSubview:coverView];
    }
    QMUILabel *titleLabel = [cell.contentView viewWithTag:1001];
    if (!titleLabel) {
        titleLabel = [[QMUILabel alloc] init];
        titleLabel.tag = 1001;
        titleLabel.font = UIFontMake(12);
        titleLabel.numberOfLines = 2;
        [cell.contentView addSubview:titleLabel];
    }
    
    PCComic *comic = self.comicArray[indexPath.item];
    [coverView pc_setImageWithURL:comic.thumb.imageURL];
    titleLabel.text = comic.title;
    titleLabel.frame = CGRectMake(0, coverView.qmui_bottom, cell.qmui_width, QMUIViewSelfSizingHeight);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    PCComic *comic = self.comicArray[indexPath.item];
    [kPCComicHistory saveComic:comic];
    PCComicDetailController *detail = [[PCComicDetailController alloc] initWithComicId:comic.comicId];
    [[QMUIHelper visibleViewController].navigationController pushViewController:detail animated:YES];
}

#pragma mark - Get
- (QMUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlack];
        _titleLabel.text = @"看了这本子的人也在看";
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat width = floorf(SCREEN_WIDTH / 5);
        layout.itemSize = CGSizeMake(width, width / 9 * 16 + 60);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColorClear;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _collectionView;
}

#pragma mark - Set
- (void)setComicArray:(NSArray<PCComic *> *)comicArray {
    _comicArray = comicArray;
    [self.collectionView reloadData];
}

@end
