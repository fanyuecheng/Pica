//
//  PCGameListController.m
//  Pica
//
//  Created by Fancy on 2021/6/25.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGameListController.h"
#import "PCGameListRequest.h"
#import "PCGameItemCell.h"
#import "PCGameDetailController.h"

@interface PCGameListController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray <PCGameList *>*gameArray;
@property (nonatomic, strong) PCGameListRequest *request;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PCGameListController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestGame];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"游戏";
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, SCREEN_WIDTH, SCREEN_HEIGHT - self.qmui_navigationBarMaxYInViewCoordinator - self.qmui_tabBarSpacingInViewCoordinator);
}

#pragma mark - Net
- (void)requestGame {
    if (self.request.page == 1) {
        [self showEmptyViewWithLoading];
    }
    [self.request sendRequest:^(PCGameList *list) {
        [self hideEmptyView];
        [self.collectionView.mj_footer endRefreshing];
        [self.gameArray addObject:list];
        [self.collectionView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestGame)];
    }];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.gameArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gameArray[section].docs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PCGameItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCGameItemCell" forIndexPath:indexPath];
    cell.game = self.gameArray[indexPath.section].docs[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PCGameDetailController *detail = [[PCGameDetailController alloc] initWithGameId:self.gameArray[indexPath.section].docs[indexPath.row].gameId];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Get
- (NSMutableArray *)gameArray {
    if (!_gameArray) {
        _gameArray = [NSMutableArray array];
    }
    return _gameArray;
}

- (PCGameListRequest *)request {
    if (!_request) {
        _request = [[PCGameListRequest alloc] init];
    }
    return _request;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake(floor((SCREEN_WIDTH - 40) * 0.5), floor((SCREEN_WIDTH - 40) * 0.5) + 40);
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15 + SafeAreaInsetsConstantForDeviceWithNotch.bottom, 15);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
 
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColorWhite;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PCGameItemCell class] forCellWithReuseIdentifier:@"PCGameItemCell"];
        @weakify(self)
        _collectionView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            @strongify(self)
            self.request.page ++;
            if (self.request.page > self.gameArray.firstObject.pages) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self requestGame];
            }
        }];
         
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

@end
