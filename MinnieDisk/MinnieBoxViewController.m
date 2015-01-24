//
//  MinnieBoxViewController.m
//  MinnieDisk
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MinnieBoxViewController.h"

@interface MinnieBoxViewController ()

@end

@implementation MinnieBoxViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupTabbarItem];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationTitle];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
