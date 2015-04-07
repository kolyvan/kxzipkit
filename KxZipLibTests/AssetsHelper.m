//
//  AssetsHelper.m
//  KxZipKit
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import "AssetsHelper.h"
#import "KxUnzipArchive.h"

@interface KxUnzipFile(AssetsHelper)
@property (readwrite, nonatomic, strong) NSString *path;
@property (readwrite, nonatomic) NSUInteger uncompressedSize;
@property (readwrite, nonatomic) NSUInteger crc32;
@property (readwrite, nonatomic) BOOL isCrypted;
@property (readwrite, nonatomic) BOOL isDirectory;
@end

@implementation KxUnzipFile(AssetsHelper)

@dynamic path, uncompressedSize, crc32, isCrypted, isDirectory;

- (BOOL) isEqual:(id)other
{
    if (self == other) {
        return YES;
    }
    
    if (!other) {
        return NO;
    }
    
    if (![other isKindOfClass:[KxUnzipFile class]]) {
        return NO;
    }
    
    return [self.path isEqualToString:((KxUnzipFile *)other).path] &&
    self.uncompressedSize == ((KxUnzipFile *)other).uncompressedSize &&
    self.crc32 == ((KxUnzipFile *)other).crc32 &&
    self.isCrypted == ((KxUnzipFile *)other).isCrypted &&
    self.isDirectory == ((KxUnzipFile *)other).isDirectory;
}

+ (KxUnzipFile *) zipFileWithPath:(NSString *)path
                 uncompressedSize:(NSUInteger)uncompressedSize
                            crc32:(NSUInteger)crc32
                        isCrypted:(BOOL)isCrypted
                      isDirectory:(BOOL)isDirectory
{
    KxUnzipFile *file = [KxUnzipFile new];
    file.path = path;
    file.uncompressedSize = uncompressedSize;
    file.crc32 = crc32;
    file.isCrypted = isCrypted;
    file.isDirectory = isDirectory;
    return file;
}


@end

@implementation AssetsHelper

+ (NSArray *) assetsTest1
{
    return @[ [KxUnzipFile zipFileWithPath:@"cover.png"
                          uncompressedSize:52106
                                     crc32:0x271dc681
                                 isCrypted:NO
                               isDirectory:NO] ];
}
+ (NSArray *) assetsTest1Prot
{
    return @[ [KxUnzipFile zipFileWithPath:@"cover.png"
                         uncompressedSize:52106
                                    crc32:0x271dc681
                                isCrypted:YES
                              isDirectory:NO] ];
}
+ (NSArray *) assetsTest1WinRu
{
    return @[ [KxUnzipFile zipFileWithPath:@"Обложка.png"
                         uncompressedSize:52106
                                    crc32:0x271dc681
                                isCrypted:NO
                              isDirectory:NO] ];

}
+ (NSArray *) assetsTest1WinRuProt
{
    return @[ [KxUnzipFile zipFileWithPath:@"Обложка.png"
                         uncompressedSize:52106
                                    crc32:0x271dc681
                                isCrypted:YES
                              isDirectory:NO] ];
}
+ (NSArray *) assetsTest2
{    
    return @[
             [KxUnzipFile zipFileWithPath:@"chapters/"
                        uncompressedSize:0
                                   crc32:0
                               isCrypted:NO
                             isDirectory:YES],
             
             [KxUnzipFile zipFileWithPath:@"chapters/bm01.html"
                        uncompressedSize:455
                                   crc32:0x9dd27b0b
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"chapters/bm02.html"
                        uncompressedSize:25823
                                   crc32:0xad7cedb1
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"chapters/bm03.html"
                        uncompressedSize:25266
                                   crc32:0x2873375e
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"chapters/bm04.html"
                        uncompressedSize:31448
                                   crc32:0x42e7e00b
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"cover.png"
                        uncompressedSize:52106
                                   crc32:0x271dc681
                               isCrypted:NO
                             isDirectory:NO]
             ];

}
+ (NSArray *) assetsTest2WinRu
{
    return @[
             [KxUnzipFile zipFileWithPath:@"Главы/"
                        uncompressedSize:0
                                   crc32:0
                               isCrypted:NO
                             isDirectory:YES],
             
             [KxUnzipFile zipFileWithPath:@"Главы/bm01.html"
                        uncompressedSize:455
                                   crc32:0x9dd27b0b
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"Главы/bm02.html"
                        uncompressedSize:25823
                                   crc32:0xad7cedb1
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"Главы/bm03.html"
                        uncompressedSize:25266
                                   crc32:0x2873375e
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"Главы/bm04.html"
                        uncompressedSize:31448
                                   crc32:0x42e7e00b
                               isCrypted:NO
                             isDirectory:NO],
             
             [KxUnzipFile zipFileWithPath:@"Обложка.png"
                        uncompressedSize:52106
                                   crc32:0x271dc681
                               isCrypted:NO
                             isDirectory:NO]
             ];
}

+ (NSData *) readDataForFilePath:(NSString *)path
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *resPath = [bundle.resourcePath stringByAppendingPathComponent:@"source"];
    resPath = [resPath stringByAppendingPathComponent:path];
    return [NSData dataWithContentsOfFile:resPath];    
}

+ (NSArray *) fallbackEncodingRu
{
    return @[ @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian)) ];
}

@end

