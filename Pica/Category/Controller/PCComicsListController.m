//
//  PCComicsListController.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsListController.h"
#import "PCRandomRequest.h"
#import "PCComicsRequest.h"
#import "PCSearchRequest.h"
#import "PCFavouriteComicsRequest.h"
#import "PCComicsListCell.h"
#import "PCComicsDetailController.h"
#import "PCComicHistory.h"

@interface PCComicsListController ()

@property (nonatomic, assign) PCComicsListType type;
@property (nonatomic, strong) PCComicsRequest *categoryRequest;
@property (nonatomic, strong) PCSearchRequest *searchRequest;
@property (nonatomic, strong) PCRandomRequest *randomRequest;
@property (nonatomic, strong) PCFavouriteComicsRequest *favouriteRequest;
@property (nonatomic, strong) NSMutableArray <PCComicsList *>*comicsArray;

@end

@implementation PCComicsListController

- (instancetype)initWithType:(PCComicsListType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComics];
    
    switch (self.type) {
        case PCComicsListTypeHistory:
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
            break;
        default:
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"新到旧" target:self action:@selector(sortAction:)];
            break;
    }
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    switch (self.type) {
        case PCComicsListTypeHistory:
            self.title = @"浏览历史";
            break;
        case PCComicsListTypeRandom:
            self.title = @"随机本子";
            break;
        case PCComicsListTypeFavourite:
            self.title = @"我的收藏";
            break;
        default:
            self.title = self.keyword;
            break;
    }
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCComicsListCell class] forCellReuseIdentifier:@"PCComicsListCell"];
    self.tableView.rowHeight = 130;
     
    if (self.type != PCComicsListTypeRandom) {
        @weakify(self)
        self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            @strongify(self)
            PCComicsList *list = self.comicsArray.lastObject;
            if (list.page < list.pages) {
                switch (self.type) {
                    case PCComicsListTypeSearch:
                        self.searchRequest.page ++;
                        break;
                    case PCComicsListTypeCategory:
                        self.categoryRequest.page ++;
                        break;
                    case PCComicsListTypeFavourite:
                        self.favouriteRequest.page ++;
                        break;
                    default:
                        break;
                }
               
                [self requestComics];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
}
 
#pragma mark - Action
- (void)deleteAction:(id)sender {
    if (self.comicsArray.firstObject.docs.count == 0) {
        return;
    }
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [[PCComicHistory sharedInstance] clearAllComic];
        self.comicsArray.firstObject.docs = @[];
        [self.tableView reloadData];
        [self showEmptyViewWithText:@"没有任何本子" detailText:nil buttonTitle:nil buttonAction:NULL];
    }];
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"确认清除浏览记录?" message:nil preferredStyle:QMUIAlertControllerStyleAlert];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

- (void)sortAction:(id)sender {
    NSDictionary *sorts = @{ @"新到旧" : @"dd",
                             @"旧到新" : @"da",
                             @"爱心数" : @"ld",
                             @"翻牌数" : @"vd"};
    NSString *sort = nil;
    switch (self.type) {
        case PCComicsListTypeSearch:
            sort = self.searchRequest.sort;
            break;
        case PCComicsListTypeCategory:
            sort = self.categoryRequest.s;
            break;
        case PCComicsListTypeFavourite:
            sort = self.favouriteRequest.s;
            break;
        default:
            break;
    }
    
    QMUIDialogSelectionViewController *dialogViewController = [[QMUIDialogSelectionViewController alloc] init];
    dialogViewController.selectedItemIndex = [sorts.allValues indexOfObject:sort];
    dialogViewController.title = @"排序方式";
    dialogViewController.items = sorts.allKeys;
    [dialogViewController addCancelButtonWithText:@"取消" block:nil];
    [dialogViewController addSubmitButtonWithText:@"确定" block:^(QMUIDialogSelectionViewController *controller) {
        NSInteger index = controller.selectedItemIndex;
        NSString *key = sorts.allKeys[index];
        NSString *value = [sorts valueForKey:key];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:key target:self action:@selector(sortAction:)];
        
        switch (self.type) {
            case PCComicsListTypeSearch:
                self.searchRequest.sort = value;
                self.searchRequest.page = 1;
                break;
            case PCComicsListTypeCategory:
                self.categoryRequest.s = value;
                self.categoryRequest.page = 1;
                break;
            case PCComicsListTypeFavourite:
                self.favouriteRequest.s = value;
                self.favouriteRequest.page = 1;
                break;
            default:
                break;
        }
        [self requestComics];
        [controller hideWithAnimated:YES completion:nil];
    }];
    [dialogViewController show];
}

