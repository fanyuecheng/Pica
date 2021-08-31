//
//  PCProfileController.m
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCProfileController.h"
#import "PCProfileRequest.h"
#import "PCPunchInRequest.h"
#import "PCUser.h"
#import "PCProfileHeaderView.h"
#import "PCNavigationController.h"
#import "PCAvatarSetRequest.h"
#import "PCSloganSetRequest.h"
#import "PCProfileInfoController.h"
#import "UIImage+PCAdd.h"
#import "PCSettingController.h"

@interface PCProfileController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, JXPagerViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) PCUser *user;
@property (nonatomic, strong) PCProfileRequest *profileRequest;
@property (nonatomic, strong) PCPunchInRequest *punchInRequest;
@property (nonatomic, strong) PCAvatarSetRequest  *avatarSetRequest;
@property (nonatomic, strong) PCSloganSetRequest  *sloganSetRequest;
@property (nonatomic, strong) PCProfileHeaderView *headerView;

@property (nonatomic, strong) JXPagerView *pagerView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) PCProfileInfoController *comicController;
@property (nonatomic, strong) PCProfileInfoController *commentController;

@end

@implementation PCProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self requestProfile];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"我的";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithImage:[UIImage pc_iconWithText:ICON_SETTING size:20 color:UIColorBlue] target:self action:@selector(settingAction:)];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.pagerView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat navigationBarMaxY = self.qmui_navigationBarMaxYInViewCoordinator;
    self.pagerView.frame = CGRectMake(0, navigationBarMaxY, SCREEN_WIDTH, SCREEN_HEIGHT - navigationBarMaxY - self.qmui_tabBarSpacingInViewCoordinator);
}

#pragma mark - Net
- (void)requestProfile {
    if (self.user == nil) {
        [self showEmptyViewWithLoading];
    }
    
    [self.profileRequest sendRequest:^(PCUser *user) {
        [self hideEmptyView];
        self.user = user;
        [self.pagerView.mainTableView.mj_header endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [self.pagerView.mainTableView.mj_header endRefreshing];
        [self showEmptyViewWithText:@"网络错误" detailText:nil buttonTitle:@"重新请求" buttonAction:@selector(requestProfile)];
    }];
}

- (void)sendPunchInRequest {
    [self.punchInRequest sendRequest:^(NSString *response) {
        if ([response isEqualToString:@"fail"]) {
            [QMUITips showError:@"您今天已经打过卡了~"];
        } else {
            [QMUITips showSucceed:@"已打卡"];
            [self requestProfile];
        }
        [self.headerView setPunchInButtonHidden:YES];
    } failure:^(NSError * _Nonnull error) {
         
    }];
}

- (void)updateAvatarWithImage:(UIImage *)avatar {
    self.avatarSetRequest.avatar = avatar;
    QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
    
    [self.avatarSetRequest sendRequest:^(id  _Nonnull response) {
        [loading hideAnimated:YES];
        [self.headerView updateAvatar:avatar];
    } failure:^(NSError * _Nonnull error) {
        [loading hideAnimated:YES];
    }];
}

- (void)updateSloganWithText:(NSString *)slogan {
    if (slogan.length == 0) {
        return;
    }
    self.sloganSetRequest.slogan = slogan;
    QMUITips *loading = [QMUITips showLoadingInView:DefaultTipsParentView];
    
    [self.sloganSetRequest sendRequest:^(id  _Nonnull response) {
        [loading hideAnimated:YES];
        [self.headerView updateSlogan:slogan];
    } failure:^(NSError * _Nonnull error) {
        [loading hideAnimated:YES];
    }];
}

#pragma mark - Action
- (void)segmentedAction:(UISegmentedControl *)sender {
    [self.pagerView.listContainerView didClickSelectedItemAtIndex:sender.selectedSegmentIndex];
    [self.pagerView.listContainerView.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * sender.selectedSegmentIndex, 0) animated:YES];
}

- (void)settingAction:(id)sender {
    PCSettingController *setting = [[PCSettingController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:setting animated:YES];
}

#pragma mark - Method
- (void)showSelectImageAlert {
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"拍照" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [self takePhoto];
    }];
    
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"从手机相册选择" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [self pickImage];
    }];
    
    QMUIAlertAction *action3 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:nil message:nil preferredStyle:QMUIAlertControllerStyleActionSheet];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController showWithAnimated:YES];
}

