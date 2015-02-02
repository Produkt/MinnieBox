//
//  LoaderViewController.m
//  MinnieBox
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "LinkerViewController.h"
#import <DropboxSDK/DropboxSDK.h>


@interface LinkerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@end

@implementation LinkerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connectButtonPressed:(id)sender {
    [[DBSession sharedSession] linkFromController:self];
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
