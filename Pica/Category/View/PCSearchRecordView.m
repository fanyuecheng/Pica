//
//  PCSearchRecordView.m
//  Pica
//
//  Created by Fancy on 2021/5/31.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCSearchRecordView.h"
#import "PCVendorHeader.h"
#import "PCComicsListController.h"
#import "UIImage+PCAdd.h"

#define PC_SEARCH_RECORD @"PC_SEARCH_RECORD"

@interface PCSearchRecordView ()

@property (nonatomic, strong) QMUIFloatLayoutView *contentView;
@property (nonatomic, strong) QMUIButton          *deleteButton;
@property (nonatomic, strong) NSMutableArray      *recordArray;

@end

@implementation PCSearchRecordView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = UIColorWhite;
    self.tableHeaderView = self.contentView;
    self.tableFooterView = self.deleteButton;
}

- (void)saveSearchKey:(NSString *)key {
    if (key) {
        if ([self.recordArray containsObject:key]) {
            [self.recordArray removeObject:key];
        }
        [self.recordArray insertObject:key atIndex:0];
        [self addTagView];
        [[NSUserDefaults standardUserDefaults] setObject:self.dataSource forKey:PC_SEARCH_RECORD];
    }
}

- (void)addTagView {
    [self.contentView qmui_removeAllSubviews];
    [self.recordArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIButton *button = [[QMUIFillButton alloc] initWithFillType:QMUIFillButtonColorBlue];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 10, 10);
        [button setTitle:obj forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }];
    self.contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
}

- (NSInteger)recordCount {
    return self.recordArray.count;
}

#pragma mark - Action
- (void)tagAction:(UIButton *)sender {
    [self removeFromSuperview];
    PCComicsListController *list = [[PCComicsListController alloc] initWithType:PCComicsListTypeSearch];
    list.keyword = sender.currentTitle;
    [[QMUIHelper visibleViewController].navigationController pushViewController:list animated:YES];
}

- (void)deleteAction:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PC_SEARCH_RECORD];
    [self.contentView qmui_removeAllSubviews];
    [self.recordArray removeAllObjects];
    [self removeFromSuperview];
}


#pragma mark - Get
- (QMUIFloatLayoutView *)contentView {
    if (!_contentView) {
        _contentView = [[QMUIFloatLayoutView alloc] init];
        _contentView.padding = UIEdgeInsetsMake(15, 15, 15, 15);
        _contentView.itemMargins = UIEdgeInsetsMake(0, 0, 15, 15);
        [self addTagView];
    }
    return _contentView;
}

- (QMUIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[QMUIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        _deleteButton.spacingBetweenImageAndTitle = 5;
        _deleteButton.titleLabel.font = UIFontMake(16);
        [_deleteButton setImage:[UIImage pc_iconWithText:ICON_ASHBIN size:18 color:UIColorBlue] forState:UIControlStateNormal];
        [_deleteButton setTitle:@"删除记录" forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (NSMutableArray *)recordArray {
    if (!_recordArray) {
        _recordArray = [NSMutableArray array];
        NSArray *localData = [[NSUserDefaults standardUserDefaults] arrayForKey:PC_SEARCH_RECORD];
        if (localData.count) {
            [_recordArray addObjectsFromArray:localData];
        }
    }
    return _recordArray;
}

@end
