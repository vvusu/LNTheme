//
//  LNTheme.m
//  GoldUISSFramework
//
//  Created by vvusu on 12/30/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "LNTheme.h"
#import "UIImage+Tint.h"
#import <objc/runtime.h>

NSString *const LN_THEME_DEFAULT_NAME = @"default";
NSString *const LN_FONT_DEFAULT_KEY = @"com.vvusu.LNTheme.defaultFont";
NSString *const LN_THEME_DEFAULT_KEY = @"com.vvusu.LNTheme.defaultTheme";
NSString *const LN_THEME_ROOTPATH = @"/Library/UserData/Skin/CurrentTheme";

@interface LNTheme()
@property (nonatomic, strong, readwrite) NSString *currentFont;
@property (nonatomic, strong, readwrite) NSString *currentTheme;
@property (nonatomic, strong, readwrite) NSString *currentThemePath;
@property (nonatomic, strong, readwrite) NSMutableDictionary *localFonts;
@property (nonatomic, strong, readwrite) NSMutableDictionary *localThemes;
@property (nonatomic, strong, readwrite) NSMutableDictionary *currentFontDic;
@property (nonatomic, strong, readwrite) NSMutableDictionary *currentColorDic;
@property (nonatomic, strong, readwrite) NSMutableDictionary *currentOffsetDic;
@property (nonatomic, strong, readwrite) NSMutableDictionary *currentOthersDic;
@end
@implementation LNTheme

+ (instancetype)instance {
    static LNTheme *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (NSMutableDictionary *)localThemes {
    if (!_localThemes) {
        _localThemes = [NSMutableDictionary dictionary];
    }
    return _localThemes;
}

- (NSMutableDictionary *)localFonts {
    if (!_localFonts) {
        _localFonts = [NSMutableDictionary dictionary];
    }
    return _localFonts;
}

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *themeFont = [defaults objectForKey:LN_FONT_DEFAULT_KEY];
        NSString *themeName = [defaults objectForKey:LN_THEME_DEFAULT_KEY];
        if (!themeName) {
            themeName = LN_THEME_DEFAULT_NAME;
        }
        if (!themeFont) {
            themeFont = LN_THEME_DEFAULT_NAME;
        }
        [self changeTheme:themeName];
        [self changeFont:themeFont];
    }
    return self;
}

- (void)registerSubFrameworks {
    unsigned int count;
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        if ([name hasPrefix:@"registerTheme_"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:NSSelectorFromString(name) withObject:nil];
#pragma clang diagnostic pop
        }
    }
    [[LNTheme instance] changeTheme:[LNTheme instance].currentTheme];
    [[LNTheme instance] changeTheme:[LNTheme instance].currentFont];
}

- (void)setCurrentFont:(NSString *)currentFont {
    _currentFont = currentFont;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentFont forKey:LN_FONT_DEFAULT_KEY];
    [defaults synchronize];
}

- (void)setCurrentTheme:(NSString *)currentTheme {
    _currentTheme = currentTheme;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentTheme forKey:LN_THEME_DEFAULT_KEY];
    [defaults synchronize];
}

- (void)changeTheme:(NSString *)themeName {
    [self getThemeDicFromJsonFileWithName:themeName isFont:NO];
}

- (void)changeFont:(NSString *)fontName {
    [self getThemeDicFromJsonFileWithName:fontName isFont:YES];
}

