//
//  MainTableViewCell.m
//  MinnieDisk
//
//  Created by Victor Baro on 23/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MainTableViewCell.h"


@interface MainTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *disclosureImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (nonatomic, strong) CALayer *percentageLayer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingEdgeConstraint;
@end
@implementation MainTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self configurePrecentageLayer];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.percentageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bottomBarView.frame)* self.sizePercentage,
                                             CGRectGetHeight(self.bottomBarView.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.folderCell) {
        [super setSelected:selected animated:animated];
    }
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.folderCell) {
        [super setHighlighted:highlighted animated:animated];
    }
}

-(void)setSizePercentage:(CGFloat)sizePercentage {
    _sizePercentage = sizePercentage;
    [self updatePercetageLayer];
}

- (void)setPercentageColor:(UIColor *)percentageColor {
    _percentageColor = percentageColor;
    self.percentageLayer.backgroundColor = percentageColor.CGColor;
}
- (void)setFolderCell:(BOOL)folderCell {
    _folderCell = folderCell;
    self.disclosureImageView.hidden = !folderCell;
    
}
- (void)configurePrecentageLayer{
    self.percentageLayer = [CALayer layer];
    self.percentageLayer.backgroundColor = self.percentageColor.CGColor;
    self.percentageLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bottomBarView.frame), CGRectGetHeight(self.bottomBarView.frame));
    [self.bottomBarView.layer addSublayer:self.percentageLayer];
}

- (void)updatePercetageLayer{
    self.percentageLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bottomBarView.frame) * self.sizePercentage, CGRectGetHeight(self.bottomBarView.frame));
}
-(void)animateTitleToDeleteState {
    self.leadingEdgeConstraint.constant = 100;
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
}

-(void)resetTitleToNormalStateAnimated:(BOOL)animated {
    self.leadingEdgeConstraint.constant = 16;
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }

}
@end
