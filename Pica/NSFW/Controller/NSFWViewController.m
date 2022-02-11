//
//  NSFWViewController.m
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "NSFWViewController.h"
#import "NSFWSourceRequest.h"
#import "NSFWBrowerViewController.h"
#import <SafariServices/SafariServices.h>

@interface NSFWViewController ()

@property (nonatomic, strong) NSFWSourceRequest *request;
@property (nonatomic, strong) NSFWBrowerViewController *browerController;

@end

@implementation NSFWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestData];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"NSFW";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"关于" target:self action:@selector(detailAction:)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.browerController) {
        self.browerController.view.frame = self.view.bounds;
    }
}

#pragma mark - Action
- (void)detailAction:(id)sender {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/EBazarov/nsfw_data_source_urls"]];
    [self presentViewController:safari animated:YES completion:nil];
}

#pragma mark - Net
- (void)requestData {
    [self showEmptyViewWithLoading:YES image:nil text:@"正在下载资源" detailText:nil buttonTitle:nil buttonAction:NULL];
    
    if ([self.request downloaded]) {
        [self configList];
    } else {
        [self.request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
            [self configList];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [self showEmptyViewWithText:@"请求失败" detailText:request.error.domain buttonTitle:@"重新请求" buttonAction:@selector(requestData)];
        }];
    }
}

#pragma mark - Method
- (void)configList {
    [self hideEmptyView];
    if ([self.request downloaded]) {
        NSString *path = self.request.rootDirectory;
        NSFWBrowerViewController *brower = [[NSFWBrowerViewController alloc] initWithPath:path];
        [self addChildViewController:brower];
        [self.view addSubview:brower.view];
        [brower didMoveToParentViewController:self];
        self.browerController = brower;
    }
}

#pragma mark - Get
- (NSFWSourceRequest *)request {
    if (!_request) {
        _request = [[NSFWSourceRequest alloc] init];
        @weakify(self)
        _request.resumableDownloadProgressBlock = ^(NSProgress *progress) {
            @strongify(self)
            NSLog(@"%@", [NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress.fractionCompleted >= 1) {
                    [self showEmptyViewWithLoading:YES image:nil text:@"解压文件中..." detailText:nil buttonTitle:nil buttonAction:NULL];
                } else {
                    [self showEmptyViewWithLoading:YES image:nil text:[NSString stringWithFormat:@"正在下载资源 %.1f%%", progress.fractionCompleted * 100] detailText:[NSString stringWithFormat:@"进度：%@/%@", @(progress.completedUnitCount), @(progress.totalUnitCount)] buttonTitle:nil buttonAction:NULL];
                }
            });
        };
    }
    return _request;
}

@end
