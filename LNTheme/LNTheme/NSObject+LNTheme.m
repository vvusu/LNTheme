//
//  NSObject+LNTheme.m
//  GoldUISSFramework
//
//  Created by vvusu on 1/16/17.
//  Copyright © 2017 Micker. All rights reserved.
//

#import "NSObject+LNTheme.h"
#import <objc/runtime.h>
#import "LNThemePicker.h"

static BOOL isChangeTheme;
static void *LNTheme_ThemeMap;
static NSHashTable *themeHashTable;

@implementation NSObject (LNTheme)
- (NSHashTable *)themeHashTable {
    if (!themeHashTable) {
        themeHashTable = [NSHashTable weakObjectsHashTable];
    }
    return themeHashTable;
}

- (NSMutableDictionary *)themePickers {
    NSMutableDictionary *themeMap = objc_getAssociatedObject(self, &LNTheme_ThemeMap);
    if (themeMap) {
        return themeMap;
    } else {
        themeMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &LNTheme_ThemeMap, themeMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return themeMap;
    }
}

- (void)setThemePickers:(NSMutableDictionary *)themePickers {
    objc_setAssociatedObject(self, &LNTheme_ThemeMap, themePickers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (themePickers) {
        if (!isChangeTheme) {
            [self.themeHashTable addObject:self];
        }
    }
}

//添加标识设置属性
- (void)setThemePicker:(NSObject *)object selector:(NSString *)sel picker:(LNThemePicker *)picker {
    NSMutableArray *pickers = [object.themePickers valueForKey:sel];
    if (!pickers) { pickers = [NSMutableArray array]; }
    [pickers addObject:picker];
    [object.themePickers setValue:pickers forKey:sel];
    [object performThemePicker:sel picker:picker];
    //hastable添加会自动去重
    if (!isChangeTheme) {
        [self.themeHashTable addObject:object];
    }
}

//更新主题
- (void)updateTheme {
    isChangeTheme = YES;
    for (NSObject *object in self.themeHashTable) {
        [object.themePickers enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableArray *pickers, BOOL *stop) {
            [pickers enumerateObjectsUsingBlock:^(LNThemePicker* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type != ThemePicker_Font) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [object performThemePicker:key picker:obj];
                    });
                }
            }];
        }];
    }
    isChangeTheme = NO;
}

//更新字体
- (void)updateFont {
    isChangeTheme = YES;
    for (NSObject *object in self.themeHashTable) {
        [object.themePickers enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableArray *pickers, BOOL *stop) {
            [pickers enumerateObjectsUsingBlock:^(LNThemePicker* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type == ThemePicker_Font) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [object performThemePicker:key picker:obj];
                    });
                }
            }];
        }];
    }
    isChangeTheme = NO;
}

//解析，动态设置属性
- (void)performThemePicker:(NSString *)selStr picker:(LNThemePicker *)picker {
    SEL selector = NSSelectorFromString(selStr);
    //判断有没有方法
    if (![self respondsToSelector:selector]) { return; }
    id value = picker.block();
    if (!value) { return; }
    IMP imp = [self methodForSelector:selector];

    //调用方法
    switch (picker.type) {
        case ThemePicker_Nomal:
        case ThemePicker_Font: {
            void (*func)(id, SEL, id) = (void *)imp;
            func(self, selector, value);
        }
            break;
        case ThemePicker_State: {
            void (*func)(id, SEL, id, UIControlState) = (void *)imp;
            func(self, selector, value, picker.valueState);
        }
            break;
        case ThemePicker_CGColor: {
            void (*func)(id, SEL, CGColorRef) = (void *)imp;
            CGColorRef color = ((UIColor *)value).CGColor;
            func(self, selector, color);
        }
            break;
        case ThemePicker_CGFloat: {
            void (*func)(id, SEL, CGFloat) = (void *)imp;
            NSNumber *num = value;
            func(self, selector, num.floatValue);
        }
            break;
        case ThemePicker_EdgeInset: {
            void (*func)(id, SEL, UIEdgeInsets) = (void *)imp;
            NSValue *empty = value;
            func(self, selector, empty.UIEdgeInsetsValue);
        }
            break;
        case ThemePicker_StatusBar: {
            void (*func)(id, SEL, UIStatusBarStyle, BOOL) = (void *)imp;
            NSNumber *num = value;
            UIStatusBarStyle style = num.integerValue;
            func(self, selector, style, picker.valueState);
        }
            break;
    }
}

- (void)ln_customFontAction:(id(^)(void))block {
    LNThemePicker *picker = [[LNThemePicker alloc] init];
    picker.type = ThemePicker_Font;
    picker.block = block;
    [self setThemePicker:self selector:@"ln_customFontInternalAction" picker:picker];
}

- (void)ln_customThemeAction:(id(^)(void))block {
    LNThemePicker *picker = [[LNThemePicker alloc] init];
    picker.type = ThemePicker_Nomal;
    picker.block = block;
    [self setThemePicker:self selector:@"ln_customThemeInternalAction" picker:picker];
}

//自定义主题事件只是为了注册方法
- (void)ln_customThemeInternalAction {
}

