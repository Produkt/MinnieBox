//
//  MinnieBoxCountdownTableViewCell.m
//  
//
//  Created by Daniel García on 24/01/15.
//
//

#import "MinnieBoxCountdownTableViewCell.h"
#import "VBFCountDown.h"

@interface MinnieBoxCountdownTableViewCell ()<CountDownDelegate>
@property (weak, nonatomic) IBOutlet VBFCountDown *countDown;

@end

@implementation MinnieBoxCountdownTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.countDown.totalSeconds = 5;
    self.countDown.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -  CountDownDelegate
- (void) countDownFinished {
    [self.delegate countDownFinished];
}

#pragma mark -  public api
- (void)startCountDown {
    [self.countDown startCountdown];
}
- (void)stopCountDown {
    [self.countDown stopCountdown];
}

@end
