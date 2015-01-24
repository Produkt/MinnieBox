//
//  MinnieBoxViewController.m
//  MinnieDisk
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MinnieBoxViewController.h"
#import "MinnieBoxTableViewCell.h"
#import "InodeRepresentationProtocol.h"
#import "DraftContentInteractor.h"

@interface MinnieBoxViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic,readwrite) NSSet *draftedInodes;
@end

@implementation MinnieBoxViewController

- (instancetype)initWithDraftedInodes:(NSSet *)draftedInodes
{
    NSParameterAssert(draftedInodes);
    self = [super init];
    if (self) {
        _draftedInodes = draftedInodes;
        [self setupTabbarItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inodeWasDrafted:) name:DraftInodesAddInodeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inodeWasUndrafted:) name:DraftInodesAddInodeNotification object:nil];
    }
    return self;
}
- (instancetype)init
{
    return [self initWithDraftedInodes:nil];
}
- (void)inodeWasDrafted:(NSNotification *)notification{
    [self.tableView reloadData];
}
- (void)inodeWasUndrafted:(NSNotification *)notification{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self setupNavigationTitle];
}

- (void)configureTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MinnieBoxTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MinnieBoxTableViewCell class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTabbarItem {
    self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"MinnieBox"
                                                   image:[[UIImage imageNamed:@"minnieBox_tabbar_deselected"]
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                           selectedImage:[[UIImage imageNamed:@"minnieBox_tabbar_selected"]
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
- (void)setupNavigationTitle{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"Minniebox";
    [titleLabel sizeToFit];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = [UIColor grayColor];
    subTitleLabel.font = [UIFont systemFontOfSize:10];
    subTitleLabel.text = @"78 MB ready to be deleted";
    [subTitleLabel sizeToFit];
    
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30)];
    [twoLineTitleView addSubview:titleLabel];
    [twoLineTitleView addSubview:subTitleLabel];
    
    float widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width;
    
    if (widthDiff > 0) {
        CGRect frame = titleLabel.frame;
        frame.origin.x = widthDiff / 2;
        titleLabel.frame = CGRectIntegral(frame);
    }else{
        CGRect frame = subTitleLabel.frame;
        frame.origin.x = abs(widthDiff) / 2;
        subTitleLabel.frame = CGRectIntegral(frame);
    }
    
    self.navigationItem.titleView = twoLineTitleView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.draftedInodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MinnieBoxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MinnieBoxTableViewCell class]) forIndexPath:indexPath];
    id<InodeRepresentationProtocol> inode = [[self.draftedInodes allObjects] objectAtIndex:indexPath.item];
    cell.inodeNameLabel.text = [inode inodeName];
    cell.inodeSizeLabel.text = [inode inodeHumanReadableSize];
    return cell;
}

#pragma mark - UITableViewDelegate


@end
