//
//  Unzip4ExtractTests.m
//  KxZipKit
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "KxUnzipArchive.h"
#import "AssetsHelper.h"

@interface Unzip4ExtractTests : XCTestCase

@end

@implementation Unzip4ExtractTests {
    
    NSString *_tmpPath;
}

- (void)setUp {
    [super setUp];
    
    _tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"unzip_tests"];
    [[NSFileManager defaultManager] removeItemAtPath:_tmpPath error:nil];
}

- (void)tearDown {

    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:_tmpPath error:nil];
}


- (void) helperTestFunc:(NSString *)name
               password:(NSString *)password
              encodings:(NSArray *)encodings
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:name ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:password];
    unzArchive.fallbackEncodings = encodings;
        
    [unzArchive extractToPath:_tmpPath];
    
    for (KxUnzipFile *file in unzArchive.files) {
        
        if (!file.isDirectory) {
            
            NSString *unzPath = [_tmpPath stringByAppendingPathComponent:file.path];
            NSData *unzData = [NSData dataWithContentsOfFile:unzPath];
            NSData *resData = [AssetsHelper readDataForFilePath:file.path];
            XCTAssertNotNil(unzData);
            XCTAssertNotNil(resData);
            XCTAssertEqualObjects(unzData, resData);
        }
    }
}

- (void)testRead1 {
    
    [self helperTestFunc:@"test1" password:nil encodings:nil];
}

- (void)testRead1WinRu {
    
    [self helperTestFunc:@"test1_winru" password:nil encodings:[AssetsHelper fallbackEncodingRu]];
}

- (void)testRead1Prot {
    
    [self helperTestFunc:@"test1_prot" password:@"12345" encodings:nil];
}

- (void)testRead1WinRuProt {
    
    [self helperTestFunc:@"test1_winru_prot" password:@"12345" encodings:[AssetsHelper fallbackEncodingRu]];
}

- (void)testRead2 {
    
    [self helperTestFunc:@"test2" password:nil encodings:nil];
}

- (void)testRead2WinRu {
    
    [self helperTestFunc:@"test2_winru" password:nil encodings:[AssetsHelper fallbackEncodingRu]];
}

@end
