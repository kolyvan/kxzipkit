//
//  ViewController.m
//  Demo
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id) init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void) loadView
{
    const CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = ({
        UIView *v = [[UIView alloc] initWithFrame:frame];
        v.backgroundColor = [UIColor whiteColor];
        v.opaque = YES;
        v;
    });
}

@end
