//
//  LNThemePicker.h
//  LNTheme
//
//  Created by vvusu on 1/19/17.
//  Copyright © 2017 vvusu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LNThemePickerType) {
    ThemePicker_Nomal = 0,
    ThemePicker_Font,
    ThemePicker_State,
    ThemePicker_CGFloat,
    ThemePicker_CGColor,
    ThemePicker_EdgeInset,
    ThemePicker_StatusBar
};

typedef id (^LNThemePickerBlock)();
@interface LNThemePicker : NSObject
@property (copy, nonatomic) LNThemePickerBlock block;
@property (assign, nonatomic) LNThemePickerType type;
@property (assign, nonatomic) UIControlState valueState;

#pragma mark - ThemePicker
+ (instancetype)initWithFontType:(NSString *)type;
+ (instancetype)initWithColorType:(NSString *)type;
+ (instancetype)initWithImageName:(NSString *)name;
+ (instancetype)initWithImageColorType:(NSString *)type size:(CGSize)size;
+ (instancetype)initWithImageName:(NSString *)name renderingMode:(UIImageRenderingMode)mode;
+ (instancetype)initTextAttributesColorType:(NSString *)color font:(NSString *)font;

#pragma mark - ThemeStatePicker
+ (instancetype)initWithColorType:(NSString *)type forState:(UIControlState)state;
+ (instancetype)initWithImageName:(NSString *)name forState:(UIControlState)state;
+ (instancetype)initWithImageName:(NSString *)name forBarMetrics:(UIBarMetrics)state;
+ (instancetype)initWithImageWithColorType:(NSString *)type size:(CGSize)size forState:(UIControlState)state;
+ (instancetype)initTextAttributesColorType:(NSString *)color font:(NSString *)font forState:(UIControlState)state;

#pragma mark - ThemeCGColorPicker
+ (instancetype)initWithCGColor:(NSString *)type;

#pragma mark - ThemeCGFloatPicker
+ (instancetype)initWithCGFloat:(CGFloat)num;

#pragma mark - ThemeEdgeInsetPicker
+ (instancetype)initWithImageInsets:(NSString *)type;

#pragma mark - ThemeStatusBarPicker
+ (instancetype)initWithStatusBarAnimated:(BOOL)animated;
@end
