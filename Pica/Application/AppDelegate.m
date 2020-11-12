//
//  AppDelegate.m
//  Pica
//
//  Created by fancy on 2020/11/2.
//

#import "AppDelegate.h"
#import "PCLoginController.h"
#import "PCTabBarViewController.h"
#import "PCCategoryController.h"
#import "PCNavigationController.h"

@interface AppDelegate ()

@property (nonatomic, strong) PCLoginController      *loginController;
@property (nonatomic, strong) PCNavigationController *categoryController;
//TODO
@property (nonatomic, strong) PCTabBarViewController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:PC_AUTHORIZATION_TOKEN];
    if (token) {
        SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageLoader;
        [downloader setValue:token forHTTPHeaderField:@"authorization"];
        self.window.rootViewController = self.categoryController;
    } else {
        self.window.rootViewController = self.loginController;
    }
     
    [self.window makeKeyAndVisible];
    
    return YES;
}
 
- (void)setRootViewControllerToLogin {
    if (self.window.rootViewController != self.loginController) {
        [UIView transitionFromView:self.window.rootViewController.view toView:self.loginController.view duration:0.65f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            [self.window setRootViewController:self.loginController];
            self.categoryController   = nil;
        }];
    }
}

- (void)setRootViewControllerToTab {
    if (self.window.rootViewController != self.categoryController) {
        UIView *currentView = [QMUIHelper visibleViewController].view;
        QMUINavigationController *controller = self.categoryController;
        
        [UIView transitionFromView:currentView toView:controller.topViewController.view duration:0.65f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            [self.window setRootViewController:self.categoryController];
            self.loginController = nil; 
        }];
    }
}

#pragma mark - Get
- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = UIColorWhite;
    }
    return _window;
}

#pragma mark - Get
- (PCLoginController *)loginController {
    if (!_loginController) {
        _loginController = [[PCLoginController alloc] init];
    }
    return _loginController;
}
 
- (PCNavigationController *)categoryController {
    if (!_categoryController) {
        _categoryController = [[PCNavigationController alloc] initWithRootViewController:[[PCCategoryController alloc] init]];
    }
    return _categoryController;
}

- (PCTabBarViewController *)tabBarController {
    if (!_tabBarController) {
        _tabBarController = [[PCTabBarViewController alloc] init];
    }
    return _tabBarController;
}

@end
