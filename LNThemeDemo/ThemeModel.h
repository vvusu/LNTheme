//
//  ThemeModel.h
//  GoldUISSFramework
//
//  Created by vvusu on 12/29/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeModel : NSObject
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, strong) NSString *descriptionField;
@property (nonatomic, strong) NSString *digitalAlbumId;
@property (nonatomic, strong) NSString *downCount;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *downloadedSize;
@property (nonatomic, strong) NSString *fileSize;
@property (nonatomic, strong) NSString *goodId;
@property (nonatomic, strong) NSString *idField;
@property (nonatomic, strong) NSString *isNew;
@property (nonatomic, strong) NSString *mininumRequiredVersion;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *paid;
@property (nonatomic, strong) NSString *pointCost;
@property (nonatomic, strong) NSArray *previewImgs;
@property (nonatomic, strong) NSString *relativeFilePath;
@property (nonatomic, strong) NSString *removedByServer;
@property (nonatomic, strong) NSString *rmbCost;
@property (nonatomic, strong) NSString *skuId;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *themeType;
@property (nonatomic, strong) NSString *thumbnail;

@end
