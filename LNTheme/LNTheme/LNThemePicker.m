//
//  LNThemePicker.m
//  LNTheme
//
//  Created by vvusu on 1/19/17.
//  Copyright © 2017 vvusu. All rights reserved.
//

#import "LNThemePicker.h"
#import "LNTheme.h"

@implementation LNThemePicker

+ (instancetype)initWithColorType:(NSString *)type {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.block = ^() {
       return [LNTheme colorForType:type];
    };
    return picker;
}

+ (instancetype)initWithImageName:(NSString *)name {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.block = ^() {
       return [LNTheme imageNamed:name];
    };
    return picker;
}

+ (instancetype)initWithImageColorType:(NSString *)type size:(CGSize)size {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.block = ^() {
        return [LNTheme imageForColorType:type size:size];
    };
    return picker;
}

+ (instancetype)initWithImageName:(NSString *)name renderingMode:(UIImageRenderingMode)mode {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.block = ^() {
        return [[LNTheme imageNamed:name] imageWithRenderingMode:mode];
    };
    return picker;
}

+ (instancetype)initTextAttributesColorType:(NSString *)color font:(NSString *)font {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.block = ^() {
        NSDictionary *textAttributes = @{NSFontAttributeName:[LNTheme fontForType:font],
                                         NSForegroundColorAttributeName:[LNTheme colorForType:color]};
        return textAttributes;
    };
    return picker;
}

#pragma mark - UIControlState

+ (instancetype)initWithColorType:(NSString *)type forState:(UIControlState)state {
    LNThemePicker *picker = [self initWithColorType:type];
    picker.valueState = state;
    picker.type = ThemeStatePicker;
    return picker;
}

+ (instancetype)initWithImageName:(NSString *)name forState:(UIControlState)state {
   LNThemePicker *picker = [self initWithImageName:name];
    picker.valueState = state;
    picker.type = ThemeStatePicker;
    return picker;
}

+ (instancetype)initWithImageName:(NSString *)name forBarMetrics:(UIBarMetrics)state {
    LNThemePicker *picker = [self initWithImageName:name];
    picker.type = ThemeStatePicker;
    picker.valueState = (NSUInteger)state;
    return picker;
}

+ (instancetype)initWithImageWithColorType:(NSString *)type size:(CGSize)size forState:(UIControlState)state {
    LNThemePicker *picker = [self initWithImageColorType:type size:size];
    picker.valueState = state;
    picker.type = ThemeStatePicker;
    return picker;
}

+ (instancetype)initTextAttributesColorType:(NSString *)color font:(NSString *)font forState:(UIControlState)state {
    LNThemePicker *picker = [self initTextAttributesColorType:color font:font];
    picker.valueState = state;
    picker.type = ThemeStatePicker;
    return picker;
}

#pragma mark - ThemeCGColorPicker

+ (instancetype)initWithCGColor:(NSString *)type {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.type = ThemeCGColorPicker;
    picker.block = ^() {
        return [LNTheme colorForType:type];
    };
    return picker;
}

#pragma mark - ThemeCGFloatPicker

+ (instancetype)initWithCGFloat:(CGFloat)num {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.type = ThemeCGFloatPicker;
    picker.block = ^() {
        return [NSNumber numberWithFloat:num];
    };
    return picker;
}

#pragma mark - ThemeEdgeInsetPicker

+ (instancetype)initWithImageInsets:(NSString *)type {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.type = ThemeEdgeInsetPicker;
    picker.block = ^() {
        return [NSValue valueWithUIEdgeInsets:[LNTheme edgeInsetsForType:type]];
    };
    return picker;
}

#pragma mark - ThemeStatusBarPicker

+ (instancetype)initWithStatusBarAnimated:(BOOL)animated {
    LNThemePicker *picker = [[LNThemePicker alloc]init];
    picker.type = ThemeStatusBarPicker;
    picker.valueState = animated;
    picker.block = ^() {
        return [NSNumber numberWithFloat:0];
    };
    return picker;
}

@end
