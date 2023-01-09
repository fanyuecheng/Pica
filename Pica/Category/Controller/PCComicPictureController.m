//
//  PCComicPictureController.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicPictureController.h"
#import "PCComicPictureRequest.h"
#import "PCPictureCell.h"
#import "PCComic.h"
#import "PCEpisode.h"
#import "PCLocalKeyHeader.h"
#import "PCComicHistory.h"
#import "PCImageSizeCache.h"
#import <WebKit/WebKit.h>

@interface PCComicPictureController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   <PCEpisodePicture *> *pictureArray;
@property (nonatomic, strong) PCComicPictureRequest *request;

@property (nonatomic, strong) PCComicPictureRequest *allImageRequest;
@property (nonatomic, strong) NSMutableArray <PCEpisodePicture *> *allPictureArray;

@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL onRequest;

@end

@implementation PCComicPictureController

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    if (parent == nil) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)].lastObject;
        PCEpisode *episode = self.episodeArray[self.index];
        PCComic *comic = [kPCComicHistory comicWithId:self.comicId];
        comic.historyEpisodeTitle = episode.title;
        comic.historyEpisodeId = episode.episodeId;
        comic.historyEpisodePage = indexPath.section + 1;
        if (indexPath) {
            comic.historyEpisodeIndex = indexPath.item;
        }
        [kPCComicHistory updateComic:comic];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)dealloc {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (instancetype)initWithComicId:(NSString *)comicId {
    if (self = [super init]) {
        _comicId = [comicId copy];
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
    UIBarButtonItem *item1 = [QMUIToolbarButton barButtonItemWithImage:[UIImage systemImageNamed:@"arrow.left"] target:self action:@selector(lastEpisode:)];
    UIBarButtonItem *item2 = [QMUIToolbarButton barButtonItemWithImage:[UIImage systemImageNamed:@"arrow.right"] target:self action:@selector(nextEpisode:)];
    item1.tintColor = UIColorBlack;
    item2.tintColor = UIColorBlack;
    self.toolbarItems = @[item1, flexibleItem, item2];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    BOOL isHorizontal = [kPCUserDefaults boolForKey:PC_READ_DIRECTION];
    
    self.navigationItem.rightBarButtonItems = @[[UIBarButtonItem qmui_itemWithTitle:isHorizontal ? @"横向" : @"竖向" target:self action:@selector(directionAction:)], [UIBarButtonItem qmui_itemWithTitle:@"导出" target:self action:@selector(exportAction:)]];
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

- (void)exportAction:(UIBarButtonItem *)sender {
    void (^exportBlock)(void) = ^{
        NSString *html = @"\
        <html>\
            <head>\
                <meta charset=\"utf-8\">\
                <meta name=\"viewport\" content=\"width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no\">\
                <title>EP_NAME</title>\
                <link rel=\"stylesheet\" href=\"https://m.bnman.net/themes/mip001/res/css/style.css\"type=\"text/css\">\
            </head>\
            <body>\
                    图片数组\
                <div class=\"foot\">\
                    <p>Copyright © Pica</p>\
                </div>\
            </body>\
        </html>";
        NSMutableString *image = [NSMutableString string];
        [self.allPictureArray enumerateObjectsUsingBlock:^(PCEpisodePicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.docs enumerateObjectsUsingBlock:^(PCPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [image appendFormat:@"<img src=\"%@\" width=\"100%%\">", obj.media.imageURL];
            }];
        }];
        html = [html stringByReplacingOccurrencesOfString:@"EP_NAME" withString:self.allPictureArray.firstObject.ep.title];
        html = [html stringByReplacingOccurrencesOfString:@"图片数组" withString:image];
        NSString *localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"comic_temp.html"];
        BOOL success = [html writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (success) {
            [MobClick event:PC_EVENT_COMIC_EXPORT];
            NSMutableArray *activityItems = [NSMutableArray array];
            [activityItems addObject:[NSURL fileURLWithPath:localPath]];
      
            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            if (IS_IPAD) {
                activity.popoverPresentationController.sourceView = self.view;
                activity.popoverPresentationController.sourceRect = CGRectMake(self.view.qmui_width * 0.5, self.view.qmui_height * 0.5, 1, 1);
                activity.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            }
            
            [[QMUIHelper visibleViewController] presentViewController:activity animated:YES completion:nil];
        }
    };
    
    if (self.allPictureArray.count) {
        exportBlock();
    } else {
        QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
        [self requestEpPicture:^(NSError *error) {
            [loading hideAnimated:NO];
            if (error) {
                 
            } else {
                exportBlock();
            }
        }];
    }
}
 
#pragma mark - Net
- (void)requestPicture {
    if (self.request.page < 1) {
        return;
    }
    QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
    self.onRequest = YES;
    [self.request sendRequest:^(PCEpisodePicture *picture) {
        self.onRequest = NO;
        [loading hideAnimated:YES];
        [self hideEmptyView];
        
        NSInteger page = picture.page;
        NSInteger pages = picture.pages;
        if (!self.pictureArray) {
            self.pictureArray = [NSMutableArray array];
            for (NSInteger i = 1; i <= pages; i++) {
                [self.pictureArray addObject:[PCEpisodePicture new]];
            }
        }
        [self.pictureArray replaceObjectAtIndex:page - 1 withObject:picture];
        if (self.historyEpisodeIndex) {
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.historyEpisodeIndex inSection:page - 1] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            self.historyEpisodeIndex = 0;
            self.historyEpisodePage = 0;
        } else {
            NSIndexPath *indexPath =  [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)].firstObject;
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    } failure:^(NSError * _Nonnull error) {
        self.onRequest = NO;
        [loading hideAnimated:YES];
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestPicture)];
    }];
}

