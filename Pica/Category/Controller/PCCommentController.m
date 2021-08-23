//
//  PCCommentController.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCommentController.h"
#import "PCCommentCell.h"
#import "PCCommentMainRequest.h"
#import "PCCommentChildRequest.h"
#import "PCCommentPublishRequest.h"

@interface PCCommentController () <QMUITextViewDelegate>

@property (nonatomic, assign) PCCommentPrimaryType primaryType; 
@property (nonatomic, copy)   NSString         *comicsId;
@property (nonatomic, copy)   NSString         *gameId;
@property (nonatomic, copy)   NSString         *commentId;
@property (nonatomic, strong) PCCommentMainRequest    *mainRequest;
@property (nonatomic, strong) PCCommentChildRequest   *childRequest;
@property (nonatomic, strong) PCCommentPublishRequest *publishRequest;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat inputHeight;
@property (nonatomic, strong) NSMutableArray <PCComicsComment *> *commentArray;

@property (nonatomic, strong) QMUITextView *textView;
@property (nonatomic, strong) QMUIButton *commentButton;
@property (nonatomic, strong) UIView *extensionView;

@end

@implementation PCCommentController
 
- (instancetype)initWithGameId:(NSString *)gameId {
    if (self = [super init]) {
        _commentType = PCCommentTypeGame;
        _primaryType = PCCommentPrimaryTypeMain;
        _gameId = [gameId copy];
        _commentArray = [NSMutableArray array];
        _inputHeight = 50;
    }
    return self;
}

- (instancetype)initWithCommentId:(NSString *)commentId {
    if (self = [super init]) {
        _primaryType = PCCommentPrimaryTypeChild;
        _commentId = [commentId copy];
        _commentArray = [NSMutableArray array];
        _inputHeight = 50;
    }
    return self;
}

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        _commentType = PCCommentTypeComic;
        _primaryType = PCCommentPrimaryTypeMain;
        _comicsId = [comicsId copy];
        _commentArray = [NSMutableArray array];
        _inputHeight = 50;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestComment];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    switch (self.primaryType) {
        case PCCommentPrimaryTypeMain:
            self.title = @"评论";
            break;
            
        default:
            self.title = @"子评论";
            break;
    }
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.commentButton];
    [self.view addSubview:self.extensionView];
}

