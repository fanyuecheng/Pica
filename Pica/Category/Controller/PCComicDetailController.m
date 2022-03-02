//
//  PCComicDetailController.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicDetailController.h"
#import "PCComicDetailRequest.h"
#import "PCComicEpisodeRequest.h"
#import "PCComicSimilarRequest.h"
#import "PCComicInfoView.h"
#import "PCComicEpisodeView.h"
#import "PCComicHistory.h"
#import "PCComicPictureController.h"
#import "PCComicRecommendView.h"

@interface PCComicDetailController ()

@property (nonatomic, strong) PCComicRecommendView *recommendView;
@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, strong) PCComic *comic;
@property (nonatomic, strong) PCComicEpisodeRequest *episodeRequest;
@property (nonatomic, strong) PCComicSimilarRequest *similarRequest;
@property (nonatomic, strong) NSMutableArray <PCComicEpisode *> *episodeArray;
@property (nonatomic, copy)   NSArray <PCComic *> *similarArray;

@property (nonatomic, assign) BOOL continueReadTag;
 
@end

@implementation PCComicDetailController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}
 
- (instancetype)initWithComicId:(NSString *)comicId {
    if (self = [super init]) {
        self.comicId = [comicId copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComicDetail];
    [self requestComicEpisode];
    [self requestComicSimilar];
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    @weakify(self)
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        @strongify(self)
        PCComicEpisode *episode = self.episodeArray.firstObject;
        if (self.episodeRequest.page < episode.pages) {
            self.episodeRequest.page ++;
            [self requestComicEpisode];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

#pragma mark - Net
- (void)requestComicDetail {
    [self showEmptyViewWithLoading];
    
    PCComicDetailRequest *request = [[PCComicDetailRequest alloc] initWithComicId:self.comicId];
    
    [request sendRequest:^(PCComic *comic) {
        [self hideEmptyView];
        self.comic = comic;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComicDetail)];
    }];
}

- (void)requestComicEpisode {
    [self.episodeRequest sendRequest:^(PCComicEpisode *episode) {
        [self hideEmptyView];
        [self.episodeArray addObject:episode];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        if (self.continueReadTag) {
            [self continuReadAction:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComicEpisode)];
    }];
}

- (void)requestComicSimilar {
    [self.similarRequest sendRequest:^(NSArray <PCComic *>* response) {
        self.similarArray = response;
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - Action
- (void)continuReadAction:(QMUIButton *)sender {
    PCComic *comic = [kPCComicHistory comicWithId:self.comicId];
    
    PCComicEpisode *historyList = nil;
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.episodeArray.count; i++) {
        PCComicEpisode *list = self.episodeArray[i];
        for (NSInteger j = 0; j < list.docs.count; j++) {
            PCEpisode *ep = list.docs[j];
            if ([ep.episodeId isEqualToString:comic.historyEpisodeId]) {
                historyList = list;
                index = j;
                break;
            }
        }
        if (historyList) {
            break;
        }
    }
    
    if (historyList) {
        PCComicPictureController *picture = [[PCComicPictureController alloc] initWithComicId:self.comicId];
        picture.episodeArray = historyList.docs;
        picture.index = index;
        picture.historyEpisodePage = comic.historyEpisodePage;
        picture.historyEpisodeIndex = comic.historyEpisodeIndex;
        [self.navigationController pushViewController:picture animated:YES];
    } else {
        self.continueReadTag = YES;
        self.episodeRequest.page ++;
        [self requestComicEpisode];
    }
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.episodeArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    PCComicEpisodeView *episodeView = [cell.contentView viewWithTag:1000];
    if (!episodeView) {
        episodeView = [[PCComicEpisodeView alloc] init];
        episodeView.tag = 1000;
        [cell.contentView addSubview:episodeView];
    }
    episodeView.episode = self.episodeArray[indexPath.row];
    episodeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComicEpisodeView *episodeView = [[PCComicEpisodeView alloc] init];
    episodeView.episode = self.episodeArray[indexPath.row];
    
    return [episodeView sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        PCComic *comic = [kPCComicHistory comicWithId:self.comicId];
        return (comic.historyEpisodeTitle &&
                comic.historyEpisodeId) ? 44 : 0;
    } else {
        return self.similarArray.count ? self.recommendView.qmui_height : CGFLOAT_MIN;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        PCComic *comic = [kPCComicHistory comicWithId:self.comicId];
        if ((comic.historyEpisodeTitle &&
             comic.historyEpisodeId)) {
            QMUIButton *button = [[QMUIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            button.backgroundColor = UIColorWhite;
            [button setTitle:[NSString stringWithFormat:@"续看 %@", comic.historyEpisodeTitle] forState:UIControlStateNormal];
            button.titleLabel.font = UIFontMake(14);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button addTarget:self action:@selector(continuReadAction:) forControlEvents:UIControlEventTouchUpInside];
            return button;
        } else {
            return nil;
        }
    } else {
        return self.similarArray.count ? self.recommendView : nil;
    }
}

#pragma mark - Method
- (UIView *)tableHeaderView {
    PCComicInfoView *infoView = [[PCComicInfoView alloc] init];
    infoView.comic = self.comic;
    infoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    
    UIView *header = [[UIView alloc] initWithFrame:infoView.bounds];
    [header addSubview:infoView];
    
    return header;
}
 
#pragma mark - Get
- (NSMutableArray<PCComicEpisode *> *)episodeArray {
    if (!_episodeArray) {
        _episodeArray = [NSMutableArray array];
    }
    return _episodeArray;
}

- (PCComicEpisodeRequest *)episodeRequest {
    if (!_episodeRequest) {
        _episodeRequest = [[PCComicEpisodeRequest alloc] initWithComicId:self.comicId];
    }
    return _episodeRequest;
}

- (PCComicSimilarRequest *)similarRequest {
    if (!_similarRequest) {
        _similarRequest = [[PCComicSimilarRequest alloc] initWithComicId:self.comicId];
    }
    return _similarRequest;
}

- (PCComicRecommendView *)recommendView {
    if (!_recommendView) {
        _recommendView = [[PCComicRecommendView alloc] init];
    }
    return _recommendView;
}

#pragma mark - Set
- (void)setComic:(PCComic *)comic {
    _comic = comic;
    
    self.title = comic.title;
    self.tableView.tableHeaderView = [self tableHeaderView]; 
}

- (void)setSimilarArray:(NSArray<PCComic *> *)similarArray {
    _similarArray = similarArray;
    self.recommendView.comicArray = similarArray;
    [self.recommendView sizeToFit];
    [self.tableView reloadData];
}


@end
