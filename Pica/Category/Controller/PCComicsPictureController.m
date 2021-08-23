//
//  PCComicsPictureController.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsPictureController.h"
#import "PCComicsPictureRequest.h"
#import "PCPictureCell.h"
#import "PCEpisode.h"
#import "PCLocalKeyHeader.h"

@interface PCComicsPictureController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   <PCEpisodePicture *> *pictureArray;
@property (nonatomic, strong) PCComicsPictureRequest *request;

@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL onRequest;

@end

@implementation PCComicsPictureController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)dealloc {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        _comicsId = [comicsId copy];
        _navigationBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestPicture];
}

- (void)setupToolbarItems {
    [super setupToolbarItems];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    UIBarButtonItem *item1 = [QMUIToolbarButton barButtonItemWithType:QMUIToolbarButtonTypeNormal title:@"上一话" target:self action:@selector(lastEpisode:)];
    UIBarButtonItem *item2 = [QMUIToolbarButton barButtonItemWithType:QMUIToolbarButtonTypeNormal title:@"下一话" target:self action:@selector(nextEpisode:)];
    self.toolbarItems = @[item1, flexibleItem, item2];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    BOOL isHorizontal = [kPCUserDefaults boolForKey:PC_READ_DIRECTION];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:isHorizontal ? @"横向" : @"竖向" target:self action:@selector(directionAction:)];
}

- (void)initSubviews {
    [super initSubviews];
    
    self.view.backgroundColor = UIColorBlack;
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, StatusBarHeightConstant, SCREEN_WIDTH, SCREEN_HEIGHT - StatusBarHeightConstant - SafeAreaInsetsConstantForDeviceWithNotch.bottom);
}

- (void)directionAction:(UIBarButtonItem *)sender {
    BOOL isHorizontal = [kPCUserDefaults boolForKey:PC_READ_DIRECTION];
    isHorizontal = !isHorizontal;
    sender.title = isHorizontal ? @"横向" : @"竖向";
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = isHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    self.collectionView.pagingEnabled = isHorizontal;
    
    [kPCUserDefaults setBool:isHorizontal forKey:PC_READ_DIRECTION];
}
 
#pragma mark - Net
- (void)requestPicture {
    if (self.request.page == 1) {
        [self showEmptyView];
    }
    self.onRequest = YES;
    [self.request sendRequest:^(PCEpisodePicture *picture) {
        self.onRequest = NO;
        [self hideEmptyView];
        [self.pictureArray addObject:picture];
        [self.collectionView reloadData];
    } failure:^(NSError * _Nonnull error) {
        self.onRequest = NO;
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestPicture)];
    }];
}

#pragma mark - Action
- (void)lastEpisode:(id)sender {
    self.index --;
    if (self.index < 0) {
        self.index ++;
        [QMUITips showInfo:@"已经是最后一话啦"];
        return;
    }
    
    [self requestNewEpisode];
}
 
- (void)nextEpisode:(id)sender {
    self.index ++;
    if (self.index >= self.episodeArray.count) {
        self.index --;
        [QMUITips showInfo:@"已经是最新话啦"];
        return;
    }
    
    [self requestNewEpisode];
}

- (void)requestNewEpisode {
    self.request = nil;
    [self.pictureArray removeAllObjects];
    [self.collectionView reloadData];
    [self.collectionView qmui_scrollToTop];
    [self requestPicture];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.pictureArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray[section].docs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PCPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCPictureCell" forIndexPath:indexPath];
    
    NSArray *pictureArray = self.pictureArray[indexPath.section].docs;
    
    cell.loadBlock = ^(PCPicture * _Nonnull picture) {
        NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForItem:[pictureArray indexOfObject:picture] inSection:indexPath.section];
        if ([self.navigationController.viewControllers containsObject:self]) {
            [collectionView reloadItemsAtIndexPaths:@[reloadIndexPath]];
        }
    };
    
    cell.picture = pictureArray[indexPath.item];
 
    @weakify(self)
    cell.clickBlock = ^{
        @strongify(self)
        self.navigationBarHidden = !self.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:YES];
        if (self.episodeArray.count > 1) {
            [self.navigationController setToolbarHidden:self.navigationBarHidden animated:YES];
        }
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGSize size = self.pictureArray[indexPath.section].docs[indexPath.item].preferSize;
        if (!size.width || !size.height) {
            return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
        } else {
            return size;
        }
    } else {
        return collectionView.bounds.size;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PCEpisodePicture *picture = self.pictureArray.lastObject;
    
    if (indexPath.section == self.pictureArray.count - 1 &&
        indexPath.item == picture.docs.count - 1 &&
        picture.page < picture.pages &&
        self.onRequest == NO) {
        self.request.page ++;
        [self requestPicture];
    }
}
 
#pragma mark - Get
- (PCComicsPictureRequest *)request {
    if (!_request) {
        if (self.episodeArray) {
            PCEpisode *ep = self.episodeArray[self.index];
            _request = [[PCComicsPictureRequest alloc] initWithComicsId:self.comicsId order:ep.order];
        }
    }
    return _request;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
         
        BOOL isHorizontal = [kPCUserDefaults boolForKey:PC_READ_DIRECTION];
        
        layout.scrollDirection = isHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.pagingEnabled = isHorizontal;
        _collectionView.backgroundColor = UIColorBlack;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PCPictureCell class] forCellWithReuseIdentifier:@"PCPictureCell"];
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (NSMutableArray<PCEpisodePicture *> *)pictureArray {
    if (!_pictureArray) {
        _pictureArray = [NSMutableArray array];
    }
    return _pictureArray;
}

#pragma mark - NavigationBar
- (BOOL)prefersStatusBarHidden {
    return self.navigationBarHidden;
}
 
- (BOOL)preferredNavigationBarHidden {
    return self.navigationBarHidden;
}

- (BOOL)forceEnableInteractivePopGestureRecognizer {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDImageCache sharedImageCache] clearMemory];
    NSLog(@"⚠️内存警告⚠️");
}

@end
