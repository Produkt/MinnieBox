//
//  ViewController.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) NSArray *inodeRepresentations;
@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithInodeRepresentation:(id<inodeRepresentationProtocol>)inode {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
