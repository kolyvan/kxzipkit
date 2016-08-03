//
//  KxUnzipArchive.h
//  https://github.com/kolyvan/kxzipkit
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

/*
 Copyright (c) 2015 Konstantin Bukreev All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

extern NSString *const KxZipKitDomain;

typedef NS_ENUM(NSInteger, KxZipKitError) {

    KxZipKitErrorUnzipAny = 1,
    KxZipKitErrorUnzipEOF,
    KxZipKitErrorUnzipParam,
    KxZipKitErrorUnzipBadFile,
    KxZipKitErrorUnzipInternal,
    KxZipKitErrorUnzipCrc,
    KxZipKitErrorUnzipBadName,
    KxZipKitErrorUnzipFileExists,
    KxZipKitErrorUnzipFileIO,
};

@class KxUnzipFile;

@interface KxUnzipArchive : NSObject

@property (readonly, nonatomic) NSUInteger numFiles;
@property (readonly, nonatomic, strong) NSArray *files;
@property (readonly, nonatomic, strong) NSString *comment;
@property (readwrite, nonatomic, strong) NSArray *fallbackEncodings;

+ (instancetype) unzipWithPath:(NSString *)path;

- (instancetype) initWithPath:(NSString *)path
                     password:(NSString *)password;

- (NSData *) readDataForFilePath:(NSString *)path;
- (NSData *) readDataForFilePath:(NSString *)path error:(NSError **)error;

- (NSData *) readDataForFile:(KxUnzipFile *)file;
- (NSData *) readDataForFile:(KxUnzipFile *)file error:(NSError **)error;

- (BOOL) readDataForFile:(KxUnzipFile *)file
                   block:(BOOL(^)(NSData *chunk))block;

- (BOOL) readDataForFile:(KxUnzipFile *)file
                   error:(NSError **)error
                   block:(BOOL(^)(NSData *chunk))block;

- (BOOL) readDataForFile:(KxUnzipFile *)file
               chunkSize:(NSUInteger)chunkSize
                   block:(BOOL(^)(NSData *chunk))block;

- (BOOL) readDataForFile:(KxUnzipFile *)file
               chunkSize:(NSUInteger)chunkSize
                   error:(NSError **)error
                   block:(BOOL(^)(NSData *chunk))block;

- (NSUInteger) extractToPath:(NSString *)folder;
- (NSUInteger) extractToPath:(NSString *)folder error:(NSError **)error;
- (NSUInteger) extractToPath:(NSString *)folder overwrite:(BOOL)overwrite;
- (NSUInteger) extractToPath:(NSString *)folder overwrite:(BOOL)overwrite error:(NSError **)error;

- (KxUnzipFile *) fileWithPath:(NSString *)path;

+ (BOOL) probeFileAtPath:(NSString *)path;

@end


@interface KxUnzipFile : NSObject
@property (readonly, nonatomic, strong) NSString *path;
@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSUInteger fileMode;
@property (readonly, nonatomic) NSUInteger compressedSize;
@property (readonly, nonatomic) NSUInteger uncompressedSize;
@property (readonly, nonatomic) NSUInteger crc32;
@property (readonly, nonatomic) BOOL isCrypted;
@property (readonly, nonatomic) BOOL isDirectory;
@end