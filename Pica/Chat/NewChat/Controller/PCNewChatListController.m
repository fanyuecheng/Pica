//
//  PCNewChatListController.m
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatListController.h"
#import "PCLocalKeyHeader.h"
#import "PCNewChatRoomCell.h"
#import "PCLoginController.h"
#import "PCNewChatRoomRequest.h"
#import "PCNewChatViewController.h"

@interface PCNewChatListController ()

@property (nonatomic, strong) PCLoginController *loginController;
@property (nonatomic, copy)   NSArray <PCNewChatRoom *> *roomArray;

@end

@implementation PCNewChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([kPCUserDefaults stringForKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN]) {
        [self requestRoomList];
    } else {
        [self configtLoginController];
    }
}

- (void)configtLoginController {
    self.loginController.view.frame = CGRectMake(0, 0, self.view.qmui_width, self.view.qmui_width);
    [self addChildViewController:self.loginController];
    self.tableView.tableHeaderView = self.loginController.view;
    [self.loginController didMoveToParentViewController:self];
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCNewChatRoomCell class] forCellReuseIdentifier:@"PCNewChatRoomCell"];
    self.tableView.rowHeight = 100;
}

#pragma mark - Net
- (void)requestRoomList {
    PCNewChatRoomRequest *request = [[PCNewChatRoomRequest alloc] init];
    [request sendRequest:^(id  _Nonnull response) {
        self.roomArray = response;
    } failure:^(NSError * _Nonnull error) {
        [kPCUserDefaults removeObjectForKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN];
        [self configtLoginController];
    }];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomArray.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCNewChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCNewChatRoomCell" forIndexPath:indexPath];
    cell.room = self.roomArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCNewChatRoom *room = self.roomArray[indexPath.row];
    [MobClick event:PC_EVENT_CHATROOM_CLICK attributes:@{@"title" : room.title}];
    PCNewChatViewController *chat = [[PCNewChatViewController alloc] initWithRoomId:room.roomId];
    chat.title = room.title;
    [self.navigationController pushViewController:chat animated:YES];
}

#pragma mark - Get
- (PCLoginController *)loginController {
    if (!_loginController) {
        _loginController = [[PCLoginController alloc] init];
        _loginController.isNewChatLogin = YES;
        @weakify(self)
        _loginController.loginBlock = ^(BOOL isNewChatLogin) {
            @strongify(self)
            [self requestRoomList];
        };
    }
    return _loginController;
}
 
#pragma mark - Set
- (void)setRoomArray:(NSArray<PCNewChatRoom *> *)roomArray {
    _roomArray = roomArray;
    
    self.tableView.tableHeaderView = nil;
    [self.tableView reloadData];
}

@end
