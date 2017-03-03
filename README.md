<p align="center">
  <img src="./images/banner.png">
</p>

<p align="center">
<a href="#文档">文档</a> -
<a href="#安装">安装</a> -
<a href="#demo">Demo</a> -
<a href="#contribution">Contribution</a>
</p>
    
<p align="center">
<a href="http://cocoadocs.org/docsets/LNTheme"><img src="https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%207%2B-blue.svg?style=flat"></a>
<a href="https://github.com/wedxz/LNTheme/tree/1.0.0"><img src="https://img.shields.io/badge/release-1.0.0-blue.svg"></a>
<a href="https://codebeat.co/projects/github-com-wedxz-lntheme-master"><img alt="codebeat badge" src="https://codebeat.co/badges/900eef02-9b88-46eb-8ce9-440c1dc31435"/></a>
<a href="https://github.com/wedxz/LNTheme/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

# LNTheme
动态主题切换框架，支持本地多主题配置或者网络多主题配置。

## 文档

### 基本使用方法
主题切换使用Name来标识，一个主题可以对应多个json配置文件。框架主要用json文件进行主题配置的。你需要在本地添加json配置文件，或者手动注册json文件。

手动注册json文件使用如下方法：

```
+ (void)addTheme:(NSString *)themeName forPath:(NSString *)path;
```
json文件格式如下：

```
{
    "colors": {
        "c1": "b2770f",
        "c2": "b2770f",
        "c3": "aaaaaa",
        "c4": "b2770f",
        "c5": "b2770f",
   },
    "fonts": {
        "f1": "8",
        "f2": "9",
        "f3": "10",
        "f4": "14",
        "f5": "16",
    },
    "coordinators": {
        "LNTabBarBadgePointViewOriginOffset": "{0,0}",
        "LNTabBarBadgePointViewHighlightOriginOffset": "{0,0}",
        "LNTabBarBadgeTextViewOriginOffset": "{0,0}",
        "LNTabBarBadgeTextViewHighlightOriginOffset": "{0,0}"
    }
}
```
json文件中`colors`,`fonts`,`coordinators`为固定写法，可以添加其他的Key。对应标识可以相同，但是相同的key会覆盖。建议是用一套标准方便维护。

`colors`颜色字符串标准格式为: `RGB / ARGB / RRGGBB / AARRGGBB`
`fonts`字体格式为: `"16"`
`coordinators`格式为: `{1,2} / {1,2,3,4} / {1,2,3,4,5,6}`

####基础使用实列：
`NSObject+LNTheme.h`这个类包含了所支持基础的设置方法。

```
@property (strong, nonatomic)NSMutableDictionary *themePickers;
- (void)updateTheme;
- (void)ln_customThemeAction:(id(^)(void))block;
@end

@interface UIColor (LNTheme)
+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end
...
```
####颜色多主题设置
```
//UIView 设置背景颜色
[self.view ln_backgroundColor:@"c8"];

//UILabel 设置Text颜色
[self.label ln_textColor:@"c5"];

//UITextField 设置text颜色
[self.textField ln_textColor:@"c8"];

//UISwitch 设置打开的颜色
[self.testSwitch ln_onTintColor:@"c8"];
```
####字体多主题设置
```
//设置UINavigationBar 的titleTextAttributes属性
[navBar ln_titleTextAttributesColorType:@"c9" font:@"f10"];
```
####图片多主题设置
```
//UIImageView 设置图片
[self.imageview ln_imageNamed:@"cm2_chat_bg"];

//UIButton 设置高亮状态下背景图片
[self.button ln_backgroundImageNamed:@"cm2_edit_cmt_bg" forState:UIControlStateHighlighted];
```

图片自定义颜色可以使用`UIImage + Tint.h`这个扩展所提供的方法。

####获取主题相关属性
获取相关属相值使用`LNTheme.h`中包含的方法，通过Key来获取。

```
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
```

####其他
如果没有包含所设置的选项可以手动刷新控件相关属性，使用`NSObject+LNTheme.h`中包含的方法：

```
- (void)ln_customThemeAction:(id(^)(void))block;
```
如主题切换时刷新UITableView

```
__weak typeof(self) wself= self;
[self ln_customThemeAction:^id {
    [wself.tableView reloadData];
    return nil;
}];
```

## 安装
### CocoaPods
要使用CocoaPods时在Podfile中填写：

```
pod 'LNTheme'
```
### Carthage
要使用Carthage时在Cartfile中填写：

```
github "wedxz/LNTheme"
```
### 源码安装
```
将“LNTheme/LNTheme”文件夹中的所有文件复制到您的项目中
```
## Demo
使用网易云音乐 API

<p align="center">
    <img src="./images/demo.png">
</p>

## Contribution

### Issue
如果你发现一个错误或需要帮助，你可以 [create a issue](https://github.com/wedxz/LNTheme/issues/new)

### Contributors
[vvusu](https://github.com/wedxz)

## License

Copyright (c) 2016 vvusu (http://github.com/wedxz)

LNTheme is available under the MIT license. See the LICENSE file for more info.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

