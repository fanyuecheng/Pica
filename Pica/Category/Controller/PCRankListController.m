//
//  PCRankListController.m
//  Pica
//
//  Created by YueCheng on 2021/5/24.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRankListController.h"
#import "PCComicsRankRequest.h"
#import "PCKnightRankRequest.h"
#import "PCComicsRankCell.h"
#import "PCKnightRankCell.h"
#import "PCComicsDetailController.h"
#import "PCComicsListController.h"
#import "PCDatabase.h"

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
    
    [self.tableView registerClass:[PCComicsRankCell class] forCellReuseIdentifier:@"PCComicsRankCell"];
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
        PCComicsRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCComicsRankCell" forIndexPath:indexPath];
        [cell setComics:self.dataSource[indexPath.row] index:indexPath.row];
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
        PCComicsListController *list = [[PCComicsListController alloc] initWithType:PCComicsListTypeSearch];
        list.keyword = user.name;
        controller = list;
    } else {
        PCComics *comics = self.dataSource[indexPath.row];
        [[PCDatabase sharedInstance] saveComic:comics];
        controller = [[PCComicsDetailController alloc] initWithComicsId:comics.comicsId];
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
                _request = [[PCComicsRankRequest alloc] initWithType:PCComicsRankTypeH24];
                break;
            case PCRankListTypeD7:
                _request = [[PCComicsRankRequest alloc] initWithType:PCComicsRankTypeD7];
                break;
            case PCRankListTypeD30:
                _request = [[PCComicsRankRequest alloc] initWithType:PCComicsRankTypeD30];
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
