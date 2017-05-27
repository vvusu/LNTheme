//
//  ThemeDetailVC.m
//  GoldUISSFramework
//
//  Created by vvusu on 12/28/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "ThemeDetailVC.h"
#import "ThemeModel.h"
#import "GoldZipLoader.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "LNTheme.h"

#define KCRGB(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define KCRANDOMCOLOR KCRGB(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

@interface ThemeDetailVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *musicBg;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@end

@implementation ThemeDetailVC

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.nameLabel.text = self.model.name;
    self.titleLabel.text = self.model.descriptionField;
    [self.musicBg sd_setImageWithURL:[NSURL URLWithString:self.model.thumbnail]];
    [self.nameLabel ln_textColor:@"c8"];
    [self.confirmBtn ln_backgroundColor:@"c7"];
    [self.confirmBtn ln_backgroundColor:@"c8"];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmBtnAction:(id)sender {
    [self changeCurrentTheme];
}

- (void)changeCustomColor {
    // 重新加载主题图片，并设置主题色为红色
}

- (void)changeCurrentTheme {
    __weak typeof(self) wself= self;
    if (self.confirmBtn.isSelected) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (!self.model.idField) {
        self.model.idField = [NSString stringWithFormat:@"theme_%f",[NSDate date].timeIntervalSince1970];
    }
    NSString *path = [NSString stringWithFormat:@"UserData/Skin/CurrentTheme/%@",self.model.idField];
    NSString *targetPath = [GoldZipLoader fileAtLibrary:path];
    [GoldZipLoader downloadFile:[NSURL URLWithString:self.model.downloadUrl]
                    destination:targetPath
                          block:^(NSError *error) {
                              dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [MBProgressHUD hideHUDForView:wself.view animated:YES];
                                      if (!error) {
                                          wself.confirmBtn.selected = YES;
                                      }
                                      [LNTheme changeTheme:wself.model.idField];
                                  });
                              });
                          }];
}

@end
