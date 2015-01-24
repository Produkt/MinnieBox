//
//  ViewController.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ViewController.h"
#import "TempRepresentation.h"
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

    }
    return self;
}

- (instancetype)initWithInodeRepresentation:(id<InodeRepresentationProtocol>)inode {
    self = [super init];
    if (self) {
        _inodeRepresentation = inode;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.inodeRepresentation) {
        self.inodeRepresentation = [self createMockRepresentation];
    }
    [self setupTableView];
	[self.listContentInteractor listRootContentWithCompletion:^(id<InodeRepresentationProtocol> inode) {
        
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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




#pragma mark -  mockup
- (TempRepresentation *)createMockRepresentation {
    TempRepresentation *rep1 = [[TempRepresentation alloc]init];
    rep1.inodeName = @"Pictures";
    rep1.inodeSize = 15000;
    rep1.inodeType = InodeTypeFolder;
    rep1.inodeChilds = nil;
    
    TempRepresentation *rep2 = [[TempRepresentation alloc]init];
    rep2.inodeName = @"Music";
    rep2.inodeSize = 10000;
    rep2.inodeType = InodeTypeFolder;
    rep2.inodeChilds = nil;
    
    TempRepresentation *rep3 = [[TempRepresentation alloc]init];
    rep3.inodeName = @"Apps";
    rep3.inodeSize = 1500;
    rep3.inodeType = InodeTypeFolder;
    rep3.inodeChilds = nil;
    
    TempRepresentation *rep4 = [[TempRepresentation alloc]init];
    rep4.inodeName = @"Apps2";
    rep4.inodeSize = 400;
    rep4.inodeType = InodeTypeFolder;
    rep4.inodeChilds = nil;
    
    TempRepresentation *rep5 = [[TempRepresentation alloc]init];
    rep5.inodeName = @"silly.pdf";
    rep5.inodeSize = 400;
    rep5.inodeType = InodeTypeFile;
    rep5.inodeChilds = nil;
    
    
    TempRepresentation *temp = [[TempRepresentation alloc]init];
    temp.inodeName = @"Dropbox";
    temp.inodeSize = 25000;
    temp.inodeType = InodeTypeFolder;
    temp.inodeChilds = @[rep1,rep2,rep3,rep4,rep5];
    
    self.colorGenerator = [[GradientColorGenerator alloc]initWithColors:@[[UIColor colorWithRed:0.00 green:0.47 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.55 green:0.76 blue:1.00 alpha:1.0]]
                                                                 length:gradientLength];

    self.maximumNodeSize = [self maximumNodeSizeForNodeRepresentation:temp];
    return temp;
}

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