- (void)showSloganInputAlert {
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [self updateSloganWithText:aAlertController.textFields.firstObject.text];
    }];
     
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"请输入您的slogan" message:nil preferredStyle:QMUIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(QMUITextField * _Nonnull textField) {
        [textField becomeFirstResponder];
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
}

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) {
                //第一次不允许的操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
                });
                return ;
            }
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        //允许权限之后的操作
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //不允许权限之后的操作 & 系统受限制之后的操作
        QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"去设置" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }];
        
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:nil];
        
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"请允许Pica访问您的相机" message:nil preferredStyle:QMUIAlertControllerStyleAlert];
        
        [alertController addAction:action1];
        [alertController addAction:action2];
        [alertController showWithAnimated:YES];
        return;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //相机不可用
        return;
    }
    
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)pickImage {
    if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotDetermined) {
        [QMUIAssetsManager requestAuthorization:^(QMUIAssetAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentAlbumViewController];
            });
        }];
    } else {
        [self presentAlbumViewController];
    }
}

- (void)presentAlbumViewController {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if (editedImage) {
        [self updateAvatarWithImage:editedImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JXPagerViewDelegate
- (NSUInteger)tableHeaderViewHeightInPagerView:(JXPagerView *)pagerView {
    NSUInteger height = [self.headerView sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height;
    return height;
}

- (UIView *)tableHeaderViewInPagerView:(JXPagerView *)pagerView {
    return self.headerView;
}

- (NSUInteger)heightForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return 40;
}

- (UIView *)viewForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return self.segmentedControl;
}

- (NSInteger)numberOfListsInPagerView:(JXPagerView *)pagerView {
    return 2;
}

- (id<JXPagerViewListViewDelegate>)pagerView:(JXPagerView *)pagerView initListAtIndex:(NSInteger)index { 
    return index == 0 ? self.comicController : self.commentController;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.segmentedControl.selectedSegmentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
}
 
#pragma mark - Get
- (PCProfileRequest *)profileRequest {
    if (!_profileRequest) {
        _profileRequest = [[PCProfileRequest alloc] init];
    }
    return _profileRequest;
}

- (PCPunchInRequest *)punchInRequest {
    if (!_punchInRequest) {
        _punchInRequest = [[PCPunchInRequest alloc] init];
    }
    return _punchInRequest;
}

- (PCAvatarSetRequest *)avatarSetRequest {
    if (!_avatarSetRequest) {
        _avatarSetRequest = [[PCAvatarSetRequest alloc] init];
    }
    return _avatarSetRequest;
}

- (PCSloganSetRequest *)sloganSetRequest {
    if (!_sloganSetRequest) {
        _sloganSetRequest = [[PCSloganSetRequest alloc] init];
    }
    return _sloganSetRequest;
}

- (PCProfileHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[PCProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 264)];
        @weakify(self)
        _headerView.punchInBlock = ^{
           @strongify(self)
            [self sendPunchInRequest];
        };
        _headerView.avatarBlock = ^{
            @strongify(self)
            [self showSelectImageAlert];
        };
        _headerView.sloganBlock = ^{
            @strongify(self)
            [self showSloganInputAlert];
        };
        
    }
    return _headerView;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
        if (@available(iOS 13.0, *)) {
            _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    }
    return _imagePickerController;
}

- (JXPagerView *)pagerView {
    if (!_pagerView) {
        _pagerView = [[JXPagerView alloc] initWithDelegate:self];
        _pagerView.listContainerView.scrollView.qmui_multipleDelegatesEnabled = YES;
        _pagerView.listContainerView.scrollView.delegate = self;
        @weakify(self)
        _pagerView.mainTableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self requestProfile];
        }];
    }
    return _pagerView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"本子", @"评论"]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
        [_segmentedControl setBackgroundImage:[UIImage qmui_imageWithColor:UIColorClear] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_segmentedControl setTitleTextAttributes:@{NSFontAttributeName:UIFontBoldMake(16), NSForegroundColorAttributeName:PCColorHotPink} forState:UIControlStateSelected];
        [_segmentedControl setTitleTextAttributes:@{NSFontAttributeName:UIFontMake(16), NSForegroundColorAttributeName:UIColorGrayLighten} forState:UIControlStateNormal];
        [_segmentedControl setDividerImage:[UIImage qmui_imageWithColor:UIColorClear] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    return _segmentedControl;
}

- (PCProfileInfoController *)comicController {
    if (!_comicController) {
        _comicController = [[PCProfileInfoController alloc] initWithType:PCProfileInfoTypeComic];
    }
    return _comicController;
}

- (PCProfileInfoController *)commentController {
    if (!_commentController) {
        _commentController = [[PCProfileInfoController alloc] initWithType:PCProfileInfoTypeComment];
    }
    return _commentController;
}

#pragma mark - Set
- (void)setUser:(PCUser *)user {
    _user = user;

    self.headerView.user = user;
    self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, QMUIViewSelfSizingHeight);
    [self.pagerView reloadData];
}



@end
