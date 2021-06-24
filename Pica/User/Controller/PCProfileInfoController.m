//
//  PCProfileInfoController.m
//  Pica
//
//  Created by YueCheng on 2021/5/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCProfileInfoController.h"
#import "PCComicsListController.h"
#import "PCComicsDetailController.h"
#import "PCUserCommentRequest.h"
#import "PCComment.h"
#import "PCCommentCell.h"

@interface PCProfileInfoController ()

@property (nonatomic, assign) PCProfileInfoType type;
@property (nonatomic, copy)   void(^scrollCallback)(UIScrollView *scrollView);
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) PCUserCommentRequest *commentRequest;
 
@end

@implementation PCProfileInfoController

- (void)dealloc {
    self.scrollCallback = nil;
}

- (instancetype)initWithType:(PCProfileInfoType)type {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestData];
}

- (void)initTableView {
    [super initTableView];
     
    [self.tableView registerClass:[QMUITableViewCell class] forCellReuseIdentifier:@"QMUITableViewCell"];
    if (self.type == PCProfileInfoTypeComment) {
        [self.tableView registerClass:[PCCommentCell class] forCellReuseIdentifier:@"PCCommentCell"];
        
        @weakify(self)
        self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            @strongify(self) 
            PCComicsComment *comment = self.dataSource.lastObject;
            if (comment.page < comment.pages) {
                self.commentRequest.page ++;
                [self requestComment];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
}

#pragma mark - Net
- (void)requestData {
    switch (self.type) {
        case PCProfileInfoTypeComic:
             
            break;
        case PCProfileInfoTypeComment:
            [self requestComment];
            break;
        default:
            break;
    }
}
 
- (void)requestComment {
    if (self.commentRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.commentRequest sendRequest:^(PCComicsComment *comment) {
        [self hideEmptyView];
        [self.tableView.mj_footer endRefreshing];
        [self.dataSource addObject:comment];
        [self.tableView reloadData];
        if (comment.total == 0) {
            [self showEmptyViewWithText:@"您还没有任何评论" detailText:nil buttonTitle:nil buttonAction:NULL];
        }
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComment)];
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.type) {
        case PCProfileInfoTypeComic:
            return 1;
            break;
        case PCProfileInfoTypeComment:{
            return self.dataSource.count;
            break;}
        default:
            return 0;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.type) {
        case PCProfileInfoTypeComic:
            return self.dataSource.count;
            break;
        case PCProfileInfoTypeComment:{
            PCComicsComment *comment = self.dataSource[section];
            return comment.docs.count;
            break;}
        default:
            return 0;
            break;
    } 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == PCProfileInfoTypeComic) {
        QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMUITableViewCell" forIndexPath:indexPath];
        cell.textLabel.text = self.dataSource[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        PCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCCommentCell" forIndexPath:indexPath];
        PCComicsComment *comment = self.dataSource[indexPath.section];
        PCComment *commentObject = comment.docs[indexPath.row];
        if (!commentObject.user) {
            commentObject.user = [PCUser localUser];
        }
        cell.comment = commentObject;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == PCProfileInfoTypeComic) {
        return 44;
    } else {
        return [tableView qmui_heightForCellWithIdentifier:@"PCCommentCell" configuration:^(PCCommentCell *cell) {
            PCComicsComment *comment = self.dataSource[indexPath.section];
            cell.comment = comment.docs[indexPath.row];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.type == PCProfileInfoTypeComic) {
        PCComicsListController *comicsList = [[PCComicsListController alloc] initWithType:indexPath.row == 0 ? PCComicsListTypeFavourite : PCComicsListTypeHistory];
        
        [[QMUIHelper visibleViewController].navigationController pushViewController:comicsList animated:YES];
    } else {
        PCComicsComment *commentList = self.dataSource[indexPath.section];
        PCComment *comment = commentList.docs[indexPath.row];
        PCComicsDetailController *detail = [[PCComicsDetailController alloc] initWithComicsId:comment.comic.comicsId];
        [[QMUIHelper visibleViewController].navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - JXPagerViewListViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

#pragma mark - ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.scrollCallback ? : self.scrollCallback(scrollView);
}

#pragma mark - Get
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        if (self.type == PCProfileInfoTypeComic) {
            [_dataSource addObject:@"我收藏的本子"];
            [_dataSource addObject:@"我浏览的本子"];
        }
    }
    return _dataSource;
}

- (PCUserCommentRequest *)commentRequest {
    if (!_commentRequest) {
        _commentRequest = [[PCUserCommentRequest alloc] init];
    }
    return _commentRequest;
}

@end