//自定义Font触发事件
- (void)ln_customFontInternalAction {
}

@end

@implementation UIColor (LNTheme)
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end

@implementation UIFont (LNTheme)
+ (UIFont *)fontWithHexString:(NSString *)hexString {
    NSArray *array = [hexString componentsSeparatedByString:@","];
    if (array.count == 1) {
        NSString *fontSize = array.firstObject;
        return [UIFont systemFontOfSize:fontSize.floatValue];
    }
    else if (array.count == 2) {
        NSString *fontName = array.firstObject;
        CGFloat fontSize = ((NSString *)array.lastObject).floatValue;
        UIFont *defaultFont = [UIFont systemFontOfSize:fontSize];
        
        if ([[fontName lowercaseString] isEqualToString:@"b"]) {
            return [UIFont boldSystemFontOfSize:fontSize];
        }
        else if ([[fontName lowercaseString] isEqualToString:@"i"]) {
            return [UIFont italicSystemFontOfSize:fontSize];
        }
        else if ([fontName hasPrefix:@"sw"]) {
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.2) {
                NSString *fontWeight = [fontName substringWithRange:NSMakeRange(2, 1)];
                return [UIFont systemFontOfSize:fontSize weight:[UIFont weightFromString:fontWeight]];
            }
            else {
                return defaultFont;
            }
        }
        else if ([fontName hasPrefix:@"smw"]) {
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
                NSString *fontWeight = [fontName substringWithRange:NSMakeRange(3, 1)];
                return [UIFont monospacedDigitSystemFontOfSize:fontSize weight:[UIFont weightFromString:fontWeight]];
            }
            else {
                return defaultFont;
            }
        }
        else {
            return [UIFont fontWithName:fontName size:fontSize];
        }
    }
    else {
        return [UIFont systemFontOfSize:hexString.floatValue];
    }
}

+ (CGFloat)weightFromString:(NSString *)string {
    if ([string isEqualToString:@"u"]) {
        return UIFontWeightUltraLight;
    }
    else if ([string isEqualToString:@"t"]) {
        return UIFontWeightThin;
    }
    else if ([string isEqualToString:@"l"]) {
        return UIFontWeightLight;
    }
    else if ([string isEqualToString:@"r"]) {
        return UIFontWeightRegular;
    }
    else if ([string isEqualToString:@"m"]) {
        return UIFontWeightMedium;
    }
    else if ([string isEqualToString:@"s"]) {
        return UIFontWeightSemibold;
    }
    else if ([string isEqualToString:@"B"]) {
        return UIFontWeightBold;
    }
    else if ([string isEqualToString:@"h"]) {
        return UIFontWeightHeavy;
    }
    else if ([string isEqualToString:@"b"]) {
        return UIFontWeightBlack;
    } else {
        return UIFontWeightUltraLight;
    }
}

@end

#pragma mark - UIView

@implementation UIApplication (LNTheme)
- (void)ln_setStatusBarAnimated:(BOOL)animated {
    [self setThemePicker:self selector:@"setStatusBarStyle:animated:"
                  picker:[LNThemePicker initWithStatusBarAnimated:animated]];
}

@end

