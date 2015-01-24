//
//  MainTableViewCell.h
//  MinnieDisk
//
//  Created by Victor Baro on 23/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic, assign) CGFloat sizePercentage;
@property (nonatomic, strong) UIColor *percentageColor;
@property (nonatomic, assign, getter=isFolderCell) BOOL folderCell;
@end
