//
//  TabBarController.m
//  GoldUISSFramework
//
//  Created by vvusu on 12/29/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "TabBarController.h"
#import "LNTheme.h"

@interface TabBarController ()
@property (weak, nonatomic) IBOutlet UITabBar *lnTabBar;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lnTabBar.barStyle = UIBarStyleBlack;
    [self.lnTabBar ln_backgroundImageNamed:@"cm2_btm_bg"];
    
    NSArray *normalImages = @[@"cm2_btm_icn_discovery",@"cm2_btm_icn_music",@"cm2_btm_icn_friend",@"cm2_btm_icn_account"];
    NSArray *prsImages = @[@"cm2_btm_icn_discovery_prs",@"cm2_btm_icn_music_prs",@"cm2_btm_icn_friend_prs",@"cm2_btm_icn_account_prs"];
    for (NSInteger i = 0; i < self.lnTabBar.items.count; i++) {
        UITabBarItem *item = self.lnTabBar.items[i];
        [item ln_imageInsets:@"NMTabBarBadgeTextViewOriginOffset"];
        [item ln_imageNamed:normalImages[i] renderingMode:UIImageRenderingModeAlwaysOriginal];
        [item ln_selectedImageNamed:prsImages[i] renderingMode:UIImageRenderingModeAlwaysOriginal];
        [item ln_titleTextAttributesColorType:@"ctabn" font:@"f2" forState:UIControlStateNormal];
        [item ln_titleTextAttributesColorType:@"ctabn" font:@"f2" forState:UIControlStateSelected];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