- (void)getThemeDicFromJsonFileWithName:(NSString *)name isFont:(BOOL)isFont {
    NSMutableArray *JsonFileArr = isFont ? [self.localFonts valueForKey:name] : [self.localThemes valueForKey:name];
    if (!JsonFileArr) { JsonFileArr = [NSMutableArray array];}
    self.currentThemePath = [NSString stringWithFormat:@"%@/%@",[LNTheme themeRootPath],name];
    
    //如果没有主题文件路径
    if ([LNTheme isFileExistAtPath:self.currentThemePath]) {
        NSArray *fileNames = [LNTheme getFilenamelistOfType:@"json" fromDirPath:self.currentThemePath];
        for (NSString *name in fileNames) {
            NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@",self.currentThemePath,name];
            [JsonFileArr addObject:fileFullPath];
        }
    } else {
        if (0 == JsonFileArr.count) {
            if (isFont) {
                self.currentFont = LN_THEME_DEFAULT_NAME;
            } else {
                self.currentTheme = LN_THEME_DEFAULT_NAME;
            }
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"defaultTheme" ofType:@"json"];
            if (filePath) {
                [JsonFileArr addObject:filePath];
            }
        }
    }
    NSDictionary *themeTypeDic = @{@"fonts":[NSMutableDictionary dictionary],
                                   @"colors":[NSMutableDictionary dictionary],
                                   @"others":[NSMutableDictionary dictionary],
                                   @"coordinators":[NSMutableDictionary dictionary]};
    //遍历所有Json文件取出所有值
    for (NSString *filePath in JsonFileArr) {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData) {
            NSError *error = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
            for (NSString *key in [jsonDic allKeys]) {
                NSMutableDictionary *dic = [themeTypeDic valueForKey:key];
                if (!dic) {
                    dic = [themeTypeDic valueForKey:@"others"];
                    [dic setObject:[jsonDic valueForKey:key] forKey:key];
                } else {
                    [dic setValuesForKeysWithDictionary:[jsonDic valueForKey:key]];
                }
            }
        }
    }
    //添加配置
    if (isFont) {
        self.currentFont = name;
        self.currentFontDic = [themeTypeDic valueForKey:@"fonts"];
    } else {
        self.currentTheme = name;
        self.currentColorDic = [themeTypeDic valueForKey:@"colors"];
        self.currentOthersDic = [themeTypeDic valueForKey:@"others"];
        self.currentOffsetDic = [themeTypeDic valueForKey:@"coordinators"];
    }
}

#pragma mark - Method

+ (void)changeTheme:(NSString *)themeName {
    [[LNTheme instance] changeTheme:themeName];
    [[LNTheme instance] updateTheme];
}

+ (void)changeFont:(NSString *)fontName {
    [[LNTheme instance] changeFont:fontName];
    [[LNTheme instance] updateFont];
}

+ (void)addFont:(NSString *)fontName forPath:(NSString *)path {
    if ([fontName length] > 0 && [path length] > 0) {
        NSMutableArray *array = [[LNTheme instance].localFonts valueForKey:fontName];
        if (!array) {
            array = [NSMutableArray array];
            [[LNTheme instance].localFonts setValue:array forKey:fontName];
        }
        [array addObject:path];
    }
}

+ (void)addTheme:(NSString *)themeName forPath:(NSString *)path {
    if ([themeName length] > 0 && [path length] > 0) {
        NSMutableArray *array = [[LNTheme instance].localThemes valueForKey:themeName];
        if (!array) {
            array = [NSMutableArray array];
            [[LNTheme instance].localThemes setValue:array forKey:themeName];
        }
        [array addObject:path];
    }
}

#pragma mark - Image

+ (UIImage *)imageNamed:(NSString *)name {
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",[LNTheme instance].currentThemePath,name];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        image = [UIImage imageNamed:name];
        //找不到去本地json配置中找key
        image = image?:[UIImage imageNamed:[LNTheme instance].currentOthersDic[name]];
    }
    return image;
}

+ (UIImage *)imageForColorType:(NSString *)type size:(CGSize)size {
   return [UIImage imageWithColor:[LNTheme colorForType:type] size:size];
}

#pragma mark - Color

+ (UIColor *)colorForType:(NSString *)type {
    if (type) {
        NSString *hexString = [LNTheme instance].currentColorDic[type];
        NSInteger lenth = hexString.length;
        switch (lenth) {
            case 3:
            case 4:
            case 6:
            case 8:
                return [UIColor colorWithHexString:hexString];
                break;
            default:
                return [UIColor whiteColor];
                break;
        }
    } else {
        return [UIColor clearColor];
    }
}

#pragma mark - Font

+ (UIFont *)fontForType:(NSString *)type {
    if (type) {
        NSString *hexString = [LNTheme instance].currentFontDic[type];
        if (hexString) {
            return [UIFont fontWithHexString:hexString];
        } else {
            return [UIFont systemFontOfSize:14];
        }
    } else {
        return [UIFont systemFontOfSize:14];
    }
}

