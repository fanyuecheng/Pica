//
//  PCColorPickerViewController.m
//  Pica
//
//  Created by Fancy on 2021/7/14.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCColorPickerViewController.h"
#import "PCColorGridView.h"
#import "PCColorSlider.h"

@interface PCColorPickerViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) PCColorGridView    *colorGridView;
@property (nonatomic, strong) PCColorSlider      *redSlider;
@property (nonatomic, strong) PCColorSlider      *greenSlider;
@property (nonatomic, strong) PCColorSlider      *blueSlider;
@property (nonatomic, strong) QMUIButton         *addButton;
@property (nonatomic, strong) QMUIButton         *clearButton;
@property (nonatomic, strong) QMUIFloatLayoutView *resultView;

@property (nonatomic, strong) NSMutableArray <UIColor *> *colorArray;

@end

@implementation PCColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"选择颜色";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"完成" target:self action:@selector(doneAction:)];
}

- (void)initSubviews {
    [super initSubviews];
    
    self.view.backgroundColor = UIColorMake(246, 246, 246);
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.colorGridView];
    [self.view addSubview:self.redSlider];
    [self.view addSubview:self.greenSlider];
    [self.view addSubview:self.blueSlider];
    [self.view addSubview:self.addButton];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.resultView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.segmentedControl.frame = CGRectMake(15, self.qmui_navigationBarMaxYInViewCoordinator + 10, self.view.qmui_width - 30, 40);
    self.colorGridView.frame = CGRectMake(15, self.segmentedControl.qmui_bottom + 15, self.view.qmui_width - 30, QMUIViewSelfSizingHeight);
    self.redSlider.frame = CGRectMake(0, self.segmentedControl.qmui_bottom + 15, self.view.qmui_width, QMUIViewSelfSizingHeight);
    self.greenSlider.frame = CGRectMake(0, self.redSlider.qmui_bottom, self.view.qmui_width, QMUIViewSelfSizingHeight);
    self.blueSlider.frame = CGRectMake(0, self.greenSlider.qmui_bottom, self.view.qmui_width, QMUIViewSelfSizingHeight);
    self.addButton.frame = CGRectMake(15, self.view.qmui_height - SafeAreaInsetsConstantForDeviceWithNotch.bottom - 200, 80, 80);
    self.clearButton.frame = CGRectMake(15, self.addButton.qmui_bottom + 10, 80, 40);
    self.resultView.frame = CGRectMake(self.addButton.qmui_right + 15, self.addButton.qmui_top, self.view.qmui_width - 125, 100);
}

#pragma mark - Action
- (void)doneAction:(id)sender {
    NSMutableArray *hexArray = [NSMutableArray array];
    [self.colorArray enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [hexArray addObject:obj.qmui_hexString];
    }];
    
    [kPCUserDefaults setObject:hexArray forKey:PC_CHAT_EVENT_COLOR];
    [self.navigationController popViewControllerAnimated:YES];
}
 
- (void)clearAction:(QMUIButton *)sender {
    [self.colorArray removeAllObjects];
    [self.resultView qmui_removeAllSubviews];
}

- (void)addAction:(QMUIButton *)sender {
    UIColor *color = sender.backgroundColor;
    if (![self.colorArray containsObject:color]) {
        if (self.colorArray.count > 10) {
            [QMUITips showError:@"最多添加10种颜色"];
        } else {
            [self.colorArray addObject:color];
            [self.resultView addSubview:[self resultItemWithColor:color]];
        }
    }
}

- (void)segmentedAction:(UISegmentedControl *)sender {
    BOOL grid = sender.selectedSegmentIndex == 0;
    [UIView animateWithDuration:.25 animations:^{
        self.colorGridView.alpha = grid ? 1 : 0;
        self.redSlider.alpha = grid ? 0 : 1;
        self.greenSlider.alpha = grid ? 0 : 1;
        self.blueSlider.alpha = grid ? 0 : 1;
    }];
}

