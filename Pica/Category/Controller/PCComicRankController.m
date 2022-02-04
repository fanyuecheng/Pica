//
//  PCComicRankController.m
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCComicRankController.h"
#import "PCRankListController.h"

@interface PCComicRankController () <UICollectionViewDelegate, UICollectionViewDataSource>
 
@property (nonatomic, strong) UISegmentedControl   *columnsView;
@property (nonatomic, strong) UICollectionView     *collectionView;
@property (nonatomic, strong) PCRankListController *h24Controller;
@property (nonatomic, strong) PCRankListController *d7Controller;
@property (nonatomic, strong) PCRankListController *d30Controller;
@property (nonatomic, strong) PCRankListController *knightController;


@end

@implementation PCComicRankController

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"哔咔排行榜";
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.columnsView];
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat navigation = self.qmui_navigationBarMaxYInViewCoordinator;
    
    self.columnsView.frame = CGRectMake(10, navigation + 10, SCREEN_WIDTH - 20, 40);
    self.collectionView.frame = CGRectMake(0, self.columnsView.qmui_bottom + 10, SCREEN_WIDTH, SCREEN_HEIGHT - navigation - 10 - 40 - 10);
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    [cell.contentView qmui_removeAllSubviews];
    
    PCRankListController *listController = [self listWithIndex:indexPath.item];
    listController.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:listController.view];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    PCRankListController *listController = [self listWithIndex:indexPath.item];
    [listController requestData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH, collectionView.qmui_height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.columnsView.selectedSegmentIndex = scrollView.contentOffset.x / scrollView.qmui_width;
}

#pragma mark - Method
- (PCRankListController *)listWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return self.h24Controller;
            break;
        case 1:
            return self.d7Controller;
            break;
        case 2:
            return self.d30Controller;
            break;
        default:
            return self.knightController;
            break;
    }
}

#pragma mark - Action
- (void)indexAction:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    [self.collectionView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0) animated:YES];
}

#pragma mark - Get
- (UISegmentedControl *)columnsView {
    if (!_columnsView) {
        _columnsView = [[UISegmentedControl alloc] initWithItems:@[@"过去24小时", @"过去7天", @"过去30天", @"骑士榜"]];
        _columnsView.selectedSegmentIndex = 0;
        [_columnsView addTarget:self action:@selector(indexAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _columnsView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColorWhite;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (PCRankListController *)h24Controller {
    if (!_h24Controller) {
        _h24Controller = [[PCRankListController alloc] initWithType:PCRankListTypeH24];
    }
    return _h24Controller;
}

- (PCRankListController *)d7Controller {
    if (!_d7Controller) {
        _d7Controller = [[PCRankListController alloc] initWithType:PCRankListTypeD7];
    }
    return _d7Controller;
}

- (PCRankListController *)d30Controller {
    if (!_d30Controller) {
        _d30Controller = [[PCRankListController alloc] initWithType:PCRankListTypeD30];
    }
    return _d30Controller;
}

- (PCRankListController *)knightController {
    if (!_knightController) {
        _knightController = [[PCRankListController alloc] initWithType:PCRankListTypeKnight];
    }
    return _knightController;
}

@end
