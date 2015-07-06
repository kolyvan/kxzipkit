//
//  KxUnzipArchive.m
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

#import "KxUnzipArchive.h"
#include "unzip.h"

enum
{
    ZipBitFlagNone = 0,
    ZipBitFlagEncrypted = 1 << 0,
    ZipBitFlagNormalCompression = 0,
    ZipBitFlagMaxCompression = 1 << 1,
    ZipBitFlagFastCompression = 1 << 2,
    ZipBitFlagSuperFastCompression = (1 << 1) | (1 << 2),
    ZipBitFlagEncryptionStrong = 1 << 6,
    ZipBitFlagFileNameUTF8 = 1 << 11
};

//////////
    
@interface KxUnzipFile()
@property (readwrite, nonatomic, strong) NSString *path;
@property (readwrite, nonatomic, strong) NSDate *date;
@property (readwrite, nonatomic) NSUInteger fileMode;
@property (readwrite, nonatomic) NSUInteger compressedSize;
@property (readwrite, nonatomic) NSUInteger uncompressedSize;
@property (readwrite, nonatomic) NSUInteger crc32;
@property (readwrite, nonatomic) BOOL isCrypted;
@property (readwrite, nonatomic) BOOL isDirectory;
@property (readwrite, nonatomic) char *origName;
@end

//////////

@implementation KxUnzipArchive {
    
    void        *_unzFile;
    NSArray     *_files;
    NSString    *_password;
    NSUInteger  _numFiles;
    NSString    *_comment;
}

+ (instancetype) unzipWithPath:(NSString *)path
{
    return [[KxUnzipArchive alloc] initWithPath:path password:nil];
}

- (instancetype) initWithPath:(NSString *)path
                     password:(NSString *)password
{
    void *unzFile = unzOpen64(path.fileSystemRepresentation);
    if (!unzFile) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _unzFile = unzFile;
        _password = password;
        _numFiles = NSNotFound;
    }
    return self;
}

- (void) dealloc
{
    if (_unzFile) {
        unzClose(_unzFile);
        _unzFile = NULL;
    }
}

- (void) setFallbackEncodings:(NSArray *)fallbackEncodings
{
    if (![_fallbackEncodings isEqualToArray:fallbackEncodings]) {
        
        _fallbackEncodings = fallbackEncodings;
        _files = nil;
        _comment = nil;
    }
}

- (NSUInteger) numFiles
{
    if (_numFiles == NSNotFound) {
        
        unz_global_info64 gi = {0};
        if (UNZ_OK == unzGetGlobalInfo64(_unzFile, &gi)) {
            _numFiles = gi.number_entry;
        } else {
            _numFiles = 0;
        }
    }
    return _numFiles;
}

- (NSString *) comment
{
    if (!_comment) {
        
        unz_global_info64 gi = {0};
        if (UNZ_OK == unzGetGlobalInfo64(_unzFile, &gi) &&
            gi.size_comment)
        {
            char *buffer = malloc(gi.size_comment);
            if (buffer) {
                
                if (unzGetGlobalComment(_unzFile, buffer, gi.size_comment)) {
                    
                    _comment = [[NSString alloc] initWithBytes:buffer
                                                        length:gi.size_comment
                                                      encoding:NSUTF8StringEncoding];
                }
            }
        }
        
        if (!_comment) {
            _comment = @"";
        }
    }
    return _comment;
}

- (NSArray *) files
{
    if (!_files) {
        
        NSMutableArray *ma = [NSMutableArray array];
        
        int res = unzGoToFirstFile(_unzFile);
        
        while (UNZ_OK == res) {
            
            KxUnzipFile *file = [self currentFileInZip];
            if (file) {
                [ma addObject:file];
            }
            
            res = unzGoToNextFile(_unzFile); // UNZ_END_OF_LIST_OF_FILE
        }
        
        _files = [ma copy];
    }
    return _files;
}

