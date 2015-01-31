//
//  ViewController.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ViewController.h"
#import "MainTableViewCell.h"
#import "ListContentInteractor.h"
#import "DraftContentInteractor.h"
#import <BCGenieEffect/UIView+Genie.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <DropboxSDK/DropboxSDK.h>

static NSInteger const gradientLength = 100;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) id<InodeRepresentationProtocol> inodeRepresentation;
@property (nonatomic, strong) ListContentInteractor *listContentInteractor;
@property (nonatomic, strong) DraftContentInteractor *draftContentInteractor;
@property (nonatomic, assign) NSUInteger maximumNodeSize;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@property (nonatomic, assign) BOOL allSelected;
@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupTabbarItem];
    }
    return self;
}

- (instancetype)initWithInodeRepresentation:(id<InodeRepresentationProtocol>)inode {
    self = [super init];
    if (self) {
        [self setupTabbarItem];
        _inodeRepresentation = inode;
        self.maximumNodeSize = [self maximumNodeSizeForNodeRepresentation:inode];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[DBSession sharedSession] isLinked]) {
        [self getInodeRepresentation];
    }
    [self setupTableView];
    [self setupNavigationBar];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mainTableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    if (self.bottomToolbar) {
        [self dismissToolbarAnimated:YES];
    }
}
- (void)getInodeRepresentation {
    if (!self.inodeRepresentation) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading kittens...";
        [self.listContentInteractor listDropboxTreeWithCompletion:^(id<InodeRepresentationProtocol> inode) {
            self.inodeRepresentation = inode;
            self.maximumNodeSize = [self maximumNodeSizeForNodeRepresentation:inode];
            [self setupNavigationBar];
            [self.mainTableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } progress:^(NSUInteger processedItems, NSUInteger total, MDLoadProgressState progressState) {
            if (progressState == MDLoadProgressStateRequest) {
                hud.detailsLabelText = [NSString stringWithFormat:@"Received %lu nodes",(unsigned long)total];
            }else if (progressState == MDLoadProgressStateProccess){
                hud.detailsLabelText = [NSString stringWithFormat:@"Processing node %lu/%lu",(unsigned long)processedItems,(unsigned long)total];
            }
        }];
    }
}
- (void)setupNavigationBar {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editPressed:)];
    self.navigationItem.rightBarButtonItem = editButton;
    self.title = [self.inodeRepresentation inodeName];
    if ([self.title isEqualToString:@"/"]) {
        self.title = @"Dropbox";
    }
}
- (void)setupTabbarItem {
    self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Dropbox"
                                                   image:[[UIImage imageNamed:@"dropbox_tabbar_deselected"]
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                           selectedImage:[[UIImage imageNamed:@"dropbox_tabbar_selected"]
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
- (void)setupTableView {
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.allowsMultipleSelectionDuringEditing = YES;
    
    
    self.mainTableView.separatorColor = [UIColor clearColor];
    [self.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil]
             forCellReuseIdentifier:NSStringFromClass([MainTableViewCell class])];
}

#pragma mark -  TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cells = [[self.inodeRepresentation inodeUndraftedChilds] count];
    self.navigationItem.rightBarButtonItem.enabled = cells ? YES : NO;
    return cells;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MainTableViewCell class])
                                                              forIndexPath:indexPath];
    id<InodeRepresentationProtocol> inode = [self.inodeRepresentation inodeUndraftedChilds][indexPath.row];
    cell.nameLabel.text = [inode inodeName];
    cell.sizeLabel.text = [inode inodeHumanReadableSize];
    cell.percentageColor = [UIColor colorWithRed:0.09 green:0.49 blue:0.98 alpha:1.0];
    if (self.maximumNodeSize > 0) {
        CGFloat size = (CGFloat)[inode inodeSize]/self.maximumNodeSize;
        cell.sizePercentage = size;
    } else {
        cell.sizePercentage = 0;
    }
    cell.folderCell = [inode inodeType];
    return cell;
}