@implementation UIView (LNTheme)
- (void)ln_tintColor:(NSString *)type {
    [self setThemePicker:self selector:@"setTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_backgroundColor:(NSString *)type {
    [self setThemePicker:self selector:@"setBackgroundColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UITabBar (LNTheme)
- (void)ln_bartintColor:(NSString *)type {
    [self setThemePicker:self selector:@"setBarTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_backgroundImageNamed:(NSString *)name {
    [self setThemePicker:self selector:@"setBackgroundImage:" picker:[LNThemePicker initWithImageName:name]];
}

@end

@implementation UITabBarItem (LNTheme)

- (void)ln_imageNamed:(NSString *)name renderingMode:(UIImageRenderingMode)mode {
    [self setThemePicker:self selector:@"setImage:"
                  picker:[LNThemePicker initWithImageName:name renderingMode:mode]];
}

- (void)ln_selectedImageNamed:(NSString *)name renderingMode:(UIImageRenderingMode)mode {
    [self setThemePicker:self selector:@"setSelectedImage:"
                  picker:[LNThemePicker initWithImageName:name renderingMode:mode]];
}

- (void)ln_imageInsets:(NSString *)type {
    [self setThemePicker:self selector:@"setImageInsets:"
                  picker:[LNThemePicker initWithImageInsets:type]];
}

- (void)ln_titleTextAttributesColorType:(NSString *)colorType font:(NSString *)fontType forState:(UIControlState)state {
    [self setThemePicker:self selector:@"setTitleTextAttributes:forState:"
                  picker:[LNThemePicker initTextAttributesColorType:colorType font:fontType forState:state]];
}

@end

@implementation UINavigationBar (LNTheme)
- (void)ln_bartintColor:(NSString *)type {
    [self setThemePicker:self selector:@"setBarTintColor:" picker:[LNThemePicker initWithColorType:type]];
}


- (void)ln_titleTextAttributesColorType:(NSString *)colorType font:(NSString *)fontType {
    [self setThemePicker:self selector:@"setTitleTextAttributes:"
                  picker:[LNThemePicker initTextAttributesColorType:colorType font:fontType]];
}

- (void)ln_backgroundImageNamed:(NSString *)name forBarMetrics:(UIBarMetrics)state {
     [self setThemePicker:self selector:@"setBackgroundImage:forBarMetrics:"
                   picker:[LNThemePicker initWithImageName:name forBarMetrics:state]];
}

@end

@implementation UIBarButtonItem (LNTheme)
- (void)ln_tintColor:(NSString *)type {
    [self setThemePicker:self selector:@"setTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UILabel (LNTheme)
- (void)ln_font:(NSString *)type {
    [self setThemePicker:self selector:@"setFont:" picker:[LNThemePicker initWithFontType:type]];
}

- (void)ln_textColor:(NSString *)type {
    [self setThemePicker:self selector:@"setTextColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_shadowColor:(NSString *)type {
    [self setThemePicker:self selector:@"setShadowColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_highlightedTextColor:(NSString *)type {
    [self setThemePicker:self selector:@"setHighlightedTextColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UIButton (LNTheme)
- (void)ln_titleFont:(NSString *)type {
    [self setThemePicker:self.titleLabel selector:@"setFont:" picker:[LNThemePicker initWithFontType:type]];
}

- (void)ln_imageNamed:(NSString *)name forState:(UIControlState)state {
    [self setThemePicker:self selector:@"setImage:forState:"
                  picker:[LNThemePicker initWithImageName:name forState:(UIControlState)state]];
}

- (void)ln_backgroundImageNamed:(NSString *)name forState:(UIControlState)state {
    [self setThemePicker:self selector:@"setBackgroundImage:forState:"
                  picker:[LNThemePicker initWithImageName:name forState:(UIControlState)state]];
}

- (void)ln_backgroundImageWithColorType:(NSString *)type size:(CGSize)size forState:(UIControlState)state {
    [self setThemePicker:self selector:@"setBackgroundImage:forState:"
                  picker:[LNThemePicker initWithImageWithColorType:type size:size forState:(UIControlState)state]];
}

- (void)ln_titleColor:(NSString *)type forState:(UIControlState)state {
    [self setThemePicker:self selector:@"setTitleColor:forState:"
                  picker:[LNThemePicker initWithColorType:type forState:state]];
}

@end

@implementation UIImageView (LNTheme)
- (void)ln_imageNamed:(NSString *)name {
    [self setThemePicker:self selector:@"setImage:" picker:[LNThemePicker initWithImageName:name]];
}

- (void)ln_imageWithColorType:(NSString *)type size:(CGSize)size {
    [self setThemePicker:self selector:@"setImage:" picker:[LNThemePicker initWithImageColorType:type size:size]];
}

@end

@implementation CALayer (LNTheme)
- (void)ln_borderColor:(NSString *)type {
  [self setThemePicker:self selector:@"setBorderColor:" picker:[LNThemePicker initWithCGColor:type]];
}

- (void)ln_shadowColor:(NSString *)type {
  [self setThemePicker:self selector:@"setShadowColor:" picker:[LNThemePicker initWithCGColor:type]];
}

- (void)ln_backgroundColor:(NSString *)type {
  [self setThemePicker:self selector:@"setBackgroundColor:" picker:[LNThemePicker initWithCGColor:type]];
}

@end

@implementation UITextField (LNTheme)
- (void)ln_textFont:(NSString *)type {
    [self setThemePicker:self selector:@"setFont:" picker:[LNThemePicker initWithFontType:type]];
}

- (void)ln_textColor:(NSString *)type {
   [self setThemePicker:self selector:@"setTextColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UITextView (LNTheme)
- (void)ln_textFont:(NSString *)type {
    [self setThemePicker:self selector:@"setFont:" picker:[LNThemePicker initWithFontType:type]];
}

- (void)ln_textColor:(NSString *)type {
   [self setThemePicker:self selector:@"setTextColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UISlider (LNTheme)
- (void)ln_thumbTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setThumbTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_minimumTrackTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setMinimumTrackTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_maximumTrackTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setMaximumTrackTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UISwitch (LNTheme)
- (void)ln_onTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setOnTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_thumbTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setThumbTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UIProgressView (LNTheme)
- (void)ln_trackTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setTrackTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

- (void)ln_progressTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setProgressTintColor:" picker:[LNThemePicker initWithColorType:type]];
}

@end

@implementation UIPageControl (LNTheme)
- (void)ln_pageIndicatorTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setPageIndicatorTintColor:" picker:[LNThemePicker initWithColorType:type]];
}
    
- (void)ln_currentPageIndicatorTintColor:(NSString *)type {
   [self setThemePicker:self selector:@"setCurrentPageIndicatorTintColor:" picker:[LNThemePicker initWithColorType:type]];
}
    
@end

@implementation UISearchBar (LNTheme)
- (void)ln_barTintColor:(NSString *)type {
    [self setThemePicker:self selector:@"setBarTintColor:" picker:[LNThemePicker initWithColorType:type]];
}
    
@end

