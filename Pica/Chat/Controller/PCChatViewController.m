//
//  PCChatViewController.m
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCChatViewController.h"
#import "PCChatManager.h"
#import "PCTextMessageCell.h"
#import "PCImageMessageCell.h"
#import "PCChatMessage.h"

@interface PCChatViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) PCChatManager *manager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation PCChatViewController

- (void)dealloc {
    [self.manager disconnect];
}

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self showEmptyViewWithLoading];
    [self connect];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat naviBottom = self.qmui_navigationBarMaxYInViewCoordinator;
    self.tableView.frame = CGRectMake(0, naviBottom, self.view.qmui_width, self.view.qmui_height - naviBottom);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"聊天室";
}

#pragma mark - Method
- (void)connect {
    [self.manager connect];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCChatMessage *message = self.messageArray[indexPath.row];
    if (message.messageType == PCChatMessageTypeDefault) {
        PCTextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCTextMessageCell" forIndexPath:indexPath];
        cell.message = message;
        return cell;
    } else if (message.messageType == PCChatMessageTypeImage) {
        PCImageMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCImageMessageCell" forIndexPath:indexPath];
        cell.message = message;
        return cell;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCChatMessage *message = self.messageArray[indexPath.row];
    if (message.messageType == PCChatMessageTypeDefault) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCTextMessageCell" configuration:^(PCTextMessageCell *cell) {
            cell.message = message;
        }];
    } else if (message.messageType == PCChatMessageTypeImage) {
        return [tableView qmui_heightForCellWithIdentifier:@"PCImageMessageCell" configuration:^(PCImageMessageCell *cell) {
            cell.message = message;
        }];
    }
    return 0;
}

#pragma mark - Get
- (PCChatManager *)manager {
    if (!_manager) {
        _manager = [[PCChatManager alloc] initWithURL:self.url];
         
        @weakify(self)
        _manager.messageBlock = ^(PCChatMessage * _Nonnull message) {
            @strongify(self)
            if (message) {
                if (message.messageType == PCChatMessageTypeDefault || message.messageType == PCChatMessageTypeImage) {
                    [self.messageArray addObject:message];
                    [self.tableView reloadData];
                } else if (message.messageType == PCChatMessageTypeConnectionCount) { 
                    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:[NSString stringWithFormat:@"在线人数:%@", @(message.connections)] target:nil action:NULL];
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                }
            }
        };
        
        _manager.stateBlock = ^(NSError * _Nonnull error) {
            @strongify(self)
            if (error) {
                [self showEmptyViewWithText:@"连接失败" detailText:error.domain buttonTitle:@"重新链接" buttonAction:@selector(connect)];
            } else {
                [self hideEmptyView];
            }
        };
    }
    return _manager;
}
 
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PCTextMessageCell class] forCellReuseIdentifier:@"PCTextMessageCell"];
        [_tableView registerClass:[PCImageMessageCell class] forCellReuseIdentifier:@"PCImageMessageCell"];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _tableView;
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

@end
