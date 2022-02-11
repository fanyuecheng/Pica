//
//  NSFWImageViewController.m
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "NSFWImageViewController.h"
#import "NSFWImage.h"
#import "PCLocalKeyHeader.h"
#import "UIViewController+PCAdd.h"
 
@interface NSFWImageViewController () <QMUIImagePreviewViewDelegate, QMUIZoomImageViewDelegate>

@property (nonatomic, copy)   NSString *path;
@property (nonatomic, strong) NSMutableArray <NSFWImage *>*dataSource;
@property (nonatomic, strong) QMUIImagePreviewView *previewView;

@property (nonatomic, strong) NSMutableArray <NSString *>*invalidArray;

@end

@implementation NSFWImageViewController

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        self.path = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
 
- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.previewView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.previewView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, self.view.qmui_width, self.view.qmui_height - self.qmui_navigationBarMaxYInViewCoordinator);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = [NSString stringWithFormat:@"1/%@", @(self.dataSource.count)];
}

#pragma mark - QMUIImagePreviewViewDelegate
- (NSUInteger)numberOfImagesInImagePreviewView:(QMUIImagePreviewView *)imagePreviewView {
    return self.dataSource.count;
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    zoomImageView.delegate = self;
    
    NSFWImage *image = self.dataSource[index];
    if (image.image) {
        [zoomImageView hideEmptyView];
        zoomImageView.image = image.image;
    } else {
        [zoomImageView showLoading];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:image.url] options:SDWebImageRetryFailed | SDWebImageScaleDownLargeImages  progress:nil completed:^(UIImage * _Nullable img, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            [zoomImageView hideEmptyView];
            if (img) {
                zoomImageView.image = img;
                image.image = img;
            } else {
                [zoomImageView showEmptyViewWithText:error.localizedDescription];
                if ([error.userInfo[SDWebImageErrorDownloadStatusCodeKey] integerValue] == 400) {
                    [self.invalidArray addObject:imageURL.absoluteString];
                    [kPCUserDefaults setObject:self.invalidArray forKey:PC_NSFW_INVALID_URL];
                }
            }
        }];
    }
}
 
- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    return QMUIImagePreviewMediaTypeImage;
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    self.title = self.title = [NSString stringWithFormat:@"%@/%@", @(index + 1), @(self.dataSource.count)];
}

#pragma mark - QMUIZoomImageViewDelegate
- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView {
    if (zoomImageView.image == nil) {
        return;
    }
    [UIViewController pc_actionSheetWithTitle:@"保存图片到相册" message:nil confirm:^{
        QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(zoomImageView.image, nil, ^(QMUIAsset *asset, NSError *error) {
            if (asset) {
                [QMUITips showSucceed:@"已保存到相册"];
            }
        });
    } cancel:nil];
}

#pragma mark - Get
- (void)setPath:(NSString *)path {
    _path = path;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *array = [json componentsSeparatedByString:@"\n"];
        if (array.count) {
            [self.dataSource removeAllObjects];
            for (NSString *url in array) {
                if (url.length && ![self.invalidArray containsObject:url]) {
                    NSFWImage *image = [[NSFWImage alloc] init];
                    image.url = url;
                    [self.dataSource addObject:image];
                }
            }
        }
    }
    [self.previewView.collectionView reloadData];
}

- (NSMutableArray<NSFWImage *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (QMUIImagePreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[QMUIImagePreviewView alloc] init];
        _previewView.delegate = self;
        _previewView.backgroundColor = UIColorBlack;
    }
    return _previewView;
}

- (NSMutableArray<NSString *> *)invalidArray {
    if (!_invalidArray) {
        _invalidArray = [NSMutableArray array];
        NSArray *invalidArray = [kPCUserDefaults objectForKey:PC_NSFW_INVALID_URL];
        if (invalidArray.count) {
            [_invalidArray addObjectsFromArray:invalidArray];
        }
    }
    return _invalidArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDImageCache sharedImageCache] clearMemory];
    NSLog(@"⚠️内存警告⚠️ %@", self);
}

@end
