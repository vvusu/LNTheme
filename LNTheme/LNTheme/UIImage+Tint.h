//
//  UIImage+Tint.h
//  LNStock
//
//  Created by vvusu on 8/30/16.
//  Copyright © 2016 vvusu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)
- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;
+ (UIImage *)imageWithName:(NSString *)name tintColor:(UIColor *)tintColor;
+ (UIImage *)imageWithName:(NSString *)name bradientTintColor:(UIColor *)tintColor;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)imageSize;
@end