#pragma mark - Coorderate

+ (CGPoint)pointForType:(NSString *)type {
   NSArray *array = [LNTheme getCoordinatorValuesWithType:type];
    if (2 == [array count]) {
        return CGPointMake([[self class] floatWithValue:array[0]],
                           [[self class] floatWithValue:array[1]]);
    }
    return CGPointZero;
}

+ (CGVector)vectorForType:(NSString *)type {
   NSArray *array = [LNTheme getCoordinatorValuesWithType:type];
    if (2 == [array count]) {
        return CGVectorMake([[self class] floatWithValue:array[0]],
                            [[self class] floatWithValue:array[1]]);
    }
    return CGVectorMake(0, 0);
}

+ (CGSize)sizeForType:(NSString *)type {
    NSArray *array = [LNTheme getCoordinatorValuesWithType:type];
    if (2 == [array count]) {
        return CGSizeMake([[self class] floatWithValue:array[0]],
                          [[self class] floatWithValue:array[1]]);
    }
    return CGSizeZero;
}

+ (CGRect)rectForType:(NSString *)type {
    NSArray *array = [LNTheme getCoordinatorValuesWithType:type];
    if (4 == [array count]) {
        return CGRectMake([[self class] floatWithValue:array[0]],
                          [[self class] floatWithValue:array[1]],
                          [[self class] floatWithValue:array[2]],
                          [[self class] floatWithValue:array[3]]);
    }
    return CGRectZero;
}

+ (UIEdgeInsets)edgeInsetsForType:(NSString *)type {
    NSArray *array = [LNTheme getCoordinatorValuesWithType:type];
    if (4 == [array count]) {
        return UIEdgeInsetsMake([[self class] floatWithValue:array[0]],
                                [[self class] floatWithValue:array[1]],
                                [[self class] floatWithValue:array[2]],
                                [[self class] floatWithValue:array[3]]);
    }
    return UIEdgeInsetsZero;
}

+ (CGAffineTransform)affineTransformForType:(NSString *)type {
    NSArray *array = [LNTheme getCoordinatorValuesWithType:type];
    if (6 == [array count]) {
        return CGAffineTransformMake([[self class] floatWithValue:array[0]],
                                     [[self class] floatWithValue:array[1]],
                                     [[self class] floatWithValue:array[2]],
                                     [[self class] floatWithValue:array[3]],
                                     [[self class] floatWithValue:array[4]],
                                     [[self class] floatWithValue:array[5]]);
    }
    return CGAffineTransformIdentity;
}

+ (NSArray *)getCoordinatorValuesWithType:(NSString *)type {
    NSString *value = [LNTheme instance].currentOffsetDic[type];
    return [LNTheme arrayWithValue:value];
}

#pragma mark - OtherType

+ (id)otherForType:(NSString *)type {
    id result = [[LNTheme instance].currentOthersDic valueForKey:type];
    return result;
}

#pragma mark - Other Method

+ (CGFloat)floatWithValue:(NSString *)origin {
    NSString *numStr = origin;
    CGFloat num = numStr.floatValue;
    return num;
}

+ (BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

+ (NSArray *)arrayWithValue:(NSString *)origin {
    NSString *coordinator = [origin copy];
    coordinator = [coordinator stringByReplacingOccurrencesOfString:@"{"withString:@""];
    coordinator = [coordinator stringByReplacingOccurrencesOfString:@"}"withString:@""];
    NSArray *array = [coordinator componentsSeparatedByString:@","];
    return array;
}

+ (NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath {
    NSMutableArray *filenamelist = [NSMutableArray array];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([LNTheme isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist addObject:filename];
            }
        }
    }
    return filenamelist;
}

+ (NSString *)themeRootPath {
    return [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LN_THEME_ROOTPATH];
}

+ (NSString *)currentTheme {
    return [LNTheme instance].currentTheme;
}

+ (NSString *)currentFont {
    return [LNTheme instance].currentFont;
}

@end
