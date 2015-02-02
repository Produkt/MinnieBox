//
//  MinnieBoxViewController.m
//  MinnieBox
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MinnieBoxViewController.h"
#import "MinnieBoxTableViewCell.h"
#import "InodeRepresentationProtocol.h"
#import "DraftContentInteractor.h"
#import "DeleteContentInteractor.h"
#import "MinieBoxDeleteTableViewCell.h"
#import "MinnieBoxCountdownTableViewCell.h"
#import "MinnieBoxDisclaimerTableViewCell.h"


@interface MinnieBoxViewController ()<UITableViewDataSource,UITableViewDelegate, CountdownCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic,readwrite) NSSet *draftedInodes;
@property (strong,nonatomic,readwrite) NSMutableArray *draftedInodesCache;
@property (strong,nonatomic) DeleteContentInteractor *deleteContentInteractor;
@property (strong,nonatomic) DraftContentInteractor *draftContentInteractor;
@property (assign,nonatomic) BOOL isWaitingConfirmation;

@property (assign,nonatomic) NSUInteger confirmationIterations;
@property (weak, nonatomic) IBOutlet UILabel *noContentLabel;
@property (weak, nonatomic) UILabel *subTitleLabel;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inodeWasUndrafted:) name:DraftInodesRemoveInodeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inodeWillBeUndrafted:) name:DraftInodesWillRemoveInodeNotification object:nil];
    }
    return self;
}
- (instancetype)init
{
    return [self initWithDraftedInodes:nil];
}
- (void)inodeWasDrafted:(NSNotification *)notification{
    [self updateCache];
    [self updateBadge];
    [self updateSubtitle];
}
- (void)inodeWasUndrafted:(NSNotification *)notification{
    [self updateCache];
    [self updateBadge];
    [self updateSubtitle];
}
- (void)updateCache{
    self.draftedInodesCache = [[self.draftedInodes allObjects] mutableCopy];
    [self.tableView reloadData];
}
- (void)inodeWillBeUndrafted:(NSNotification *)notification{
//    NSUInteger index = [self.draftedInodesCache indexOfObject:notification.object];
//    [self.draftedInodesCache removeObject:notification.object];
//    NSMutableArray *indexPathsToDelete = [NSMutableArray array];
//    [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:index inSection:0]];
//    if (!self.draftedInodesCache.count) {
//        [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:0 inSection:1]];
//    }
//    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)updateSubtitle{
    NSString *draftedBytesLenght = [NSByteCountFormatter stringFromByteCount:[self draftedBytes]
                                                           countStyle:NSByteCountFormatterCountStyleMemory];
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@ ready to be deleted",draftedBytesLenght];
    [self.subTitleLabel sizeToFit];
}
- (void)updateBadge {
    NSUInteger draftedBytes = [self draftedBytes];
    NSString *badgeString = @"";
    if (draftedBytes > 0) {
        badgeString = [NSByteCountFormatter stringFromByteCount:draftedBytes
                                                               countStyle:NSByteCountFormatterCountStyleMemory];

    }
    UITabBarItem *item = [self.tabBarController.tabBar.items lastObject];
    item.badgeValue = badgeString;
}

