//
//  PCCategoryController.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCategoryController.h"
#import "PCVersionCheckRequest.h"
#import "PCCategoryRequest.h"
#import "PCKeywordRequest.h"
#import "PCCategoryCell.h"
#import "PCKeywordCell.h"
#import "NSString+PCAdd.h"
#import "PCComicListController.h"
#import "PCComicRankController.h"
#import "PCCommentController.h"
#import "PCSearchRequest.h"
#import "PCIconHeader.h"
#import "PCSearchRecordView.h"
#import "PCAuthenticationController.h"
#import "PCNavigationController.h"
#import <SafariServices/SafariServices.h>

@interface PCCategoryController () <UICollectionViewDelegate, UICollectionViewDataSource, QMUITextFieldDelegate>

@property (nonatomic, copy)   NSArray <NSString *>   *keywordArray;
@property (nonatomic, copy)   NSArray <PCCategory *> *categoryArray;
@property (nonatomic, copy)   NSArray <PCCategory *> *comicArray;

@property (nonatomic, strong) PCSearchRecordView *recordView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) QMUITextField    *textField;
@property (nonatomic, strong) QMUIButton       *versionButton;

@end

@implementation PCCategoryController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestKeyword];
    
    [self requestVersion];
    
    if ([kPCUserDefaults boolForKey:PC_LOCAL_AUTHORIZATION]) {
        PCNavigationController *navigation = [[PCNavigationController alloc] initWithRootViewController:[[PCAuthenticationController alloc] init]];
        navigation.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigation animated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nsfwChange:) name:PC_NSFW_ON object:nil];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.versionButton];
    [self.view addSubview:self.collectionView];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.textField];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.view.qmui_width;
    CGFloat height = self.view.qmui_height;
    
    if (self.versionButton.hidden) {
        self.versionButton.frame = CGRectZero;
        self.collectionView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, width, height - self.qmui_navigationBarMaxYInViewCoordinator - self.qmui_tabBarSpacingInViewCoordinator);
    } else {
        self.versionButton.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, width, 30);
        self.collectionView.frame = CGRectMake(0, self.versionButton.qmui_bottom, width, height  - self.versionButton.qmui_bottom - self.qmui_tabBarSpacingInViewCoordinator);
    }
     
    if (self.recordView.superview) {
        self.recordView.frame = CGRectMake(0, self.qmui_navigationBarMaxYInViewCoordinator, SCREEN_WIDTH, SCREEN_HEIGHT - self.qmui_navigationBarMaxYInViewCoordinator - [QMUIKeyboardManager visibleKeyboardHeight]);
    }
}

#pragma mark - Notification
- (void)nsfwChange:(NSNotification *)noti {
    if (!self.categoryArray.count) {
        return;
    }
    BOOL on = [noti.object boolValue];
    NSMutableArray *categoryArray = [self.categoryArray mutableCopy];
    if (on) {
        [categoryArray insertObject:[PCCategory nsfwCategory] atIndex:0];
    } else {
        [categoryArray removeObjectAtIndex:0];
    }
    self.categoryArray = categoryArray;
    [self.collectionView reloadData];
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
        if ([kPCUserDefaults boolForKey:PC_NSFW_ON]) {
            [categoryArray addObject:[PCCategory nsfwCategory]];
        }
        [categoryArray addObject:[PCCategory rankCategory]];
        [categoryArray addObject:[PCCategory randomCategory]];
        [categoryArray addObject:[PCCategory recommendCategory]];
        [categoryArray addObject:[PCCategory commentCategory]];
        [categoryArray addObject:[PCCategory sanctuaryCategory]];
        [categoryArray addObjectsFromArray:responseArray];
        self.categoryArray = categoryArray;
    } failure:^(NSError * _Nonnull error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestCategory)];
    }];
}

