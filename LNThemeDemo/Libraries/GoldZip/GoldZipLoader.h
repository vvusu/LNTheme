//
//  GoldZipLoader.h
//  GoldZIPFramework
//
//  Created by Micker on 16/9/12.
//  Copyright © 2016年 Micker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoldZipLoader : NSObject

+ (void) downloadFile:(NSURL *) downloadURL destination:(NSString *) destination block:(void(^)(NSError *error))callback;

+ (void)setLogger:(void(^)(NSString *log))logger;

+ (NSString *) fileAtLibrary:(NSString *) path;

+ (NSString *)fileMD5:(NSString *)filePath;

@end