- (NSUInteger)draftedBytes{
    __block NSUInteger totalBytes = 0;
    [self.draftedInodes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        totalBytes += [(id<InodeRepresentationProtocol>)obj inodeSize];
        
    }];
    return totalBytes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self setupNavigationTitle];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateSubtitle];
}
- (void)configureTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MinnieBoxTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MinnieBoxTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MinieBoxDeleteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MinieBoxDeleteTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MinnieBoxCountdownTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MinnieBoxCountdownTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MinnieBoxDisclaimerTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([MinnieBoxDisclaimerTableViewCell class])];
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
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.text = @"Minniebox";
    [titleLabel sizeToFit];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 19, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = [UIColor grayColor];
    subTitleLabel.font = [UIFont systemFontOfSize:11];
    subTitleLabel.text = @"78 MB ready to be deleted";
    [subTitleLabel sizeToFit];
    self.subTitleLabel = subTitleLabel;
    
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
    return [self.draftedInodesCache count]?3:0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.noContentLabel.hidden = ([self.draftedInodesCache count] || self.isWaitingConfirmation)?YES:NO;
    if (section == 0) {
        return [self.draftedInodesCache count];
    }else if (section == 1){
        return ([self.draftedInodesCache count] && !self.isWaitingConfirmation)?2:0;
    }else if (section == 2){
        return ([self.draftedInodesCache count] && self.isWaitingConfirmation)?2:0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 ) {
        MinnieBoxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MinnieBoxTableViewCell class]) forIndexPath:indexPath];
        id<InodeRepresentationProtocol> inode = [self.draftedInodesCache objectAtIndex:indexPath.item];
        cell.inodeNameLabel.text = [inode inodeName];
        cell.inodeSizeLabel.text = [inode inodeHumanReadableSize];
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.item == 0) {
            MinieBoxDeleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MinieBoxDeleteTableViewCell class]) forIndexPath:indexPath];
            cell.deleteButtonLabel.text = @"Delete All";
            return cell;
        }else{
            MinnieBoxDisclaimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MinnieBoxDisclaimerTableViewCell class]) forIndexPath:indexPath];
            return cell;
        }
        
    }else if (indexPath.section == 2){
        if (indexPath.item == 0) {
            MinnieBoxCountdownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MinnieBoxCountdownTableViewCell class]) forIndexPath:indexPath];
            return cell;
        }else{
            MinieBoxDeleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MinieBoxDeleteTableViewCell class]) forIndexPath:indexPath];
            cell.deleteButtonLabel.text = @"Stop!";
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.item == 0) {
        self.isWaitingConfirmation = YES;
        [self.tableView reloadData];
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
        [self.tableView scrollToRowAtIndexPath:cellIndexPath
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
        MinnieBoxCountdownTableViewCell *cell = (MinnieBoxCountdownTableViewCell *)[tableView cellForRowAtIndexPath:cellIndexPath];
        cell.delegate = self;
        [cell startCountDown];
        self.tableView.scrollEnabled = NO;
    }else if (indexPath.section == 2 && indexPath.item == 1){
        self.isWaitingConfirmation = NO;
        MinnieBoxCountdownTableViewCell *cell = (MinnieBoxCountdownTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];
        [cell stopCountDown];

        self.tableView.scrollEnabled = YES;
        [self.tableView reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }else if (indexPath.section == 1){
        if (indexPath.item == 0) {
            return 44;
        }else if (indexPath.item == 1){
            return 70;
        }
    }else if (indexPath.section == 2){
        if (indexPath.item == 0) {
            return 150;
        }else if (indexPath.item == 1){
            return 44;
        }
    }
    return 0;
}


#pragma mark -  CountDownCellDelegate
- (void)countDownFinished {
    self.isWaitingConfirmation = NO;
    [self deleteAllItems];
}

- (void)deleteAllItems{
    [self.deleteContentInteractor deleteInodes:self.draftedInodesCache withCompletion:^{
        self.tableView.scrollEnabled = YES;
        self.noContentLabel.hidden = ([self.draftedInodesCache count] || self.isWaitingConfirmation)?YES:NO;
    }];
}

- (DeleteContentInteractor *)deleteContentInteractor{
    if (!_deleteContentInteractor) {
        _deleteContentInteractor = [[DeleteContentInteractor alloc] init];
        _deleteContentInteractor.draftContentInteractor = self.draftContentInteractor;
    }
    return _deleteContentInteractor;
}
- (DraftContentInteractor *)draftContentInteractor{
    if (!_draftContentInteractor) {
        _draftContentInteractor = [[DraftContentInteractor alloc] initWithDraftedInodes:(NSMutableSet *)self.draftedInodes];
    }
    return _draftContentInteractor;
}

@end
