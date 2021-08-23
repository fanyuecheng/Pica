//
//  PCCategoryController.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategoryController.h"
#import "PCCategoryRequest.h"
#import "PCKeywordRequest.h"
#import "PCCategoryCell.h"
#import "PCKeywordCell.h"
#import "NSString+PCAdd.h"
#import "PCComicsListController.h"
#import "PCComicsRankController.h"
#import "PCCommentController.h"
#import "PCSearchRequest.h"
#import "PCIconHeader.h"
#import "PCSearchRecordView.h"
#import <SafariServices/SafariServices.h>

@interface PCCategoryController () <UICollectionViewDelegate, UICollectionViewDataSource, QMUITextFieldDelegate>

@property (nonatomic, copy)   NSArray <NSString *>   *keywordArray;
@property (nonatomic, copy)   NSArray <PCCategory *> *categoryArray;

@property (nonatomic, strong) PCSearchRecordView *recordView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) QMUITextField    *textField;

@end

@implementation PCCategoryController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestKeyword];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.collectionView];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.textField];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, SCREEN_WIDTH, SCREEN_HEIGHT - self.qmui_navigationBarMaxYInViewCoordinator - self.qmui_tabBarSpacingInViewCoordinator);
    if (self.recordView.superview) {
        self.recordView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, SCREEN_WIDTH, SCREEN_HEIGHT - self.qmui_navigationBarMaxYInViewCoordinator - [QMUIKeyboardManager visibleKeyboardHeight]);
    }
}

#pragma mark - Request
- (void)requestKeyword {
    [self showEmptyViewWithLoading];
    PCKeywordRequest *request = [[PCKeywordRequest alloc] init];
    [request sendRequest:^(NSArray *keywordArray) {
        self.keywordArray = keywordArray;
        [self requestCategory];
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestKeyword)];
    }];
}

- (void)requestCategory {
    PCCategoryRequest *request = [[PCCategoryRequest alloc] init];
    [request sendRequest:^(NSArray *responseArray) {
        [self hideEmptyView];
        NSMutableArray *categoryArray = [NSMutableArray array];
        [categoryArray addObject:[PCCategory rankCategory]];
        [categoryArray addObject:[PCCategory randomCategory]];
        [categoryArray addObject:[PCCategory commentCategory]];
        [categoryArray addObjectsFromArray:responseArray];
        self.categoryArray = categoryArray;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestCategory)];
    }];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.keywordArray.count : self.categoryArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PCKeywordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCKeywordCell" forIndexPath:indexPath];
        cell.keyword = self.keywordArray[indexPath.item];;
        return cell;
    } else {
        PCCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCCategoryCell" forIndexPath:indexPath];
        cell.category = self.categoryArray[indexPath.item];
        return cell;
    }
}
 
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PCCategoryHeader" forIndexPath:indexPath];
        
        QMUILabel *tltleLabel = [header viewWithTag:1000];
        if (!tltleLabel) {
            tltleLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(15) textColor:UIColorBlue];
            tltleLabel.tag = 1000;
            tltleLabel.frame = CGRectMake(10, 0, SCREEN_WIDTH - 20, 40);
            [header addSubview:tltleLabel]; 
        }
        tltleLabel.text = indexPath.section == 0 ? @"大家都在搜" : @"热门分类";
        return header;
    } else {
        return nil;
    }
}
 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *keyword = self.keywordArray[indexPath.item];
        return CGSizeMake([keyword pc_widthForFont:UIFontMake(14)] + 20, 26);
    } else {
        CGFloat itemWidth = floorf((SCREEN_WIDTH - 40) / 3);
        return CGSizeMake(itemWidth, itemWidth + 20);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *keyword = self.keywordArray[indexPath.item];
        PCComicsListController *list = [[PCComicsListController alloc] initWithType:PCComicsListTypeSearch];
        list.keyword = keyword;
        [self.navigationController pushViewController:list animated:YES];
    } else {
        UIViewController *controller = nil;
        PCCategory *category = self.categoryArray[indexPath.item];
        
        if (category.isWeb) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:category.link]];
            [self presentViewController:safari animated:YES completion:nil];
            return;
        } else if (category.isCustom) {
            if ([category.controllerClass isEqualToString:@"PCComicsRankController"] ||
                [category.controllerClass isEqualToString:@"PCComicsListController"]) {
                controller = [[NSClassFromString(category.controllerClass) alloc] init];
            } else if ([category.controllerClass isEqualToString:@"PCCommentController"]) {
                PCCommentController *comment = [[PCCommentController alloc] initWithComicsId:PC_COMMENT_BOARD_ID];
                comment.commentType = PCCommentTypeComic;
                controller = comment;
            }
        } else {
            PCComicsListController *list = [[PCComicsListController alloc] initWithType:PCComicsListTypeCategory];
            list.keyword = category.title;
            controller = list;
        }
        if (controller) {
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length) {
        [textField resignFirstResponder];
        PCComicsListController *list = [[PCComicsListController alloc] initWithType:PCComicsListTypeSearch];
        list.keyword = textField.text;
        [self.navigationController pushViewController:list animated:YES];
        [self.recordView saveSearchKey:textField.text];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.recordView.recordCount) {
        [self.view addSubview:self.recordView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.recordView.superview) {
        [self.recordView removeFromSuperview];
    }
}

#pragma mark - Set
- (void)setKeywordArray:(NSArray<NSString *> *)keywordArray {
    _keywordArray = [keywordArray copy];
    [self.collectionView reloadData];
}

- (void)setCategoryArray:(NSArray<PCCategory *> *)categoryArray {
    _categoryArray = [categoryArray copy];
    [self.collectionView reloadData];
}

#pragma mark - Get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10 + SafeAreaInsetsConstantForDeviceWithNotch.bottom, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
 
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColorWhite;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PCCategoryCell class] forCellWithReuseIdentifier:@"PCCategoryCell"];
        [_collectionView registerClass:[PCKeywordCell class] forCellWithReuseIdentifier:@"PCKeywordCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PCCategoryHeader"];
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (QMUITextField *)textField {
    if (!_textField) {
        _textField = [[QMUITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 30)];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.placeholder = @"搜索";
        _textField.returnKeyType = UIReturnKeySearch;
        QMUILabel *leftView = [[QMUILabel alloc] qmui_initWithFont:[UIFont fontWithName:@"iconfont" size:14] textColor:UIColorPlaceholder];
        leftView.text = ICON_SEARCH;
        leftView.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [leftView sizeToFit];
        _textField.leftView = leftView;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.delegate = self;
    }
    return _textField;
}

- (PCSearchRecordView *)recordView {
    if (!_recordView) {
        _recordView = [[PCSearchRecordView alloc] init];
    }
    return _recordView;
}

@end
