//
//  UnzipProbeTest.m
//  KxZipKit
//
//  Created by Kolyvan on 29.07.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "KxUnzipArchive.h"

@interface UnzipProbeTest : XCTestCase

@end

@implementation UnzipProbeTest


- (void)testProbeOk {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test1" ofType:@"zip"];
    XCTAssertTrue([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
    zipPath = [bundle pathForResource:@"test1_winru" ofType:@"zip"];
    XCTAssertTrue([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
    zipPath = [bundle pathForResource:@"test1_prot" ofType:@"zip"];
    XCTAssertTrue([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
    zipPath = [bundle pathForResource:@"test1_winru_prot" ofType:@"zip"];
    XCTAssertTrue([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
    zipPath = [bundle pathForResource:@"test2" ofType:@"zip"];
    XCTAssertTrue([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
    zipPath = [bundle pathForResource:@"test2_winru" ofType:@"zip"];
    XCTAssertTrue([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
}

- (void)testProbeFail {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *zipPath = [bundle pathForResource:@"test_unk" ofType:@"zip"];
    XCTAssertFalse([KxUnzipArchive probeFileAtPath:zipPath], @"Pass");
    
    NSString *resPath = [bundle.resourcePath stringByAppendingPathComponent:@"source/cover.png"];    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:resPath], @"Pass");
    XCTAssertFalse([KxUnzipArchive probeFileAtPath:resPath], @"Pass");
}

@end