- (void)requestEpPicture:(void (^)(NSError *error))finished {
    if (self.allImageRequest.page < 1) {
        return;
    }
    @weakify(self)
    [self.allImageRequest sendRequest:^(PCEpisodePicture *picture) {
        @strongify(self)
        NSInteger page = picture.page;
        NSInteger pages = picture.pages;
        [self.allPictureArray addObject:picture];
        if (page < pages) {
            self.allImageRequest.page ++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestEpPicture:finished];
            });
        } else {
            !finished ? : finished(nil);
        }
    } failure:^(NSError * _Nonnull error) {
        !finished ? : finished(error);
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
    self.pictureArray = nil;
    self.allImageRequest = nil;
    self.allPictureArray = nil;
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
    
    cell.loadBlock = ^(PCPicture * _Nonnull picture) {
        @strongify(self)
        NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForItem:[pictureArray indexOfObject:picture] inSection:indexPath.section];
        if ([self.navigationController.viewControllers containsObject:self]) {
            [collectionView reloadItemsAtIndexPaths:@[reloadIndexPath]];
        }
    };
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        PCPicture *picture = self.pictureArray[indexPath.section].docs[indexPath.item];
        CGSize size = [kPCImageSizeCache getImageSizeForKey:picture.media.imageURL];
        if (CGSizeIsEmpty(size)) {
            return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
        } else {
            return CGSizeMake(SCREEN_WIDTH, floorf(SCREEN_WIDTH * size.height / size.width));
        }
    } else {
        return collectionView.bounds.size;
    }
}

- (void)scrollViewDidScroll:(UICollectionView *)scrollView {
    if (scrollView.isDragging ||
        scrollView.isTracking ||
        scrollView.isDecelerating) {
        BOOL shouldRequest = self.pictureArray.firstObject.docs.count == 0 || self.pictureArray.lastObject.docs.count == 0;
        
        if (shouldRequest) {
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)scrollView.collectionViewLayout;
            BOOL scrollDirectionVertical = layout.scrollDirection == UICollectionViewScrollDirectionVertical;
            CGFloat contentOffset = scrollDirectionVertical ? scrollView.contentOffset.y : scrollView.contentOffset.x;
            CGFloat maxContentOffset = scrollDirectionVertical ? scrollView.contentSize.height : scrollView.contentSize.width;
            
            PCEpisodePicture *firstPicture = nil;
            PCEpisodePicture *lastPicture = nil;
            
            for (NSInteger i = 0; i < self.pictureArray.count; i ++) {
                PCEpisodePicture *picture = self.pictureArray[i];
                if (picture.docs.count == 0) {
                    continue;
                } else {
                    firstPicture = picture;
                    break;
                }
            }
            for (NSInteger i = self.pictureArray.count - 1; i >= 0; i --) {
                PCEpisodePicture *picture = self.pictureArray[i];
                if (picture.docs.count == 0) {
                    continue;
                } else {
                    lastPicture = picture;
                    break;
                }
            }

            if (contentOffset <= 0 &&
                self.pictureArray.firstObject.docs.count == 0 &&
                self.onRequest == NO) {
                self.request.page = firstPicture.page - 1;
                [self requestPicture];
            } else if (contentOffset + (scrollDirectionVertical ? scrollView.qmui_height : scrollView.qmui_width) >= maxContentOffset && self.pictureArray.lastObject.docs.count == 0 && self.onRequest == NO) {
                self.request.page = lastPicture.page + 1;
                [self requestPicture];
            }
        }
    }
}
 
#pragma mark - Get
- (PCComicPictureRequest *)request {
    if (!_request) {
        if (self.episodeArray) {
            PCEpisode *ep = self.episodeArray[self.index];
            _request = [[PCComicPictureRequest alloc] initWithComicId:self.comicId order:ep.order];
            if (self.historyEpisodePage) {
                _request.page = self.historyEpisodePage;
            }
        }
    }
    return _request;
}

- (PCComicPictureRequest *)allImageRequest {
    if (!_allImageRequest) {
        if (self.episodeArray) {
            PCEpisode *ep = self.episodeArray[self.index];
            _allImageRequest = [[PCComicPictureRequest alloc] initWithComicId:self.comicId order:ep.order];
        }
    }
    return _allImageRequest;
}

- (NSMutableArray<PCEpisodePicture *> *)allPictureArray {
    if (!_allPictureArray) {
        _allPictureArray = [NSMutableArray array];
    }
    return _allPictureArray;
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
    NSLog(@"⚠️内存警告⚠️ %@", self);
}

@end
