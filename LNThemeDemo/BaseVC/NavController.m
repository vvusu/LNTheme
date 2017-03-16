//
//  NavController.m
//  GoldUISSFramework
//
//  Created by vvusu on 12/30/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "NavController.h"
#import <LNTheme/LNTheme.h>

@interface NavController ()

@end

@implementation NavController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //设置主题颜色
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    [navBar ln_backgroundImageNamed:@"cm2_topbar_bg" forBarMetrics:UIBarMetricsDefault];
    [navBar ln_titleTextAttributesColorType:@"ctabh" font:@"f10"];
    [self setValue:navBar forKey:@"navigationBar"];
    //自定义返回按钮
    UIImage *backButtonImage = [[LNTheme imageNamed:@"cm2_topbar_icn_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {

}
@end
