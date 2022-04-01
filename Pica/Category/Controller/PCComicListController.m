//
//  PCComicListController.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicListController.h"
#import "PCRandomRequest.h"
#import "PCComicRequest.h"
#import "PCSearchRequest.h"
#import "PCFavouriteComicRequest.h"
#import "PCComicListCell.h"
#import "PCComicDetailController.h"
#import "PCComicHistory.h"
#import "PCComicCollectionRequest.h"

@interface PCComicListController ()

@property (nonatomic, assign) PCComicListType type;
@property (nonatomic, strong) PCComicRequest *categoryRequest;
@property (nonatomic, strong) PCSearchRequest *searchRequest;
@property (nonatomic, strong) PCRandomRequest *randomRequest;
@property (nonatomic, strong) PCFavouriteComicRequest *favouriteRequest;
@property (nonatomic, strong) PCComicCollectionRequest *collectionRequest;
@property (nonatomic, strong) NSMutableArray <PCComicList *>*comicArray;

@end

@implementation PCComicListController

- (instancetype)initWithType:(PCComicListType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComics];
    
    switch (self.type) {
        case PCComicListTypeHistory:
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
            break;
        case PCComicListTypeSearch:
            [MobClick event:PC_EVENT_SEARCH attributes:@{@"keyword" : self.keyword}];
            break;
        case PCComicListTypeRecommend:
        case PCComicListTypeRandom:
            break;
        default:
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"新到旧" target:self action:@selector(sortAction:)];
            break;
    }
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    switch (self.type) {
        case PCComicListTypeHistory:
            self.title = @"浏览历史";
            break;
        case PCComicListTypeRandom:
            self.title = @"随机本子";
            break;
        case PCComicListTypeFavourite:
            self.title = @"我的收藏";
            break;
        case PCComicListTypeRecommend:
            self.title = @"本子推荐";
            break;
        default:
            self.title = self.keyword;
            break;
    }
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCComicListCell class] forCellReuseIdentifier:@"PCComicListCell"];
    self.tableView.rowHeight = 130;
     
    if (self.type != PCComicListTypeRandom && self.type != PCComicListTypeRecommend) {
        @weakify(self)
        self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            @strongify(self)
            PCComicList *list = self.comicArray.lastObject;
            if (list.page < list.pages) {
                switch (self.type) {
                    case PCComicListTypeSearch:
                        self.searchRequest.page ++;
                        break;
                    case PCComicListTypeTag:
                    case PCComicListTypeTranslate:
                    case PCComicListTypeCreator:
                    case PCComicListTypeAuthor:
                    case PCComicListTypeCategory:
                        self.categoryRequest.page ++;
                        break;
                    case PCComicListTypeFavourite:
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
    if (self.comicArray.firstObject.docs.count == 0) {
        return;
    }
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [kPCComicHistory clearAllComic];
        self.comicArray.firstObject.docs = @[];
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
        case PCComicListTypeSearch:
            sort = self.searchRequest.sort;
            break;
        case PCComicListTypeTag:
        case PCComicListTypeTranslate:
        case PCComicListTypeCreator:
        case PCComicListTypeAuthor:
        case PCComicListTypeCategory:
            sort = self.categoryRequest.s;
            break;
        case PCComicListTypeFavourite:
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
            case PCComicListTypeSearch:
                self.searchRequest.sort = value;
                self.searchRequest.page = 1;
                break;
            case PCComicListTypeTag:
            case PCComicListTypeTranslate:
            case PCComicListTypeCreator:
            case PCComicListTypeAuthor:
            case PCComicListTypeCategory:
                self.categoryRequest.s = value;
                self.categoryRequest.page = 1;
                break;
            case PCComicListTypeFavourite:
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
        case PCComicListTypeHistory:
            [self requestHistoryComics];
            break;
        case PCComicListTypeRandom:
            [self requestRandomComics];
            break;
        case PCComicListTypeSearch:
            [self requestSearchComics];
            break;
        case PCComicListTypeFavourite:
            [self requestFavouriteComics];
            break;
        case PCComicListTypeRecommend:
            [self requestRecommendComics];
            break;
        case PCComicListTypeTag:
        case PCComicListTypeTranslate:
        case PCComicListTypeCreator:
        case PCComicListTypeAuthor:
        case PCComicListTypeCategory:
            [self requestCategoryComics];
            break;
        default:
            break;
    }
}

- (void)requestHistoryComics {
    PCComicList *list = [[PCComicList alloc] init];
    list.page = 1;
    list.pages = 1;
    list.docs = [kPCComicHistory allComic];
    list.total = list.docs.count;
    [self requestFinishedWithList:list];
}

- (void)requestRecommendComics {
    [self showEmptyViewWithLoading];
 
    [self.collectionRequest sendRequest:^(NSArray *response) {
        [self hideEmptyView];
        [self.comicArray addObjectsFromArray:response];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestFavouriteComics {
    if (self.favouriteRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.favouriteRequest sendRequest:^(PCComicList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestCategoryComics {
    if (self.categoryRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }

    switch (self.type) {
        case PCComicListTypeTranslate:
            self.categoryRequest.ct = self.keyword;
            break;
        case PCComicListTypeTag:
            self.categoryRequest.t = self.keyword;
            break;
        case PCComicListTypeCreator:
            self.categoryRequest.ca = self.keyword;
            break;
        case PCComicListTypeAuthor:
            self.categoryRequest.a = self.keyword;
            break;
        case PCComicListTypeCategory:
            self.categoryRequest.c = self.keyword;
            break;
        default:
            break;
    }
    
    [self.categoryRequest sendRequest:^(PCComicList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestSearchComics {
    if (self.searchRequest.page == 1) {
        [self showEmptyViewWithLoading];
    }
    
    [self.searchRequest sendRequest:^(PCComicList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestRandomComics {
    [self showEmptyViewWithLoading];
    
    [self.randomRequest sendRequest:^(PCComicList *list) {
        [self requestFinishedWithList:list];
    } failure:^(NSError * _Nonnull error) {
        [self requestFinishedWithError:error];
    }];
}

- (void)requestFinishedWithList:(PCComicList *)list {
    switch (self.type) {
        case PCComicListTypeSearch:
            if (self.searchRequest.page == 1) {
                [self.comicArray removeAllObjects];
            }
            break;
        case PCComicListTypeTag:
        case PCComicListTypeTranslate:
        case PCComicListTypeCreator:
        case PCComicListTypeAuthor:
        case PCComicListTypeCategory:
            if (self.categoryRequest.page == 1) {
                [self.comicArray removeAllObjects];
            }
            break;
        default:
            break;
    }
    
    [self hideEmptyView];
    [self.tableView.mj_footer endRefreshing];
    [self.comicArray addObject:list];
    [self.tableView reloadData];
    if (list.page == 1 && list.docs.count == 0) {
        [self showEmptyViewWithText:@"没有任何本子" detailText:nil buttonTitle:nil buttonAction:NULL];
    }
}

- (void)requestFinishedWithError:(NSError *)error {
    SEL sel = NULL;
    switch (self.type) {
        case PCComicListTypeRandom:
            sel = @selector(requestRandomComics);
            break;
        case PCComicListTypeSearch:
            sel = @selector(searchRequest);
            break;
        case PCComicListTypeTag:
        case PCComicListTypeTranslate:
        case PCComicListTypeCreator:
        case PCComicListTypeAuthor:
        case PCComicListTypeCategory:
            sel = @selector(requestCategoryComics);
            break;
        case PCComicListTypeRecommend:
            sel = @selector(requestRecommendComics);
            break;
        default:
            break;
    }
    [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:sel];
}


#pragma mark - Table
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.type == PCComicListTypeRecommend && self.comicArray.count) {
        QMUILabel *header = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlue];
        header.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        header.backgroundColor = UIColorWhite;
        header.frame = CGRectMake(0, 0, tableView.qmui_width, 30);
        header.text = self.comicArray[section].title;
        return header;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.type == PCComicListTypeRecommend && self.comicArray.count  ) {
        return 30;
    } else {
        return CGFLOAT_MIN;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.comicArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comicArray[section].docs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCComicListCell" forIndexPath:indexPath];
    cell.comic = self.comicArray[indexPath.section].docs[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCComic *comic = self.comicArray[indexPath.section].docs[indexPath.row];
    
    PCComicDetailController *detail = [[PCComicDetailController alloc] initWithComicId:comic.comicId];
    [self.navigationController pushViewController:detail animated:YES];
    [kPCComicHistory saveComic:comic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComic *comic = self.comicArray[indexPath.section].docs[indexPath.row];
    return [tableView qmui_heightForCellWithIdentifier:@"PCComicListCell" cacheByKey:comic.comicId configuration:^(PCComicListCell *cell) {
        cell.comic = comic;
    }];
}

#pragma mark - Get
- (NSMutableArray<PCComicList *> *)comicArray {
    if (!_comicArray) {
        _comicArray = [NSMutableArray array];
    }
    return _comicArray;
}

- (PCComicRequest *)categoryRequest {
    if (!_categoryRequest) {
        _categoryRequest = [[PCComicRequest alloc] init];
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

- (PCFavouriteComicRequest *)favouriteRequest {
    if (!_favouriteRequest) {
        _favouriteRequest = [[PCFavouriteComicRequest alloc] init];
    }
    return _favouriteRequest;
}

- (PCComicCollectionRequest *)collectionRequest {
    if (!_collectionRequest) {
        _collectionRequest = [[PCComicCollectionRequest alloc] init];
    }
    return _collectionRequest;
}

@end
