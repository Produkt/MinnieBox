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
#import "GradientColorGenerator.h"

static NSInteger const gradientLength = 100;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) id<InodeRepresentationProtocol> inodeRepresentation;
@property (nonatomic, strong) ListContentInteractor *listContentInteractor;
@property (nonatomic, strong) DraftContentInteractor *draftContentInteractor;
@property (nonatomic, strong) GradientColorGenerator *colorGenerator;
@property (nonatomic, assign) NSUInteger maximumNodeSize;
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
        _inodeRepresentation = inode;
        self.maximumNodeSize = [self maximumNodeSizeForNodeRepresentation:inode];
        [self setupTabbarItem];

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_inodeRepresentation) {
        [self.listContentInteractor listRootContentWithCompletion:^(id<InodeRepresentationProtocol> inode) {
            _inodeRepresentation = inode;
            self.maximumNodeSize = [self maximumNodeSizeForNodeRepresentation:inode];
            [self.mainTableView reloadData];
        }];
    }
    [self setupTableView];


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
    self.mainTableView.separatorColor = [UIColor clearColor];
    [self.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil]
             forCellReuseIdentifier:NSStringFromClass([MainTableViewCell class])];
}

#pragma mark -  TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cells = [[((id<InodeRepresentationProtocol>)self.inodeRepresentation) inodeChilds] count];
    return cells;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MainTableViewCell class])
                                                              forIndexPath:indexPath];
    id<InodeRepresentationProtocol> inode = [self.inodeRepresentation inodeChilds][indexPath.row];
    
    cell.nameLabel.text = [inode inodeName];
    cell.sizeLabel.text = [inode inodeHumanReadableSize];
    NSInteger nCells = [[((id<InodeRepresentationProtocol>)self.inodeRepresentation) inodeChilds] count];
    cell.percentageColor = [self.colorGenerator colorAtPosition:indexPath.row * gradientLength * 2/nCells];
    
    CGFloat size = (CGFloat)[inode inodeSize]/self.maximumNodeSize;
    cell.sizePercentage = size;
    return cell;
}


#pragma mark -  TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id<InodeRepresentationProtocol> inode = [self.inodeRepresentation inodeChilds][indexPath.row];
    [self.draftContentInteractor addInode:inode];
}



#pragma mark -  helpers

- (NSUInteger)maximumNodeSizeForNodeRepresentation:(id<InodeRepresentationProtocol>)inode {
    NSArray *array = [[NSArray alloc]initWithArray:[inode inodeChilds]];
    NSUInteger maximum = 0;
    for (id<InodeRepresentationProtocol>childNode in array) {
        if ([childNode inodeSize] > maximum) {
            maximum = [childNode inodeSize];
        }
    }
    return maximum;
}

#pragma mark -  getters
- (GradientColorGenerator *)colorGenerator {
    if (!_colorGenerator) {
        _colorGenerator = [[GradientColorGenerator alloc]initWithColors:@[[UIColor colorWithRed:0.00 green:0.47 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.55 green:0.76 blue:1.00 alpha:1.0]]
                                                                     length:gradientLength];
    }
    return _colorGenerator;
}

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