- (void)initTableView {
    [super initTableView];
    
    [self.tableView registerClass:[PCCommentCell class] forCellReuseIdentifier:@"PCCommentCell"];
    
    self.tableView.contentInset = UIEdgeInsetsSetBottom(self.tableView.contentInset, self.tableView.contentInset.bottom + 50);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    @weakify(self)
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        @strongify(self)
         
        PCComicsComment *comment = self.commentArray.lastObject;
        if (self.primaryType == PCCommentPrimaryTypeMain) {
            if (self.mainRequest.page < comment.pages) {
                self.mainRequest.page ++;
                [self requestComment];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            if (self.childRequest.page < comment.pages) {
                self.childRequest.page ++;
                [self requestComment];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.textView.frame = CGRectMake(0, self.view.qmui_height - self.inputHeight - self.keyboardHeight - (self.keyboardHeight ? 0 : SafeAreaInsetsConstantForDeviceWithNotch.bottom), self.view.qmui_width, self.inputHeight);
    self.commentButton.frame = CGRectMake(self.textView.qmui_width - 60, self.textView.qmui_top + (self.textView.qmui_height - 40), 50, 30);
    self.extensionView.frame = CGRectMake(0, self.view.qmui_height -  SafeAreaInsetsConstantForDeviceWithNotch.bottom, self.view.qmui_width, SafeAreaInsetsConstantForDeviceWithNotch.bottom);
}

#pragma mark - Method
- (PCComment *)commentWithIndexPath:(NSIndexPath *)indexPath {
    PCComicsComment *list = self.commentArray.firstObject;
    PCComment *comment = nil;
    if (list.topComments.count) {
        if (indexPath.section == 0) {
            comment = list.topComments[indexPath.row];
        } else {
            comment = self.commentArray[indexPath.section - 1].docs[indexPath.row];
        }
    } else {
        comment = self.commentArray[indexPath.section].docs[indexPath.row];
    }
    return comment;
}

- (void)requestFinishedWithComment:(PCComicsComment *)comment
                             error:(NSError *)error {
    if (error) {
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestComment)];
    } else {
        [self hideEmptyView];
        [self.tableView.mj_footer endRefreshing];
        [self.commentArray addObject:comment];
        [self.tableView reloadData];
        if (comment.docs.count == 0) {
            [self showEmptyViewWithText:@"还没有任何评论哦" detailText:nil buttonTitle:nil buttonAction:NULL];
        }
    }
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    PCComicsComment *list = self.commentArray.firstObject;
    if (list.topComments.count) {
        return self.commentArray.count + 1;
    } else {
        return self.commentArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PCComicsComment *list = self.commentArray.firstObject;
    if (list.topComments.count) {
        if (section == 0) {
            return list.topComments.count;
        } else {
            return self.commentArray[section - 1].docs.count;
        }
    } else {
        return self.commentArray[section].docs.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCCommentCell" forIndexPath:indexPath];
    cell.comment = [self commentWithIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCComment *comment = [self commentWithIndexPath:indexPath];;
    return [tableView qmui_heightForCellWithIdentifier:@"PCCommentCell" cacheByKey:comment.commentId configuration:^(PCCommentCell *cell) {
        cell.comment = comment;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Net
- (void)requestComment {
    if (self.primaryType == PCCommentPrimaryTypeMain) {
        if (self.mainRequest.page == 1) {
            [self showEmptyViewWithLoading];
        }
        
        [self.mainRequest sendRequest:^(PCComicsComment *comment) {
            [self requestFinishedWithComment:comment error:nil];
        } failure:^(NSError * _Nonnull error) {
            [self requestFinishedWithComment:nil error:error];
        }];
    } else {
        if (self.childRequest.page == 1) {
            [self showEmptyViewWithLoading];
        }
        
        [self.childRequest sendRequest:^(PCComicsComment *comment) {
            [self requestFinishedWithComment:comment error:nil];
        } failure:^(NSError * _Nonnull error) {
            [self requestFinishedWithComment:nil error:error];
        }];
    }
}

- (void)publishComment {
    QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
    
    [self.publishRequest sendRequest:^(PCComment *comment) {
        [loading hideAnimated:NO];
        
        PCComicsComment *list = self.commentArray.firstObject;
        if (list.topComments.count) {
            NSMutableArray *topComments = [list.topComments mutableCopy];
            [topComments addObject:comment];
            list.topComments = topComments;
        } else {
            NSMutableArray *docs = [list.docs mutableCopy];
            [docs insertObject:comment atIndex:0];
            list.docs = docs;
        }
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [loading hideAnimated:NO];
    }];
}

#pragma mark - Action
- (void)commentAction:(QMUIButton *)sender {
    NSString *text = [self.textView.text qmui_trim];
    if (text.length) {
        self.textView.text = @"";
        [self.textView resignFirstResponder];
        self.publishRequest.content = text;
        [self publishComment];
    }
}

#pragma mark - TextView
- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height {
    if (height > 180) {
        
    } else if (height > 50) {
        self.inputHeight = height;
    } else {
        self.inputHeight = 50;
    }
}

#pragma mark - Get
- (PCCommentMainRequest *)mainRequest {
    if (!_mainRequest) {
        _mainRequest = [[PCCommentMainRequest alloc] initWithObjectId:self.commentType == PCCommentTypeComic ? self.comicsId : self.gameId];
        _mainRequest.type = self.commentType;
    }
    return _mainRequest;
}

- (PCCommentChildRequest *)childRequest {
    if (!_childRequest) {
        _childRequest = [[PCCommentChildRequest alloc] initWithCommentId:self.commentId];
        _childRequest.type = self.commentType;
    }
    return _childRequest;
}

- (PCCommentPublishRequest *)publishRequest {
    if (!_publishRequest) {
        if (self.primaryType == PCCommentPrimaryTypeMain) {
            if (self.commentType == PCCommentTypeComic) {
                _publishRequest = [[PCCommentPublishRequest alloc] initWithComicsId:self.comicsId];
            } else {
                _publishRequest = [[PCCommentPublishRequest alloc] initWithGameId:self.gameId];
            }
        } else {
            _publishRequest = [[PCCommentPublishRequest alloc] initWithCommentId:self.commentId];
        }
    }
    return _publishRequest;
}

- (QMUITextView *)textView {
    if (!_textView) {
        _textView = [[QMUITextView alloc] init];
        _textView.font = UIFontMake(16);
        _textView.textContainerInset = UIEdgeInsetsMake(15, 10, 15, 70);
        _textView.backgroundColor = UIColorWhite;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.placeholder = self.primaryType == PCCommentPrimaryTypeMain ? @"在这里发表您的评论" : @"在这里发表您的回复";
        _textView.qmui_borderColor = PCColorPink;
        _textView.qmui_borderPosition = QMUIViewBorderPositionTop;
        _textView.delegate = self;
        @weakify(self)
        _textView.qmui_keyboardWillShowNotificationBlock = ^(QMUIKeyboardUserInfo *info) {
            @strongify(self)
            self.keyboardHeight = info.height;
        };
        
        _textView.qmui_keyboardWillHideNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            @strongify(self)
            self.keyboardHeight = 0;
        };
    }
    return _textView;
}

- (QMUIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [[QMUIButton alloc] init];
        [_commentButton setTitle:self.primaryType == PCCommentPrimaryTypeMain ? @"发布" : @"回复" forState:UIControlStateNormal];
        [_commentButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _commentButton.layer.cornerRadius = 4;
        _commentButton.layer.masksToBounds = YES;
        _commentButton.backgroundColor = PCColorHotPink;
        [_commentButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
}

- (UIView *)extensionView {
    if (!_extensionView) {
        _extensionView = [[UIView alloc] init];
        _extensionView.backgroundColor = UIColorWhite;
    }
    return _extensionView;
}

#pragma mark - Set
- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    _keyboardHeight = keyboardHeight;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)setInputHeight:(CGFloat)inputHeight {
    _inputHeight = inputHeight;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
