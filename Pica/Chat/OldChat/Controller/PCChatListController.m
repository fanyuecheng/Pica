//
//  PCChatListController.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatListController.h"
#import "PCChatListRequest.h"
#import "PCChatRoom.h"
#import "PCChatRoomCell.h"
#import "PCChatViewController.h"

@interface PCChatListController ()

@property (nonatomic, strong) PCChatListRequest *request;
@property (nonatomic, copy)   NSArray *roomArray;

@end

@implementation PCChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestList];
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCChatRoomCell class] forCellReuseIdentifier:@"PCChatRoomCell"];
    self.tableView.rowHeight = 100;
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"聊天";
}

#pragma mark - Net
- (void)requestList {
    [self showEmptyViewWithLoading];
    
    [self.request sendRequest:^(NSArray <PCChatRoom *>* roomArray) {
        [self hideEmptyView];
        self.roomArray = roomArray;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestList)];
    }];
}
 
#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCChatRoomCell" forIndexPath:indexPath];
    cell.room = self.roomArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCChatRoom *room = self.roomArray[indexPath.row];
    [MobClick event:PC_EVENT_CHATROOM_CLICK attributes:@{@"title" : room.title}];
    PCChatViewController *chat = [[PCChatViewController alloc] initWithURL:room.socketUrl];
    chat.title = room.title;
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
- (void)setRoomArray:(NSArray *)roomArray {
    _roomArray = roomArray;
    
    [self.tableView reloadData];
}

@end
