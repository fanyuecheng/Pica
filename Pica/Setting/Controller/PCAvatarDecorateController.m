//
//  PCAvatarDecorateController.m
//  Pica
//
//  Created by Fancy on 2021/7/16.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCAvatarDecorateController.h"
#import "UIImageView+PCAdd.h"
#import "PCUser.h"
#import "PCCategoryCell.h"
#import "PCIconHeader.h"

@interface PCAvatarDecorateController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy)   NSArray <NSString *> *decorateArray; 
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation PCAvatarDecorateController

- (void)didInitialize {
    [super didInitialize];
    
    _selectIndex = [kPCUserDefaults integerForKey:PC_CHAT_AVATAR_CHARACTER];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.collectionView];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
     
    self.title = @"头像装饰";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"随机" target:self action:@selector(randomAction:)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, SCREEN_WIDTH, SCREEN_HEIGHT - self.qmui_navigationBarMaxYInViewCoordinator - self.qmui_tabBarSpacingInViewCoordinator);
}

#pragma mark - Action
- (void)randomAction:(id)sender {
    self.selectIndex = -1;
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.decorateArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PCCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCCategoryCell" forIndexPath:indexPath];
     
    [cell.imageView pc_setImageWithURL:self.decorateArray[indexPath.item] placeholderImage:nil];
    cell.iconLabel.text = ICON_HEART;
    cell.iconLabel.alpha = (self.selectIndex == indexPath.item) ? 1 : 0;
    
    return cell;
}
 
 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.selectIndex = indexPath.item;
}
 
#pragma mark - Get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 50) / 4, (SCREEN_WIDTH - 50) / 4);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10 + SafeAreaInsetsConstantForDeviceWithNotch.bottom, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
 
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColorWhite;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PCCategoryCell class] forCellWithReuseIdentifier:@"PCCategoryCell"];
 
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}
 
- (NSArray<NSString *> *)decorateArray {
    if (!_decorateArray) {
        _decorateArray = [PCUser characterImageArray];
    }
    return _decorateArray;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    [kPCUserDefaults setInteger:selectIndex forKey:PC_CHAT_AVATAR_CHARACTER];
    [self.collectionView reloadData];
}
 


@end
