//
//  PCComicDownloadListController.m
//  Pica
//
//  Created by AogeFF on 2026/07/04.
//  Copyright © 2026 fancy. All rights reserved.
//

#import "PCComicDownloadListController.h"
#import "PCDownloadCell.h"
#import "PCDownloadManager.h"
#import "PCComicDownload.h"
#import "PCComicDownloadDetailController.h"

@interface PCComicDownloadListController ()

@property (nonatomic, strong) NSArray<PCComicDownload *> *records;
@property (nonatomic, copy)   void(^scrollCallback)(UIScrollView *scrollView);

@end

@implementation PCComicDownloadListController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.scrollCallback = nil;
}

- (instancetype)init {
    return [super initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(reloadFromDB) name:PCDownloadDidEnqueueNotification object:nil];
    [nc addObserver:self selector:@selector(reloadFromDB) name:PCDownloadDidChangeStatusNotification object:nil];
    [nc addObserver:self selector:@selector(reloadFromDB) name:PCDownloadDidCompleteComicNotification object:nil];
    [nc addObserver:self selector:@selector(reloadFromDB) name:PCDownloadDidDeleteComicNotification object:nil];
    // 进度通知不整表刷新，交给 cell 内部按 comicId 局部更新

    [self reloadFromDB];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFromDB];
}

- (void)initTableView {
    [super initTableView];

    [self.tableView registerClass:[PCDownloadCell class] forCellReuseIdentifier:@"PCDownloadCell"];
    self.tableView.rowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - Data

- (void)reloadFromDB {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.records = [kPCDownloadManager allDownloadsSortedByCreatedAtDesc];
        [self.tableView reloadData];
        [self updateEmptyState];
    });
}

- (void)updateEmptyState {
    if (self.records.count == 0) {
        [self showEmptyViewWithText:@"还没有下载的漫画" detailText:nil buttonTitle:nil buttonAction:NULL];
    } else {
        [self hideEmptyView];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCDownloadCell" forIndexPath:indexPath];
    PCComicDownload *record = self.records[indexPath.row];
    [cell configureWithRecord:record];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PCComicDownload *record = self.records[indexPath.row];
    PCComicDownloadDetailController *detail = [[PCComicDownloadDetailController alloc] initWithComicId:record.comicId];
    [[QMUIHelper visibleViewController].navigationController pushViewController:detail animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
      trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    if (indexPath.row >= self.records.count) return nil;
    PCComicDownload *record = self.records[indexPath.row];
    NSString *comicId = record.comicId;

    UIContextualAction *deleteAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleDestructive
                            title:@"删除"
                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        QMUIAlertAction *confirm = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [kPCDownloadManager deleteComicId:comicId];
            completionHandler(YES);
        }];
        QMUIAlertAction *cancel = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            completionHandler(NO);
        }];
        QMUIAlertController *alert = [QMUIAlertController alertControllerWithTitle:@"确认删除?"
                                                                            message:@"该本漫画的下载文件将全部清除"
                                                                     preferredStyle:QMUIAlertControllerStyleAlert];
        [alert addAction:confirm];
        [alert addAction:cancel];
        [alert showWithAnimated:YES];
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
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

@end