- (void)requestVersion {
    PCVersionCheckRequest *request = [[PCVersionCheckRequest alloc] init];
    [request sendRequest:^(PCVersion *version) {
        if (version && version.isNewVersion) {
            [self.versionButton setTitle:[NSString stringWithFormat:@"Pica有新版本：%@ 点击查看", version.version] forState:UIControlStateNormal];
            self.versionButton.hidden = NO;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - Action
- (void)categoryAction:(QMUIButton *)sender {
    BOOL hidden = [kPCUserDefaults boolForKey:PC_CATEGORY_WEB_HIDDEN];
    [kPCUserDefaults setBool:!hidden forKey:PC_CATEGORY_WEB_HIDDEN];
    [kPCUserDefaults synchronize];
    [self.collectionView reloadData];
}

- (void)newVersionAction:(QMUIButton *)sender {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/fanyuecheng/Pica/releases"]];
    [self presentViewController:safari animated:YES completion:nil];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.keywordArray.count;
    } else {
        return [kPCUserDefaults boolForKey:PC_CATEGORY_WEB_HIDDEN] ? self.comicArray.count : self.categoryArray.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PCKeywordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCKeywordCell" forIndexPath:indexPath];
        cell.keyword = self.keywordArray[indexPath.item];;
        return cell;
    } else {
        PCCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCCategoryCell" forIndexPath:indexPath];
        NSArray *dataSource = [kPCUserDefaults boolForKey:PC_CATEGORY_WEB_HIDDEN] ? self.comicArray : self.categoryArray;
        cell.category = dataSource[indexPath.item];
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
        QMUIButton *actionButton = [header viewWithTag:1001];
        if (!actionButton) {
            actionButton = [[QMUIButton alloc] init];
            [actionButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
            actionButton.titleLabel.font = UIFontMake(15);
            actionButton.tag = 1001;
            [actionButton addTarget:self action:@selector(categoryAction:) forControlEvents:UIControlEventTouchUpInside];
            [header addSubview:actionButton];
        }
        [actionButton setTitle:indexPath.section == 0 ? @"" : ([kPCUserDefaults boolForKey:PC_CATEGORY_WEB_HIDDEN] ? @"显示网页分类" : @"隐藏网页分类") forState:UIControlStateNormal];
        [actionButton sizeToFit];
        actionButton.frame = indexPath.section == 0 ? CGRectZero : CGRectMake(SCREEN_WIDTH - 10 - actionButton.qmui_width, 0, actionButton.qmui_width, 40);
        
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
        return CGSizeMake(itemWidth, itemWidth + 30);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *keyword = self.keywordArray[indexPath.item];
        PCComicListController *list = [[PCComicListController alloc] initWithType:PCComicListTypeSearch];
        list.keyword = keyword;
        [self.navigationController pushViewController:list animated:YES];
    } else {
        UIViewController *controller = nil;
        NSArray *dataSource = [kPCUserDefaults boolForKey:PC_CATEGORY_WEB_HIDDEN] ? self.comicArray : self.categoryArray;
        PCCategory *category = dataSource[indexPath.item];
        
        if (category.isWeb) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:category.link]];
            [self presentViewController:safari animated:YES completion:nil];
            return;
        } else if (category.isCustom) {
            if ([category.controllerClass isEqualToString:@"PCComicRankController"]) {
                controller = [[NSClassFromString(category.controllerClass) alloc] init];
            } else if ([category.controllerClass isEqualToString:@"PCComicListController"]) {
                controller = [[PCComicListController alloc] initWithType:[category.categoryId integerValue]];
            } else if ([category.controllerClass isEqualToString:@"PCCommentController"]) {
                PCCommentController *comment = [[PCCommentController alloc] initWithComicId:PC_COMMENT_BOARD_ID];
                comment.commentType = PCCommentTypeComic;
                controller = comment;
            } else if ([category.controllerClass isEqualToString:@"NSFWViewController"]) {
                controller = [[NSClassFromString(category.controllerClass) alloc] init];
            }
        } else {
            PCComicListController *list = [[PCComicListController alloc] initWithType:PCComicListTypeCategory];
            list.keyword = category.title;
            controller = list;
        }
        if (controller) {
            [MobClick event:PC_EVENT_CATEGORY_CLICK attributes:@{@"title" : category.title}];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length) {
        [textField resignFirstResponder];
        PCComicListController *list = [[PCComicListController alloc] initWithType:PCComicListTypeSearch];
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
    NSMutableArray *comicArray = [NSMutableArray array];
    [_categoryArray enumerateObjectsUsingBlock:^(PCCategory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.isWeb) {
            [comicArray addObject:obj];
        }
    }];
    self.comicArray = comicArray;
    [self.collectionView reloadData];
}

#pragma mark - Get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 8;
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
        QMUILabel *leftView = [[QMUILabel alloc] qmui_initWithFont:[UIFont fontWithName:@"iconfont" size:15] textColor:UIColorPlaceholder];
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

- (QMUIButton *)versionButton {
    if (!_versionButton) {
        _versionButton = [[QMUIButton alloc] init];
        _versionButton.titleLabel.font = UIFontMake(12);
        _versionButton.imagePosition = QMUIButtonImagePositionRight;
        _versionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _versionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        _versionButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        [_versionButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_versionButton setImage:[UIImage qmui_imageWithShape:QMUIImageShapeDisclosureIndicator size:CGSizeMake(7, 13) tintColor:UIColorWhite] forState:UIControlStateNormal];
        _versionButton.backgroundColor = PCColorLightPink;
        _versionButton.hidden = YES;
        [_versionButton addTarget:self action:@selector(newVersionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _versionButton;
}
 
@end
