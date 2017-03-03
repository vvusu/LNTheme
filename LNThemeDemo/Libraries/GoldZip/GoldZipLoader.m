//
//  GoldZipLoader.m
//  GoldZIPFramework
//
//  Created by Micker on 16/9/12.
//  Copyright © 2016年 Micker. All rights reserved.
//

#import "GoldZipLoader.h"
#import "ZipArchive.h"
#import <CommonCrypto/CommonDigest.h>

void (^GoldZIPLogger)(NSString *log);

@implementation GoldZipLoader

+ (void) copyFilesFromDirectory:(NSString *)srcDir toDirectory:(NSString *)destDir{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSArray* filenames = [fileMgr contentsOfDirectoryAtPath:srcDir error:nil];
    for (NSString *filename in filenames) {
        NSString* srcFilePath = [srcDir stringByAppendingPathComponent:filename];
        NSString *destFilePath = [destDir stringByAppendingPathComponent:filename];
//        NSString* latestDirectory = [destFilePath stringByDeletingLastPathComponent];
//        NSError* sError = nil;
//        BOOL isDir = NO;
//        if (![fileMgr fileExistsAtPath:latestDirectory isDirectory:&isDir] || !isDir){
//            [fileMgr createDirectoryAtPath:latestDirectory withIntermediateDirectories:YES attributes:nil error:&sError];
//        }
        [[NSFileManager defaultManager] copyItemAtPath:srcFilePath toPath:destFilePath error:nil];
    }
}

+ (void) downloadFile:(NSURL *) downloadURL destination:(NSString *) destination block:(void(^)(NSError *error))callback {

    if (!downloadURL || !destination) {
        if (GoldZIPLogger) GoldZIPLogger([NSString stringWithFormat:@"ZIP: downloadURL or destination should not be nil!!"]);
        return;
    }
    
    NSString *directory = destination;
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:30.0];
    
    if (GoldZIPLogger) GoldZIPLogger([NSString stringWithFormat:@"ZIP: request file %@", downloadURL]);
    
    // create task
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (GoldZIPLogger) GoldZIPLogger([NSString stringWithFormat:@"ZIP: request file success, data length:%@", @(data.length)]);
            
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];

            NSString *filename = [[downloadURL absoluteString] lastPathComponent];
            NSString *downloadTmpPath = [NSString stringWithFormat:@"%@zip_%@", NSTemporaryDirectory(), filename];
            NSString *unzipTmpDirectory = [NSString stringWithFormat:@"%@unzip_%@/", NSTemporaryDirectory(), @(arc4random())];
            [data writeToFile:downloadTmpPath atomically:YES];
            
            BOOL isFnished = NO;

            NSString *originZip = [directory stringByAppendingPathComponent:filename];
//            NSString *localMD5 = [self fileMD5:originZip];
//            NSString *remoteMD5 = [self fileMD5:downloadTmpPath];
//            if (![localMD5 isEqualToString:remoteMD5]) {
//                if (GoldZIPLogger)  {
//                    GoldZIPLogger([NSString stringWithFormat:@"ZIP: MD5 didn't matched, \norigin :%@ || remote:%@", localMD5, remoteMD5]);
//                }
//                if (callback) {
//                    callback([NSError errorWithDomain:@"cn.micker" code:0 userInfo:nil]);
//                }
//            }
            
            if (!isFnished) {
                ZipArchive *zipArchive = [[ZipArchive alloc] init];
                [zipArchive UnzipOpenFile:downloadTmpPath];
                BOOL unzipSucc = [zipArchive UnzipFileTo:unzipTmpDirectory overWrite:YES];
                if (unzipSucc) {
                    [GoldZipLoader copyFilesFromDirectory:unzipTmpDirectory toDirectory:directory];
                }else{
                    if (GoldZIPLogger) GoldZIPLogger(@"ZIP: fail to unzip script file");
                    isFnished = YES;
                    if (callback) {
                        callback([NSError errorWithDomain:@"cn.micker" code:1000 userInfo:nil]);
                    }
                }
            }
            
            // success
            if (!isFnished) {
                if (GoldZIPLogger) GoldZIPLogger([NSString stringWithFormat:@"ZIP: download zip [%@] file success, @ [%@]", downloadURL, originZip]);
                [data writeToFile:originZip atomically:YES];
                if (callback) callback(nil);
            }
            
            // clear temporary files
            [[NSFileManager defaultManager] removeItemAtPath:downloadTmpPath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:unzipTmpDirectory error:nil];
        }
        else {
            if (GoldZIPLogger) GoldZIPLogger([NSString stringWithFormat:@"ZIP: request error %@", error]);
            if (callback) callback(error);
        }
    }];
    [task resume];
}

+ (NSString *) fileAtLibrary:(NSString *) path {
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *scriptDirectory = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/", path]];
    return scriptDirectory;
}

#pragma mark utils

+ (NSString *)fileMD5:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if(!handle){
        return nil;
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while (!done){
        NSData *fileData = [handle readDataOfLength:256];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if([fileData length] == 0)
            done = YES;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSString *result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        digest[0], digest[1],
                        digest[2], digest[3],
                        digest[4], digest[5],
                        digest[6], digest[7],
                        digest[8], digest[9],
                        digest[10], digest[11],
                        digest[12], digest[13],
                        digest[14], digest[15]];
    return result;
}


+ (void)setLogger:(void (^)(NSString *))logger {
    GoldZIPLogger = [logger copy];
}

@end