#pragma mark - Method
- (UIView *)resultItemWithColor:(UIColor *)color {
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 15;
    view.layer.masksToBounds = YES;
    view.backgroundColor = color;
    return view;
}

#pragma mark - Get
- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"网格", @"滑块"]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (PCColorGridView *)colorGridView {
    if (!_colorGridView) {
        _colorGridView = [[PCColorGridView alloc] init];
        @weakify(self)
        _colorGridView.colorBlock = ^(UIColor * _Nonnull color) {
            @strongify(self)
            self.addButton.backgroundColor = color;
        };
    }
    return _colorGridView;
}

- (PCColorSlider *)slider {
    PCColorSlider *slider = [[PCColorSlider alloc] init];
    slider.alpha = 0;
    @weakify(self)
    slider.valueBlock = ^(NSInteger value) {
        @strongify(self)
        CGFloat r = self.redSlider.value;
        CGFloat g = self.greenSlider.value;
        CGFloat b = self.blueSlider.value;
        self.addButton.backgroundColor = UIColorMake(r, g, b);
    };
    return slider;
}

- (PCColorSlider *)redSlider {
    if (!_redSlider) {
        _redSlider = [self slider];
        _redSlider.type = PCColorSliderTypeRed;
    }
    return _redSlider;
}

- (PCColorSlider *)greenSlider {
    if (!_greenSlider) {
        _greenSlider = [self slider];
        _greenSlider.type = PCColorSliderTypeGreen;
    }
    return _greenSlider;
}

- (PCColorSlider *)blueSlider {
    if (!_blueSlider) {
        _blueSlider = [self slider];
        _blueSlider.type = PCColorSliderTypeBlue;
    }
    return _blueSlider;
}

- (QMUIButton *)addButton {
    if (!_addButton) {
        _addButton = [[QMUIButton alloc] init];
        _addButton.titleLabel.font = UIFontBoldMake(30);
        [_addButton setTitle:@"+" forState:UIControlStateNormal];
        [_addButton setTitleColor:UIColorBlack forState:UIControlStateNormal];
        _addButton.backgroundColor = UIColorWhite;
        _addButton.layer.cornerRadius = 4;
        _addButton.layer.masksToBounds = 4;
        [_addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (QMUIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [[QMUIButton alloc] init];
        _clearButton.titleLabel.font = UIFontBoldMake(20);
        [_clearButton setTitle:@"清空" forState:UIControlStateNormal];
        [_clearButton setTitleColor:UIColorBlack forState:UIControlStateNormal];
        _clearButton.layer.shadowOpacity = 1;
        _clearButton.layer.shadowColor = UIColorGray7.CGColor;
        _clearButton.layer.shadowRadius = 8;
        _clearButton.layer.shadowOffset = CGSizeZero;
        [_clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (QMUIFloatLayoutView *)resultView {
    if (!_resultView) {
        _resultView = [[QMUIFloatLayoutView alloc] init];
        _resultView.minimumItemSize = CGSizeMake(30, 30);
        _resultView.itemMargins = UIEdgeInsetsMake(0, 0, 10, 10);
        NSArray *colorArray = [kPCUserDefaults objectForKey:PC_CHAT_EVENT_COLOR];
        if (colorArray.count) {
            [colorArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_resultView addSubview:[self resultItemWithColor:UIColorMakeWithHex(obj)]];
            }];
        }
    }
    return _resultView;
}

- (NSMutableArray<UIColor *> *)colorArray {
    if (!_colorArray) {
        _colorArray = [NSMutableArray array];
        NSArray *colorArray = [kPCUserDefaults objectForKey:PC_CHAT_EVENT_COLOR];
        [colorArray enumerateObjectsUsingBlock:^(NSString * _Nonnull hex, NSUInteger idx, BOOL * _Nonnull stop) {
            [_colorArray addObject:UIColorMakeWithHex(hex)];
        }];
    }
    return _colorArray;
}

@end
