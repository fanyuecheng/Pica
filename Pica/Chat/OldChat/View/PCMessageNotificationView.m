//
//  PCMessageNotificationView.m
//  Pica
//
//  Created by Fancy on 2021/6/18.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCMessageNotificationView.h"
#import "PCVendorHeader.h"

static NSMutableArray <PCMessageNotificationView *> *kMessageNotificationViewArray = nil;

@interface PCMessageNotificationView ()

@property (nonatomic, strong) QMUILabel *messageLabel;

@property (nonatomic, weak)   NSTimer *hideDelayTimer;
@property (nonatomic, assign) CGPoint gestureBeganLocation;

@end

@implementation PCMessageNotificationView

- (void)dealloc {
    if ([kMessageNotificationViewArray containsObject:self]) {
        [kMessageNotificationViewArray removeObject:self];
    }
}

- (void)didMoveToSuperview {
    if (!kMessageNotificationViewArray) {
        kMessageNotificationViewArray = [[NSMutableArray alloc] init];
    }
    if (self.superview) {
        // show
        if (![kMessageNotificationViewArray containsObject:self]) {
            [kMessageNotificationViewArray addObject:self];
        }
    } else {
        // hide
        if ([kMessageNotificationViewArray containsObject:self]) {
            [kMessageNotificationViewArray removeObject:self];
        }
    }
}

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
    [self addSubview:self.messageLabel];
    
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)]];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.messageLabel.frame = CGRectMake(15, 15, SCREEN_WIDTH - 30, QMUIViewSelfSizingHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SCREEN_WIDTH, [self.messageLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height + 30);
}

#pragma mark - Method
- (void)showAnimated:(BOOL)animated {
    PCMessageNotificationView *lastNotification = kMessageNotificationViewArray.lastObject;
    if (lastNotification) {
        [UIView animateWithDuration:.25 delay:0 options:QMUIViewAnimationOptionsCurveIn animations:^{
            lastNotification.alpha = 0;
        } completion:^(BOOL finished) {
            [lastNotification hideAnimated:NO];
        }];
    }
    
    [self.hideDelayTimer invalidate];
    [self sizeToFit];
    self.frame = CGRectSetXY(self.bounds, 0, -self.qmui_height);
    
    [DefaultTipsParentView addSubview:self];
    
    if (animated) {
         [UIView animateWithDuration:0.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
             self.qmui_top = StatusBarHeightConstant;
         } completion:nil];
    } else {
        self.qmui_top = StatusBarHeightConstant;
    }
}

+ (PCMessageNotificationView *)showWithMessage:(NSString *)message
                                      animated:(BOOL)animated {
    PCMessageNotificationView *notificationView = [[PCMessageNotificationView alloc] init];
    notificationView.messageLabel.text = message;
    notificationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
     
    [notificationView showAnimated:animated];
    [notificationView hideAnimated:YES afterDelay:4];

    return notificationView;
}

- (void)hideAnimated:(BOOL)animated {
    [self.hideDelayTimer invalidate];
    
    if (animated) {
         [UIView animateWithDuration:0.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
             self.qmui_top = -self.qmui_height;
         } completion:^(BOOL finished) {
             [self removeFromSuperview];
         }];
    } else {
        self.qmui_top = -self.qmui_height;
        [self removeFromSuperview];
    }
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(animated) repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.hideDelayTimer = timer;
}

- (void)handleHideTimer:(NSTimer *)timer {
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled = NO;
    }];
    [self hideAnimated:[timer.userInfo boolValue]];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureBeganLocation = [sender locationInView:self];
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGPoint location = [sender locationInView:self];
            CGFloat vDistance = location.y - self.gestureBeganLocation.y;
            self.qmui_top += vDistance;
            if (self.qmui_top > StatusBarHeightConstant) {
                self.qmui_top = StatusBarHeightConstant;
            }
            break;}
            
        case UIGestureRecognizerStateEnded:{
            if (self.qmui_top < 20) {
                [self hideAnimated:YES];
            } else {
                [UIView animateWithDuration:.25 delay:0.0 options:(7<<16) animations:^{
                    self.qmui_top = StatusBarHeightConstant;
                } completion:nil];
            }
            break;}
            
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)sender {
    [self hideAnimated:YES];
}

#pragma mark - Get
 
- (QMUILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[QMUILabel alloc] qmui_initWithFont:UIFontMake(14) textColor:UIColorBlack];
        _messageLabel.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        _messageLabel.numberOfLines = 0;
        _messageLabel.backgroundColor = UIColorWhite;
        _messageLabel.layer.cornerRadius = 4;
        _messageLabel.layer.shadowOpacity = 1;
        _messageLabel.layer.shadowColor = UIColorSeparator.CGColor;
        _messageLabel.layer.shadowRadius = 8;
        _messageLabel.layer.shadowOffset = CGSizeZero;
    }
    return _messageLabel;
}

@end

@implementation PCMessageNotificationView (PCMessageNotificationTool)

+ (BOOL)hideAllNotificationInView:(UIView * _Nullable)view animated:(BOOL)animated {
    NSArray *notifications = [self allNotificationInView:view];
    BOOL result = NO;
    for (PCMessageNotificationView *notificationView in notifications) {
        result = YES;
        [notificationView hideAnimated:animated];
    }
    return result;
}

+ (nullable PCMessageNotificationView *)notificationInView:(UIView *)view {
    if (kMessageNotificationViewArray.count <= 0) {
        return nil;
    }
    return kMessageNotificationViewArray.lastObject;
}

+ (nullable NSArray <PCMessageNotificationView *> *)allNotificationInView:(UIView *)view {
    if (!view) {
        return kMessageNotificationViewArray.count > 0 ? [kMessageNotificationViewArray mutableCopy] : nil;
    }
    NSMutableArray *notificationViewArray = [[NSMutableArray alloc] init];
    for (UIView *notificationView in kMessageNotificationViewArray) {
        if (notificationView.superview == view && [notificationView isKindOfClass:self]) {
            [notificationViewArray addObject:notificationView];
        }
    }
    return notificationViewArray.count > 0 ? [notificationViewArray mutableCopy] : nil;
}

@end