#pragma mark - Net
- (void)requestComics {
    switch (self.type) {
        case PCComicsListTypeHistory:
            [self requestHistoryComics];
            break;
        case PCComicsListTypeRandom:
            [self requestRandomComics];
            break;
        case PCComicsListTypeSearch:
            [self requestSearchComics];
            break;
        case PCComicsListTypeCategory:
            [self requestCategoryComics];
            break;
        case PCComicsListTypeFavourite:
            [self requestFavouriteComics];
            break;
        default:
            break;
    }
}

- (void)requestHistoryComics {
    PCComicsList *list = [[PCComicsList alloc] init];
    list.page = 1;
    list.pages = 1;
    list.docs = [[PCComicHistory sharedInstance] allComic];
    list.total = list.docs.count;
    [self requestFinishedWithList:list];
}

- (void)requestFavouriteComics {
    if (self.favouriteRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.favouriteRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestCategoryComics {
    if (self.categoryRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.categoryRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestSearchComics {
    if (self.searchRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.searchRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestRandomComics {
    [self showEmptyViewWithLoading];
    
    [self.randomRequest sendRequest:^(PCComicsList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestFinishedWithList:(PCComicsList *)list {
    switch (self.type) {
        case PCComicsListTypeSearch:
            if (self.searchRequest.page == 1) {
                [self.comicsArray removeAllObjects];
            }
            break;
        case PCComicsListTypeCategory:
            if (self.categoryRequest.page == 1) {
                [self.comicsArray removeAllObjects];
            }
            break;
        default:
            break;
    }
    
    [self hideEmptyView];
    [self.tableView.mj_footer endRefreshing];
    [self.comicsArray addObject:list];
    [self.tableView reloadData];
    if (list.page == 1 && list.docs.count == 0) {
        [self showEmptyViewWithText:@"没有任何本子" detailText:nil buttonTitle:nil buttonAction:NULL];
    }
}

- (void)requestFinishedWithError:(NSError *)error {
    SEL sel = NULL;
    switch (self.type) {
        case PCComicsListTypeRandom:
            sel = @selector(requestRandomComics);
            break;
        case PCComicsListTypeSearch:
            sel = @selector(searchRequest);
            break;
        case PCComicsListTypeCategory:
            sel = @selector(requestCategoryComics);
            break;
        default:
            break;
    }
    [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:sel];
}


#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.comicsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comicsArray[section].docs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComicsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCComicsListCell" forIndexPath:indexPath];
    cell.comics = self.comicsArray[indexPath.section].docs[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCComics *comics = self.comicsArray[indexPath.section].docs[indexPath.row];
    
    PCComicsDetailController *detail = [[PCComicsDetailController alloc] initWithComicsId:comics.comicsId];
    [self.navigationController pushViewController:detail animated:YES];
    [[PCComicHistory sharedInstance] saveComic:comics];
}

#pragma mark - Get
- (NSMutableArray<PCComicsList *> *)comicsArray {
    if (!_comicsArray) {
        _comicsArray = [NSMutableArray array];
    }
    return _comicsArray;
}

- (PCComicsRequest *)categoryRequest {
    if (!_categoryRequest) {
        _categoryRequest = [[PCComicsRequest alloc] init];
        _categoryRequest.c = self.keyword;
    }
    return _categoryRequest;
}

- (PCSearchRequest *)searchRequest {
    if (!_searchRequest) {
        _searchRequest = [[PCSearchRequest alloc] init];
        _searchRequest.keyword = self.keyword;
    }
    return _searchRequest;
}

- (PCRandomRequest *)randomRequest {
    if (!_randomRequest) {
        _randomRequest = [[PCRandomRequest alloc] init];
    }
    return _randomRequest;
}

- (PCFavouriteComicsRequest *)favouriteRequest {
    if (!_favouriteRequest) {
        _favouriteRequest = [[PCFavouriteComicsRequest alloc] init];
    }
    return _favouriteRequest;
}

@end
