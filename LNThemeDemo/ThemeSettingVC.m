//
//  ThemeSettingVC.m
//  GoldUISSFramework
//
//  Created by vvusu on 12/28/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "ThemeSettingVC.h"
#import "YYModel.h"
#import "ThemeModel.h"
#import "ThemeDetailVC.h"
#import "ThemeSettingCell.h"
#import "UIImageView+WebCache.h"
#import "NSObject+LNTheme.h"

#define __async_main__ dispatch_async(dispatch_get_main_queue()
#define __async_global__  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

static NSString *const KICellReuseIdentifier = @"ThemeSettingCell";

@interface ThemeSettingVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArr;
@end
@implementation ThemeSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat itemW = (self.view.frame.size.width - 40) / 3.0 - 1;
    CGFloat itemH = itemW * 87 / 61 + 20;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 20.0;
    layout.minimumInteritemSpacing = 10.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 60, 10);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:KICellReuseIdentifier bundle:nil] forCellWithReuseIdentifier:KICellReuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"skineTheme" ofType:@"json"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    self.dataArr = [NSArray yy_modelArrayWithClass:[ThemeModel class] json:jsonArr];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThemeSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KICellReuseIdentifier forIndexPath:indexPath];
    ThemeModel *model = self.dataArr[indexPath.row];
    [cell.bgImage sd_setImageWithURL:[NSURL URLWithString:model.thumbnail]];
    cell.titleLabel.text = model.name;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ThemeDetailVC *themeVC = [[ThemeDetailVC alloc]init];
    themeVC.model = self.dataArr[indexPath.row];
    [self.navigationController pushViewController:themeVC animated:YES];
}

@end
