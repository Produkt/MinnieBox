//
//  ViewController.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ViewController.h"
#import "TempRepresentation.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) id<InodeRepresentationProtocol> inodeRepresentation;
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
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}





#pragma mark -  mockup
- (NSArray *)createMockArray {
    TempRepresentation *rep1 = [[TempRepresentation alloc]init];
    rep1.name = @"Pictures";
    rep1.size = 15000;
    rep1.type = InodeTypeFolder;
    rep1.childRepresentation = nil;
    
    TempRepresentation *rep2 = [[TempRepresentation alloc]init];
    rep2.name = @"Music";
    rep2.size = 10000;
    rep2.type = InodeTypeFolder;
    rep2.childRepresentation = nil;
    
    TempRepresentation *rep3 = [[TempRepresentation alloc]init];
    rep3.name = @"Apps";
    rep3.size = 1500;
    rep3.type = InodeTypeFolder;
    rep3.childRepresentation = nil;
    
    TempRepresentation *rep4 = [[TempRepresentation alloc]init];
    rep4.name = @"Apps2";
    rep4.size = 400;
    rep4.type = InodeTypeFolder;
    rep4.childRepresentation = nil;
    
    TempRepresentation *rep5 = [[TempRepresentation alloc]init];
    rep5.name = @"silly.pdf";
    rep5.size = 400;
    rep5.type = InodeTypeFile;
    rep5.childRepresentation = nil;
    
    return @[rep1,rep2,rep3,rep4,rep5];
}


@end
