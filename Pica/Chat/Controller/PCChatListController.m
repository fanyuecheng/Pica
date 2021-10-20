//
//  PCChatListController.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatListController.h"
#import "PCChatListRequest.h"
#import "PCChatList.h"
#import "PCChatListCell.h"
#import "PCChatViewController.h"

@interface PCChatListController ()

@property (nonatomic, strong) PCChatListRequest *request;
@property (nonatomic, copy)   NSArray *listArray;

@end

@implementation PCChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestList];
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCChatListCell class] forCellReuseIdentifier:@"PCChatListCell"];
    self.tableView.rowHeight = 100;
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"聊天室";
}

#pragma mark - Net
- (void)requestList {
    [self showEmptyViewWithLoading];
    
    [self.request sendRequest:^(NSArray <PCChatList *>* listArray) {
        [self hideEmptyView];
        self.listArray = listArray;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestList)];
    }];
}
 
#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCChatListCell" forIndexPath:indexPath];
    cell.list = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCChatList *list = self.listArray[indexPath.row];
    PCChatViewController *chat = [PCChatViewController chatViewControllerWithURL:list.socketUrl];
    chat.title = list.title;
    [self.navigationController pushViewController:chat animated:YES];
}

#pragma mark - Get
- (PCChatListRequest *)request {
    if (!_request) {
        _request = [[PCChatListRequest alloc] init];
    }
    return _request;
}

#pragma mark - Set
- (void)setListArray:(NSArray *)listArray {
    _listArray = listArray;
    
    [self.tableView reloadData];
}

@end
