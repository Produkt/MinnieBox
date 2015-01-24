//
//  MainTableViewCell.m
//  MinnieDisk
//
//  Created by Victor Baro on 23/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MainTableViewCell.h"


@interface MainTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (nonatomic, strong) CALayer *percentageLayer;
@end
@implementation MainTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self configurePrecentageLayer];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.percentageLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bottomBarView.frame),
                                             CGRectGetHeight(self.bottomBarView.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSizePercentage:(CGFloat)sizePercentage {
    _sizePercentage = sizePercentage;
    [self updatePercetageLayer];
}

- (void)setPercentageColor:(UIColor *)percentageColor {
    _percentageColor = percentageColor;
    self.percentageLayer.backgroundColor = percentageColor.CGColor;
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
@end
