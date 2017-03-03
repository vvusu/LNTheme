//
//  ThemeModel.m
//  GoldUISSFramework
//
//  Created by vvusu on 12/29/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "ThemeModel.h"

@implementation ThemeModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"idField" : @"id",
             @"descriptionField" : @"description"};
}

@end
