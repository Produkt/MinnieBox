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
#import "GradientColorGenerator.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) id<InodeRepresentationProtocol> inodeRepresentation;
@property (nonatomic, strong) ListContentInteractor *listContentInteractor;
@property (nonatomic, strong) GradientColorGenerator *colorGenerator;
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
	[self.listContentInteractor listRootContentWithCompletion:^(NSArray *inodes) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)setupTableView {
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.mainTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil]
             forCellReuseIdentifier:NSStringFromClass([MainTableViewCell class])];
}

#pragma mark -  TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cells = [((id<InodeRepresentationProtocol>)self.inodeRepresentation).childRepresentation count];
    return cells;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MainTableViewCell class])
                                                              forIndexPath:indexPath];
    id<InodeRepresentationProtocol> inode = self.inodeRepresentation.childRepresentation[indexPath.row];
    
    cell.nameLabel.text = inode.name;
    cell.sizeLabel.text = inode.humanReadableSize;
    NSInteger nCells = [((id<InodeRepresentationProtocol>)self.inodeRepresentation).childRepresentation count];
    cell.backgroundColor = [self.colorGenerator colorAtPosition:indexPath.row * 200/nCells];
    return cell;
}


#pragma mark -  TableViewDelegate




#pragma mark -  mockup
- (TempRepresentation *)createMockRepresentation {
    TempRepresentation *rep1 = [[TempRepresentation alloc]init];
    rep1.name = @"Pictures";
    rep1.size = 15000;
    rep1.humanReadableSize = @"15 GB";
    rep1.type = InodeTypeFolder;
    rep1.childRepresentation = nil;
    
    TempRepresentation *rep2 = [[TempRepresentation alloc]init];
    rep2.name = @"Music";
    rep2.size = 10000;
    rep2.humanReadableSize = @"10 GB";
    rep2.type = InodeTypeFolder;
    rep2.childRepresentation = nil;
    
    TempRepresentation *rep3 = [[TempRepresentation alloc]init];
    rep3.name = @"Apps";
    rep3.size = 1500;
    rep3.humanReadableSize = @"1500 MB";
    rep3.type = InodeTypeFolder;
    rep3.childRepresentation = nil;
    
    TempRepresentation *rep4 = [[TempRepresentation alloc]init];
    rep4.name = @"Apps2";
    rep4.size = 400;
    rep4.humanReadableSize = @"400 MB";
    rep4.type = InodeTypeFolder;
    rep4.childRepresentation = nil;
    
    TempRepresentation *rep5 = [[TempRepresentation alloc]init];
    rep5.name = @"silly.pdf";
    rep5.size = 400;
    rep5.humanReadableSize = @"400 MB";
    rep5.type = InodeTypeFile;
    rep5.childRepresentation = nil;
    
    
    TempRepresentation *temp = [[TempRepresentation alloc]init];
    temp.name = @"Dropbox";
    temp.size = 25000;
    temp.humanReadableSize = @"25 GB";
    temp.type = InodeTypeFolder;
    temp.childRepresentation = @[rep1,rep2,rep3,rep4,rep5, rep5, rep5, rep5];
    
    self.colorGenerator = [[GradientColorGenerator alloc]initWithColors:@[[UIColor colorWithRed:0.00 green:0.47 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.55 green:0.76 blue:1.00 alpha:1.0]]
                                                                 length:100];
    return temp;
}


- (ListContentInteractor *)listContentInteractor{
    if (!_listContentInteractor) {
        _listContentInteractor = [[ListContentInteractor alloc] init];
    }
    return _listContentInteractor;
}

@end