- (KxUnzipFile *) currentFileInZip
{
    unz_file_info64 fileInfo ={0};
    int res = unzGetCurrentFileInfo64(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
    if (res != UNZ_OK) {
        return nil;
    }
    
    if (!fileInfo.size_filename) {
        return nil;
    }
    
    char *filename = malloc(fileInfo.size_filename + 1);
    if (!filename) {
        return nil;
    }
    
    res = unzGetCurrentFileInfo64(_unzFile, &fileInfo, filename, fileInfo.size_filename, NULL, 0, NULL, 0);
    if (res != UNZ_OK) {
        free(filename);
        return nil;
    }
    
    filename[fileInfo.size_filename] = 0;
    
    // crappy 11 bit, never valid
    //const NSStringEncoding encoding = 0 != (fileInfo.flag & ZipBitFlagFileNameUTF8) ? NSUTF8StringEncoding : [self.class cp437Encoding];

    KxUnzipFile *file = [KxUnzipFile new];
    
    file.origName = filename;
    file.path = [self filePathWithBytes:filename
                                 length:fileInfo.size_filename];
    
    file.compressedSize = fileInfo.compressed_size;
    file.uncompressedSize = fileInfo.uncompressed_size;
    file.crc32 = fileInfo.crc;
    file.fileMode = fileInfo.external_fa;
    file.isCrypted = 0 != (fileInfo.flag & ZipBitFlagEncrypted);
    file.isDirectory = [file.path hasSuffix:@"/"];

    if (fileInfo.tmu_date.tm_year) {
        
        NSDateComponents *components = [NSDateComponents new];
        components.second   = fileInfo.tmu_date.tm_sec;
        components.minute   = fileInfo.tmu_date.tm_min;
        components.hour     = fileInfo.tmu_date.tm_hour;
        components.day      = fileInfo.tmu_date.tm_mday;
        components.month    = fileInfo.tmu_date.tm_mon + 1;
        components.year     = fileInfo.tmu_date.tm_year;
        
        NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        file.date = [gregorianCalendar dateFromComponents:components];
    }
    
    return file;
}

- (BOOL) locateFileInZip:(KxUnzipFile *)file
{
    const int res = unzLocateFile(_unzFile, file.origName, NULL);
    return (UNZ_OK == res);
}

- (BOOL) locateFileInZipWithPath:(NSString *)path
{
    const int res = unzLocateFile(_unzFile, path.UTF8String, NULL);
    return (UNZ_OK == res);
}

- (NSData *) readDataForFilePath:(NSString *)path
{
    if (![self locateFileInZipWithPath:path]) {
        return nil;
    }
    
    return [self currentFileReadData];
}

- (NSData *) readDataForFile:(KxUnzipFile *)file
{
    if (![self locateFileInZip:file]) {
        return nil;
    }
    
    return [self currentFileReadData];    
}

- (BOOL) readDataForFile:(KxUnzipFile *)file
                   block:(BOOL(^)(NSData *chunk))block;
{
    if (![self locateFileInZip:file]) {
        return NO;
    }
    
    return [self currentFileReadDataWithBlock:block];
}

- (NSData *) currentFileReadData
{
    NSMutableData *data = [NSMutableData data];
    
    const BOOL res = [self currentFileReadDataWithBlock:^BOOL(NSData *chunk)
                      {
                          if (chunk) {
                              [data appendData:chunk];
                          }
                          return YES;
                      }];
    
    return res ? data : nil;
}

- (BOOL) currentFileReadDataWithBlock:(BOOL(^)(NSData *chunk))block;
{
    int res;
    
    if (_password.length) {
        res = unzOpenCurrentFilePassword(_unzFile, _password.UTF8String);
    } else {
        res = unzOpenCurrentFile(_unzFile);
    }
    
    if (UNZ_OK == res) {
        
        Byte buffer[4096];
        int read;
        
        do {
            
            read = unzReadCurrentFile(_unzFile, buffer, sizeof(buffer));
            
            if (read < 0) {
                
                res = -1;
                
            } else if (read == 0) {
                
                block(nil);
                
            } else if (read > 0) {
                
                NSData *data = [NSData dataWithBytesNoCopy:buffer
                                                    length:read
                                              freeWhenDone:NO];
                if (!block(data)) {
                    break;
                }
            }
            
        } while (read > 0);
        
        unzCloseCurrentFile(_unzFile);
    }
    
    return UNZ_OK == res;
}

- (NSUInteger) extractToPath:(NSString *)folder
{
    return [self extractToPath:folder overwrite:NO];
}

- (NSUInteger) extractToPath:(NSString *)folder
                   overwrite:(BOOL)overwrite
{
    NSFileManager *fm = [NSFileManager new];
    
    NSUInteger count = 0;
    
    int res = unzGoToFirstFile(_unzFile);
    
    while (UNZ_OK == res) {
        
        if ([self extractCurrentFileToPath:folder
                                 overwrite:overwrite
                               fileManager:fm])
        {
            count += 1;
        }
        
        res = unzGoToNextFile(_unzFile); // UNZ_END_OF_LIST_OF_FILE
    }
    
    return count;
}

- (BOOL) extractCurrentFileToPath:(NSString *)destFolder
                        overwrite:(BOOL)overwrite
                      fileManager:(NSFileManager *)fileManager
{
    int res;
    
    if (_password.length) {
        res = unzOpenCurrentFilePassword(_unzFile, _password.UTF8String);
    } else {
        res = unzOpenCurrentFile(_unzFile);
    }
    
    if (UNZ_OK != res) {
        return NO;
    }
    
    NSString *path;
    char *filename = NULL;
    
    unz_file_info64 fileInfo ={0};
    unzGetCurrentFileInfo64(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
    
    if (!fileInfo.size_filename) {
        res = -1; // wrong filename
        goto clean;
    }
    
    filename = malloc(fileInfo.size_filename);
    if (!filename) {
        res = -1; // out of memory
        goto clean;
    }
    
    res = unzGetCurrentFileInfo64(_unzFile, &fileInfo, filename, fileInfo.size_filename, NULL, 0, NULL, 0);
    if (res != UNZ_OK) {
        res = -1; // minizip failure
        goto clean;
    }
    
    path = [self filePathWithBytes:filename length:fileInfo.size_filename];
    if (!path) {
        res = -1; // wrong path
        goto clean;
    }
    
    const BOOL isDir = [path hasSuffix:@"/"];
    
    if (!isDir && fileInfo.uncompressed_size) {

        path = [destFolder stringByAppendingPathComponent:path];
        NSString *dirPath = path.stringByDeletingLastPathComponent;
        
        BOOL dirIsDir;
        if ([fileManager fileExistsAtPath:dirPath isDirectory:&dirIsDir]) {
            
            if (!dirIsDir) {
                res = -1; // file exist and it's not directory
                goto  clean;
            }
            
        } else {
            
            if (![fileManager createDirectoryAtPath:dirPath
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:nil])
            {
                res = -1; // unable create a directory
                goto  clean;
            }
        }
        
        if ([fileManager fileExistsAtPath:path]) {
            if (overwrite) {
                [fileManager removeItemAtPath:path error:nil];
            } else {
                res = -1; // a file exists, forbid overwrite
                goto  clean;
            }
        }
        
        if (![fileManager createFileAtPath:path contents:nil attributes:nil]) {
            res = -1; // unable create file path
            goto  clean;
        }
        
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:path];
        if (!file) {
            res = -1; // unable open file for writing
            goto  clean;
        }
        
        Byte buffer[1024*16] = {0};
        int read;
        
        do {
            
            read = unzReadCurrentFile(_unzFile, buffer, sizeof(buffer));
            if (read < 0) {
                
                res = -1;
                
            } else if (read > 0) {
                
                NSData *data = [NSData dataWithBytesNoCopy:buffer
                                                    length:read
                                              freeWhenDone:NO];
                
                @try {
                    
                    [file writeData:data];
                    
                } @catch (NSException *exp) {
                 
                    NSLog(@"catch: %@", exp);
                    res = -1;
                    read = 0;
                }
            }
            
        } while (read > 0);
        
        [file closeFile];
    }

clean:
    
    if (filename) {
        free(filename);
    }
    
    unzCloseCurrentFile(_unzFile);
    
    return UNZ_OK == res;
}

- (KxUnzipFile *) fileWithPath:(NSString *)path;
{
    for (KxUnzipFile *file in self.files) {
        if ([file.path isEqualToString:path]) {
            return file;
        }
    }
    return nil;
}

- (NSString *) stringWithBytes:(void *)bytes
                        length:(NSUInteger)legth

{
    NSString *result;
    result = [[NSString alloc] initWithBytes:bytes
                                      length:legth
                                    encoding:NSUTF8StringEncoding];
    if (result) {
        return result;
    }
    
    for (NSNumber *number in _fallbackEncodings) {
    
        const NSStringEncoding encoding = number.unsignedIntegerValue;
        result = [[NSString alloc] initWithBytes:bytes
                                          length:legth
                                        encoding:encoding];
        if (result) {
            return result;
        }
    }
    
    result = [[NSString alloc] initWithBytes:bytes
                                      length:legth
                                    encoding:[self.class cp437Encoding]];
    if (result) {
        return result;
    }
    
    NSStringEncoding possibleEncodings[] = {

        NSJapaneseEUCStringEncoding,
        NSShiftJISStringEncoding,
        NSUnicodeStringEncoding,
        
        [self.class dosRussianEncoding],
        [self.class koi8REncoding],
        
        NSWindowsCP1250StringEncoding,
        NSWindowsCP1251StringEncoding,
        NSWindowsCP1252StringEncoding,
        NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding,
        
        NSISOLatin1StringEncoding,
        NSASCIIStringEncoding,
    };
    
    for (NSUInteger i = 0; i < sizeof(possibleEncodings)/sizeof(possibleEncodings[0]); ++i) {
        
        const NSStringEncoding possibleEncoding = possibleEncodings[i];
        if (possibleEncoding) {
            
            NSString *s = [[NSString alloc] initWithBytes:bytes length:legth encoding:possibleEncoding];
            if (s) {
                return s;
            }
        }
    }
    
    return nil;
}

- (NSString *) filePathWithBytes:(void *)bytes
                          length:(NSUInteger)length
{
    NSString *path = [self stringWithBytes:bytes
                                    length:length];
    
    if ([path rangeOfString:@"\\"].location != NSNotFound) {
        path = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    }
    
    if ([path hasPrefix:@"/"] || [path hasPrefix:@".."]) {
        return nil; // wrong path
    }
    
    return path;
}

+ (NSStringEncoding) cp437Encoding
{
    return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS);
}

+ (NSStringEncoding) dosRussianEncoding
{
    return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian);
}

+ (NSStringEncoding) koi8REncoding
{
    return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingKOI8_R);
}

@end

//////////

@implementation KxUnzipFile

- (void) dealloc
{
    if (_origName) {
        free(_origName);
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<UnzipFile:%@ %luB>",
            _path, (unsigned long)_uncompressedSize];
}

@end