#pragma mark -  TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        id<InodeRepresentationProtocol> selectedNode = (id<InodeRepresentationProtocol>)([self.inodeRepresentation inodeUndraftedChilds][indexPath.row]);
        if ([selectedNode inodeType] == InodeTypeFolder) {
            ViewController *nextVC = [[ViewController alloc]initWithInodeRepresentation:selectedNode];
            nextVC.draftedInodes = self.draftedInodes;
            [self.navigationController pushViewController:nextVC animated:YES];
            MainTableViewCell *cell = (MainTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = (MainTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.percentageColor = [UIColor redColor];
    [cell animateTitleToDeleteState];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id<InodeRepresentationProtocol> selectedNode = (id<InodeRepresentationProtocol>)([self.inodeRepresentation inodeUndraftedChilds][indexPath.row]);
        [self.draftContentInteractor addInode:selectedNode completion:nil];
        
        MainTableViewCell *cell = (MainTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell resetTitleToNormalStateAnimated:NO];
        
        [cell genieInTransitionWithDuration:1.0
                            destinationRect:[self destinationGennieRect]
                            destinationEdge:BCRectEdgeTop
                                 completion:^{
                                     [tableView deleteRowsAtIndexPaths:@[indexPath]
                                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                                 }];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = (MainTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.percentageColor =  [UIColor colorWithRed:0.09 green:0.49 blue:0.98 alpha:1.0];
    [cell resetTitleToNormalStateAnimated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"To Minniebox";
}



#pragma mark -  helpers

- (NSUInteger)maximumNodeSizeForNodeRepresentation:(id<InodeRepresentationProtocol>)inode {
    NSArray *array = [[NSArray alloc]initWithArray:[inode inodeUndraftedChilds]];
    NSUInteger maximum = 0;
    for (id<InodeRepresentationProtocol>childNode in array) {
        if ([childNode inodeSize] > maximum) {
            maximum = [childNode inodeSize];
        }
    }
    return maximum;
}

- (CGRect)destinationGennieRect {
    return CGRectMake(CGRectGetWidth(self.view.frame) * 0.6,
                      self.tabBarController.tabBar.frame.origin.y,
                      CGRectGetWidth(self.view.frame) * 0.3,
                      CGRectGetHeight(self.tabBarController.tabBar.frame));
}

#pragma mark -  Navbar actions
- (void)editPressed:(UIBarButtonItem *)sender {
    if ([self.mainTableView isEditing]) {
        [self dismissToolbarAnimated:YES];
        [self.mainTableView setEditing:NO animated:YES];
        [sender setTitle:@"Edit"];
    }
    else {
        [self presentToolbarAnimated:YES];
        [sender setTitle:@"Done"];
        [self.mainTableView setEditing:YES animated:YES];
        self.allSelected = NO;
    }
}

#pragma mark -  bottomToolbar
- (void)presentToolbarAnimated:(BOOL)animated {
    CGFloat height = 50;
    
    if (!self.bottomToolbar) {
        CGRect toolbarFrame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), height);
        self.bottomToolbar = [[UIToolbar alloc]initWithFrame:toolbarFrame];
        self.bottomToolbar.translucent = NO;
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"Mark all"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(markAllButtonPressed:)];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"Send to MinnieBox"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(sendToMinnieBoxButtonPressed:)];
        rightItem.tintColor = [UIColor redColor];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.bottomToolbar.items = @[leftItem, flexibleItem,rightItem];
    }
    [self.tabBarController.view addSubview:self.bottomToolbar];
    
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
             usingSpringWithDamping:0.9
              initialSpringVelocity:3.0
                            options:0
                         animations:^{
                             self.bottomToolbar.center = CGPointMake(self.bottomToolbar.center.x,
                                                                     self.bottomToolbar.center.y - height);
                         } completion:nil];
    } else {
        self.bottomToolbar.center = CGPointMake(self.bottomToolbar.center.x,
                                                self.bottomToolbar.center.y - height);
    }
    
}
- (void)dismissToolbarAnimated:(BOOL)animated {
    CGFloat height = CGRectGetHeight(self.bottomToolbar.frame);

    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
             usingSpringWithDamping:0.9
              initialSpringVelocity:3.0
                            options:0
                         animations:^{
                             self.bottomToolbar.center = CGPointMake(self.bottomToolbar.center.x,
                                                                     self.bottomToolbar.center.y + height);
                         } completion:^(BOOL finished) {
                             [self.bottomToolbar removeFromSuperview];
                         }];
    } else {
        [self.bottomToolbar removeFromSuperview];
    }
}

- (void)markAllButtonPressed:(UIBarButtonItem *)sender {
    if (self.allSelected) {
        [sender setTitle:@"Mark all"];
        self.allSelected = NO;
        for (NSInteger i = 0; i < [self.mainTableView numberOfRowsInSection:0]; i++) {
            [self.mainTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                            animated:NO];
        }
        
    } else {
        [sender setTitle:@"Unmark all"];
        self.allSelected = YES;
        for (NSInteger i = 0; i < [self.mainTableView numberOfRowsInSection:0]; i++) {
            [self.mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
        }
    }

}
- (void)sendToMinnieBoxButtonPressed:(UIBarButtonItem *)sender {
    NSArray *indexPaths = [self.mainTableView indexPathsForSelectedRows];
    __weak typeof(self) weakSelf = self;
    for (NSIndexPath *indexPath in indexPaths) {
        id<InodeRepresentationProtocol> selectedNode = (id<InodeRepresentationProtocol>)([self.inodeRepresentation inodeUndraftedChilds][indexPath.row]);
        [self.draftContentInteractor addInode:selectedNode completion:^{
            [weakSelf.mainTableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
}

#pragma mark -  getters
- (ListContentInteractor *)listContentInteractor{
    if (!_listContentInteractor) {
        _listContentInteractor = [[ListContentInteractor alloc] init];
        _listContentInteractor.draftedInodes = self.draftedInodes;
    }
    return _listContentInteractor;
}
- (DraftContentInteractor *)draftContentInteractor{
    if (!_draftContentInteractor) {
        _draftContentInteractor = [[DraftContentInteractor alloc] initWithDraftedInodes:self.draftedInodes];
    }
    return _draftContentInteractor;
}

@end
