//
//  PCComicsDetailController.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsDetailController.h"
#import "PCComicsDetailRequest.h"
#import "PCComicsEpisodeRequest.h"
#import "PCComicsInfoView.h"
#import "PCComicsEpisodeView.h"

@interface PCComicsDetailController ()

@property (nonatomic, copy)   NSString *comicsId;
@property (nonatomic, strong) PCComics *comics;
@property (nonatomic, strong) PCComicsEpisode *episode;
 
@end

@implementation PCComicsDetailController

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        self.comicsId = [comicsId copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComicsDetail];
    [self requestComicsEpisode];
}

#pragma mark - Net
- (void)requestComicsDetail {
    [self showEmptyViewWithLoading];
    
    PCComicsDetailRequest *request = [[PCComicsDetailRequest alloc] initWithComicsId:self.comicsId];
    
    [request sendRequest:^(PCComics *comics) {
        [self hideEmptyView];
        self.comics = comics;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComicsDetail)];
    }];
}

- (void)requestComicsEpisode {
    PCComicsEpisodeRequest *request = [[PCComicsEpisodeRequest alloc] initWithComicsId:self.comicsId];
    
    [request sendRequest:^(PCComicsEpisode *episode) {
        [self hideEmptyView];
        self.episode = episode;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComicsEpisode)];
    }];
}

#pragma mark - Method
- (UIView *)tableHeaderView {
    PCComicsInfoView *infoView = [[PCComicsInfoView alloc] init];
    infoView.comics = self.comics;
    infoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    
    UIView *header = [[UIView alloc] initWithFrame:infoView.bounds];
    [header addSubview:infoView];
    
    return header;
}

- (UIView *)tableFooterView {
    PCComicsEpisodeView *episodeView = [[PCComicsEpisodeView alloc] init];
    episodeView.episode = self.episode;
    episodeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, episodeView.qmui_bottom + 44)];
    [footer addSubview:episodeView];
    
    return footer;
}

#pragma mark - Set
- (void)setComics:(PCComics *)comics {
    _comics = comics;
    
    self.title = comics.title;
    self.tableView.tableHeaderView = [self tableHeaderView]; 
}
 
- (void)setEpisode:(PCComicsEpisode *)episode {
    _episode = episode;
    self.tableView.tableFooterView = [self tableFooterView];
}

@end
