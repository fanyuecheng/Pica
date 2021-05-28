//
//  PCComicsCommentController.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsCommentController.h"
#import "PCCommentRequest.h"
#import "PCCommentCell.h"

@interface PCComicsCommentController ()

@property (nonatomic, copy)   NSString         *comicsId;
@property (nonatomic, strong) PCCommentRequest *request;
@property (nonatomic, strong) NSMutableArray <PCComicsComment *> *commentArray;

@end

@implementation PCComicsCommentController

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        _comicsId = [comicsId copy];
        _commentArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComment];
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCCommentCell class] forCellReuseIdentifier:@"PCCommentCell"];
    
    @weakify(self)
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        @strongify(self)
         
        PCComicsComment *comment = self.commentArray.lastObject;
        if (comment.page < comment.pages) {
            self.request.page ++;
            [self requestComment];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.commentArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentArray[section].docs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCCommentCell" forIndexPath:indexPath];
    cell.comment = self.commentArray[indexPath.section].docs[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView qmui_heightForCellWithIdentifier:@"PCCommentCell" configuration:^(PCCommentCell *cell) {
        cell.comment = self.commentArray[indexPath.section].docs[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Net
- (void)requestComment {
    if (self.request.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.request sendRequest:^(PCComicsComment *comment) {
        [self hideEmptyView];
        [self.tableView.mj_footer endRefreshing];
        [self.commentArray addObject:comment];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComment)];
    }];
}

#pragma mark - Get
- (PCCommentRequest *)request {
    if (!_request) {
        _request = [[PCCommentRequest alloc] initWithComicsId:self.comicsId];
    }
    return _request;
}

@end
