//
//  Unzip2EntriesTests.m
//  KxZipKit
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "KxUnzipArchive.h"
#import "AssetsHelper.h"

@interface Unzip2FilesTests : XCTestCase

@end

@implementation Unzip2FilesTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFiles1 {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test1" ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:nil];
    
    NSArray *files = unzArchive.files;
    
    XCTAssertNotNil(files, @"Pass");
    XCTAssertTrue(files.count == 1, @"Pass");
    XCTAssertEqualObjects(files, [AssetsHelper assetsTest1]);
}

- (void)testFiles2 {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test2" ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:nil];
    
    NSArray *files = unzArchive.files;
    
    XCTAssertNotNil(files, @"Pass");
    XCTAssertTrue(files.count == 6, @"Pass");
    XCTAssertEqualObjects(files, [AssetsHelper assetsTest2]);
}

- (void)testFiles1WinRu {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test1_winru" ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:nil];
    unzArchive.fallbackEncodings = @[ @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian)) ];
    
    NSArray *files = unzArchive.files;
    
    XCTAssertNotNil(files, @"Pass");
    XCTAssertTrue(files.count == 1, @"Pass");
    XCTAssertEqualObjects(files, [AssetsHelper assetsTest1WinRu]);

}

- (void)testFiles2WinRu {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test2_winru" ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:nil];
    unzArchive.fallbackEncodings = @[ @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian)) ];
    
    NSArray *files = unzArchive.files;
    
    XCTAssertNotNil(files, @"Pass");
    XCTAssertTrue(files.count == 6, @"Pass");
    XCTAssertEqualObjects(files, [AssetsHelper assetsTest2WinRu]);
}

- (void)testFiles1Protected {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test1_prot" ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:nil];
    
    NSArray *files = unzArchive.files;
    
    XCTAssertNotNil(files, @"Pass");
    XCTAssertTrue(files.count == 1, @"Pass");
    XCTAssertEqualObjects(files, [AssetsHelper assetsTest1Prot]);
}

- (void)testFiles1WinRuProtected {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test1_winru_prot" ofType:@"zip"];
    KxUnzipArchive *unzArchive = [[KxUnzipArchive alloc] initWithPath:zipPath password:nil];
    unzArchive.fallbackEncodings = @[ @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSRussian)) ];
    
    NSArray *files = unzArchive.files;
    
    XCTAssertNotNil(files, @"Pass");
    XCTAssertTrue(files.count == 1, @"Pass");
    XCTAssertEqualObjects(files, [AssetsHelper assetsTest1WinRuProt]);
    
}

@end
