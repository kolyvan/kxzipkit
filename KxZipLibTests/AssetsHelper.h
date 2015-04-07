//
//  AssetsHelper.h
//  KxZipKit
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AssetsHelper : NSObject

+ (NSArray *) assetsTest1;
+ (NSArray *) assetsTest1Prot;
+ (NSArray *) assetsTest1WinRu;
+ (NSArray *) assetsTest1WinRuProt;
+ (NSArray *) assetsTest2;
+ (NSArray *) assetsTest2WinRu;

+ (NSData *) readDataForFilePath:(NSString *)path;

+ (NSArray *) fallbackEncodingRu;

@end
