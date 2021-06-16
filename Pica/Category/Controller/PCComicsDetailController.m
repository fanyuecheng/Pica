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
@property (nonatomic, strong) PCComicsEpisodeRequest *episodeRequest;
@property (nonatomic, strong) NSMutableArray <PCComicsEpisode *> *episodeArray;
 
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

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    @weakify(self)
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        @strongify(self)
        PCComicsEpisode *episode = self.episodeArray.firstObject;
        if (self.episodeRequest.page < episode.pages) {
            self.episodeRequest.page ++;
            [self requestComicsEpisode];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
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
    [self.episodeRequest sendRequest:^(PCComicsEpisode *episode) {
        [self hideEmptyView];
        [self.episodeArray addObject:episode];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComicsEpisode)];
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.episodeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    PCComicsEpisodeView *episodeView = [cell.contentView viewWithTag:1000];
    if (!episodeView) {
        episodeView = [[PCComicsEpisodeView alloc] init];
        episodeView.tag = 1000;
        [cell.contentView addSubview:episodeView];
    }
    episodeView.episode = self.episodeArray[indexPath.row];
    episodeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComicsEpisodeView *episodeView = [[PCComicsEpisodeView alloc] init];
    episodeView.episode = self.episodeArray[indexPath.row];
    
    return [episodeView sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height;
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
 
#pragma mark - Get
- (NSMutableArray<PCComicsEpisode *> *)episodeArray {
    if (!_episodeArray) {
        _episodeArray = [NSMutableArray array];
    }
    return _episodeArray;
}

- (PCComicsEpisodeRequest *)episodeRequest {
    if (!_episodeRequest) {
        _episodeRequest = [[PCComicsEpisodeRequest alloc] initWithComicsId:self.comicsId];
    }
    return _episodeRequest;
}

#pragma mark - Set
- (void)setComics:(PCComics *)comics {
    _comics = comics;
    
    self.title = comics.title;
    self.tableView.tableHeaderView = [self tableHeaderView]; 
}

@end
