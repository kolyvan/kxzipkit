//
//  ViewController.m
//  Demo
//
//  Created by Kolyvan on 06.04.15.
//  Copyright (c) 2015 Kolyvan. All rights reserved.
//

#import "ViewController.h"
#import "KxUnzipArchive.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (readonly, nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController {
    NSArray *_items;
}

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
    
    _tableView = ({
        
        UITableView *v = [[UITableView alloc] initWithFrame:self.view.bounds
                                                      style:UITableViewStyleGrouped];
        
        v.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        v.backgroundColor = [UIColor whiteColor];
        v.delegate = self;
        v.dataSource = self;
        v;
    });
    
    [self.view addSubview:_tableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_items && _path) {
    
        if (![_path.pathExtension compare:@"zip" options:NSCaseInsensitiveSearch]) {
            
            KxUnzipArchive *unzArchive = [KxUnzipArchive unzipWithPath:_path];
            _items = unzArchive.files;
            
        } else {
            
            NSFileManager *fm = [NSFileManager defaultManager];
            _items = [fm contentsOfDirectoryAtPath:_path error:nil];
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }
    
    id item = _items[indexPath.row];
    if ([item isKindOfClass:[KxUnzipFile class]]) {
        
        KxUnzipFile *file = item;
        cell.textLabel.text = file.path;
        
    } else {
        cell.textLabel.text = [item description];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id item = _items[indexPath.row];
    if ([item isKindOfClass:[KxUnzipFile class]]) {
        
        // nothing
        
    } else if ([item isKindOfClass:[NSString class]]) {
        
        ViewController *vc = [ViewController new];
        vc.path = [_path stringByAppendingPathComponent:item];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
