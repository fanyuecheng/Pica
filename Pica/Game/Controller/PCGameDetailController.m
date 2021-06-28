//
//  PCGameDetailController.m
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCGameDetailController.h"
#import "PCGameDetailRequest.h"
#import "PCGame.h"
#import "PCGameInfoView.h"
#import "PCContentCell.h"

@interface PCGameDetailController ()

@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, strong) PCGame *game;
@property (nonatomic, strong) PCGameDetailRequest *request;

@end

@implementation PCGameDetailController

- (instancetype)initWithGameId:(NSString *)gameId {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.gameId = gameId; 
    }
    return self;
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"游戏介绍";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestGameDetail];
}

- (void)initTableView {
    [super initTableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColorWhite;
    [self.tableView registerClass:[PCContentCell class] forCellReuseIdentifier:@"PCContentCell"];
}

#pragma mark - Net
- (void)requestGameDetail {
    [self showEmptyViewWithLoading];
    
    @weakify(self)
    [self.request sendRequest:^(PCGame *game) {
        @strongify(self)
        [self hideEmptyView];
        self.game = game;
    } failure:^(NSError * _Nonnull error) {
        @strongify(self)
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestGameDetail)];
    }];
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.game ? 2 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCContentCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.game.updateContent.length ? self.game.updateContent : @"null";
    } else {
        cell.textLabel.text = self.game.desc.length ? self.game.desc : @"null";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView qmui_heightForCellWithIdentifier:@"PCContentCell" configuration:^(PCContentCell *cell) { 
        if (indexPath.section == 0) {
            cell.textLabel.text = self.game.updateContent.length ? self.game.updateContent : @"null";
        } else {
            cell.textLabel.text = self.game.desc.length ? self.game.desc : @"null";
        }
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QMUILabel *header = [[QMUILabel alloc] qmui_initWithFont:UIFontBoldMake(13) textColor:PCColorPink];
    header.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    header.text = section == 0 ? [NSString stringWithFormat:@"最新更新 %@", self.game.version] : @"游戏介绍";
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - Set
- (void)setGame:(PCGame *)game {
    _game = game;
    
    PCGameInfoView *header = [[PCGameInfoView alloc] init];
    header.game = game;
    header.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    self.tableView.tableHeaderView = header;
    [self.tableView reloadData];
}

#pragma mark - Get
- (PCGameDetailRequest *)request {
    if (!_request) {
        if (self.gameId) {
            _request = [[PCGameDetailRequest alloc] init];
            _request.gameId = self.gameId;
        }
    }
    return _request;
}

@end
