//
//  PCRankListController.m
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRankListController.h"
#import "PCComicRankRequest.h"
#import "PCKnightRankRequest.h"
#import "PCComicRankCell.h"
#import "PCKnightRankCell.h"
#import "PCComicDetailController.h"
#import "PCComicListController.h"
#import "PCComicHistory.h"

@interface PCRankListController ()

@property (nonatomic, assign) PCRankListType type;
@property (nonatomic, strong) PCRequest      *request;
@property (nonatomic, copy)   NSArray        *dataSource;

@end

@implementation PCRankListController

- (instancetype)initWithType:(PCRankListType)type {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCComicRankCell class] forCellReuseIdentifier:@"PCComicRankCell"];
    [self.tableView registerClass:[PCKnightRankCell class] forCellReuseIdentifier:@"PCKnightRankCell"];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 35, 0, 15);
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == PCRankListTypeKnight) {
        PCKnightRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCKnightRankCell" forIndexPath:indexPath];
        [cell setUser:self.dataSource[indexPath.row] index:indexPath.row];
        return cell;
    } else {
        PCComicRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCComicRankCell" forIndexPath:indexPath];
        [cell setComic:self.dataSource[indexPath.row] index:indexPath.row];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.type == PCRankListTypeKnight) ? 100 : 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIViewController *controller = nil;
    if (self.type == PCRankListTypeKnight) {
        PCUser *user = self.dataSource[indexPath.row];
        PCComicListController *list = [[PCComicListController alloc] initWithType:PCComicListTypeCreator];
        list.keyword = user.userId;
        controller = list;
    } else {
        PCComic *comic = self.dataSource[indexPath.row];
        [kPCComicHistory saveComic:comic];
        controller = [[PCComicDetailController alloc] initWithComicId:comic.comicId];
    }
    [[QMUIHelper visibleViewController].navigationController pushViewController:controller animated:YES];
}

#pragma mark - Net
- (void)requestData {
    if (self.dataSource.count) {
        return;
    }
    [self showEmptyViewWithLoading];
    
    [self.request sendRequest:^(NSArray *response) {
        [self hideEmptyView];
        self.dataSource = response;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestData)];
    }];
}

#pragma mark - Get
- (PCRequest *)request {
    if (!_request) {
        switch (self.type) {
            case PCRankListTypeH24:
                _request = [[PCComicRankRequest alloc] initWithType:PCComicRankTypeH24];
                break;
            case PCRankListTypeD7:
                _request = [[PCComicRankRequest alloc] initWithType:PCComicRankTypeD7];
                break;
            case PCRankListTypeD30:
                _request = [[PCComicRankRequest alloc] initWithType:PCComicRankTypeD30];
                break;
            default:
                _request = [[PCKnightRankRequest alloc] init];
                break;
        }
    }
    return _request;
}
 
- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [self.tableView reloadData];
}

@end
