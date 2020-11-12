//
//  PCComicsListController.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicsListController.h"
#import "PCComicsRequest.h"
#import "PCSearchRequest.h"
#import "PCComicsListCell.h"
#import "PCComicsDetailController.h"

@interface PCComicsListController ()

@property (nonatomic, copy)   NSString *category;
@property (nonatomic, copy)   NSString *keyword;
@property (nonatomic, strong) PCComicsRequest *categoryRequest;
@property (nonatomic, strong) PCSearchRequest *searchRequest;
@property (nonatomic, strong) NSMutableArray <PCComicsList *>*comicsArray;

@end

@implementation PCComicsListController

- (instancetype)initWithCategory:(NSString *)category {
    if (self = [super init]) {
        self.category = [category copy];
        self.comicsArray = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithKeyword:(NSString *)keyword {
    if (self = [super init]) {
        self.keyword = [keyword copy];
        self.comicsArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComics];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"新到旧" target:self action:@selector(sortAction:)];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = self.category ? self.category : self.keyword;
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCComicsListCell class] forCellReuseIdentifier:@"PCComicsListCell"];
    self.tableView.rowHeight = 130;
    @weakify(self)
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        @strongify(self) 
        PCComicsList *list = self.comicsArray.lastObject;
        if (list.page < list.pages) {
            if (self.keyword) {
                self.searchRequest.page ++;
            } else {
                self.categoryRequest.page ++;
            }
            [self requestComics];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}
 
#pragma mark - Action
- (void)sortAction:(id)sender {
    NSDictionary *sorts = @{ @"新到旧" : @"dd",
                             @"旧到新" : @"da",
                             @"爱心数" : @"ld",
                             @"翻牌数" : @"vd"};
    NSString *sort = self.keyword ? self.searchRequest.sort : self.categoryRequest.s;
     
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
        
        if (self.keyword) {
            self.searchRequest.sort = value;
            self.searchRequest.page = 1;
        } else {
            self.categoryRequest.s = value;
            self.categoryRequest.page = 1;
        }
        [self requestComics];
        [controller hideWithAnimated:YES completion:nil];
    }];
    [dialogViewController show];
}

#pragma mark - Net
- (void)requestComics {
    if (self.keyword) {
        [self requestSearchComics];
    } else {
        [self requestCategoryComics];
    }
}

- (void)requestCategoryComics {
    if (self.categoryRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.categoryRequest sendRequest:^(PCComicsList *list) {
        [self hideEmptyView];
        [self.tableView.mj_footer endRefreshing];
        if (self.categoryRequest.page == 1) {
            [self.comicsArray removeAllObjects];
        }
        [self.comicsArray addObject:list];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestCategoryComics)];
    }];
}

- (void)requestSearchComics {
    if (self.searchRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.searchRequest sendRequest:^(PCComicsList *list) {
        [self hideEmptyView];
        [self.tableView.mj_footer endRefreshing];
        if (self.searchRequest.page == 1) {
            [self.comicsArray removeAllObjects];
        }
        [self.comicsArray addObject:list];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(searchRequest)];
    }];
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
}

#pragma mark - Get
- (PCComicsRequest *)categoryRequest {
    if (!_categoryRequest) {
        _categoryRequest = [[PCComicsRequest alloc] init];
        _categoryRequest.c = self.category;
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

@end
