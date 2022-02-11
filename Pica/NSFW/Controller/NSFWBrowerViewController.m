//
//  NSFWBrowerViewController.m
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "NSFWBrowerViewController.h"
#import "NSFWImageViewController.h"
#import "NSFWFile.h"

@interface NSFWBrowerViewController ()

@property (nonatomic, copy)   NSString *path;
@property (nonatomic, strong) NSMutableArray <NSFWFile *>*dataSource;

@end

@implementation NSFWBrowerViewController

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super initWithStyle:UITableViewStyleInsetGrouped]) {
        self.path = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.dataSource[indexPath.row].name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSFWFile *file = self.dataSource[indexPath.row];
    if (file.isDirectory) {
        NSFWBrowerViewController *brower = [[NSFWBrowerViewController alloc] initWithPath:file.path];
        brower.title = file.name;
        [self.navigationController pushViewController:brower animated:YES];
    } else {
        NSFWImageViewController *image = [[NSFWImageViewController alloc] initWithPath:file.path];
        [self.navigationController pushViewController:image animated:YES];
    }
}

#pragma mark - Set
- (void)setPath:(NSString *)path {
    _path = path;
    NSArray *fileArray = [kDefaultFileManager contentsOfDirectoryAtPath:path error:nil];
    if (fileArray.count) {
        [self.dataSource removeAllObjects];
        fileArray = [fileArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        for (NSString *filePath in fileArray) {
            NSFWFile *file = [[NSFWFile alloc] initWithPath:[path stringByAppendingPathComponent:filePath]];
            [self.dataSource addObject:file];
        }
    }
    [self.tableView reloadData];
}

- (NSMutableArray<NSFWFile *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
