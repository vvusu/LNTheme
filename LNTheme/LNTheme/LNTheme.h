//
//  LNTheme.h
//  GoldUISSFramework
//
//  Created by vvusu on 12/30/16.
//  Copyright © 2016 Micker. All rights reserved.
//

/**
    工程目录下可以添加"defaultTheme.json"文件，为默认的主题配置文件。也可自己注册主题配置文件。
    主题json文件格式如下:
 {
    "colors": {
        "c1": "b2770f",
        "c2": "b2770f",
        "c3": "aaaaaa"
    },
    "fonts": {
       "f1": "8",
       "f2": "9"
    },
    "coordinators": {
        "LNTabBarBadgePointViewOriginOffset": "{0,0}",
        "LNTabBarBadgePointViewOrigin": "{0,0,12,11}"
    }
 }
    注意:
    颜色值格式为: RGB / ARGB / RRGGBB / AARRGGBB
    coordinators格式为: {1,2} / {1,2,3,4} / {1,2,3,4,5,6}
 */

#import <UIKit/UIKit.h>
#import "NSObject+LNTheme.h"

//默认主题的名称
FOUNDATION_EXPORT  NSString * const LN_THEME_DEFAULT_NAME;

@interface LNTheme : NSObject

+ (instancetype)instance;
/**
    当前主题Name
 */
+ (NSString *)currentTheme;
/**
    沙盒中主题存储的根目录
 */
+ (NSString *)themeRootPath;
/**
    启动本地主题注册接口 适用于多Frameworks注册
    各模块需要编写LNTheme的分类，并以‘registerTheme_’作为前缀命名
    - (void)registerTheme_Host {
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"json"]
        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"json"]
        [[self class] addTheme:LN_THEME_DEFAULT_NAME forPath:path1];
        [[self class] addTheme:@"day" forPath:path2];
    }
 */
- (void)registerSubFrameworks;
/**
    切换主题，初始值为default
    如果当前主题不存在，则自动切换回default
    @param themeName 当前主题
 */
+ (void)changeTheme:(NSString *)themeName;
/**
    注册有限主题的路径，可以多次调用
    @param themeName 主题名字 默认主题为LN_DEFAULT_THEME_NAME("default")
    @param path 目录地址
 */
+ (void)addTheme:(NSString *)themeName forPath:(NSString *)path;
/**
    基础数据结构对象 Font
    @param type 名称
    @return UIFont
 */
+ (UIFont *)fontForType:(NSString *)type;
/**
    基础数据结构对象Image，和JSON文件同级目录或者BUNDLE
    @param name 名称
    @return UIImage
 */
+ (UIImage *)imageNamed:(NSString *)name;
/**
    基础数据结构对象 Color
    @param type 名称
    @return UIColor
 */
+ (UIColor *)colorForType:(NSString *)type;
/**
    除Color,Font,Image,Coorderate之外
    @param type 名称
    @return id值
 */
+ (id)otherForType:(NSString *)type;
/**
    基础数据结构对象 Coorderate
    @param type 名称 格式：{1,1,1,1}
    @return 值
 */
+ (CGSize)sizeForType:(NSString *)type;
+ (CGRect)rectForType:(NSString *)type;
+ (CGPoint)pointForType:(NSString *)type;
+ (CGVector)vectorForType:(NSString *)type;
+ (UIEdgeInsets)edgeInsetsForType:(NSString *)type;
+ (CGAffineTransform)affineTransformForType:(NSString *)type;
@end
