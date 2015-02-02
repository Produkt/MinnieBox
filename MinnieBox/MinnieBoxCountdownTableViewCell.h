//
//  MinnieBoxCountdownTableViewCell.h
//  
//
//  Created by Daniel García on 24/01/15.
//
//

#import <UIKit/UIKit.h>

@protocol CountdownCellDelegate <NSObject>
- (void)countDownFinished;
@end

@interface MinnieBoxCountdownTableViewCell : UITableViewCell
@property (nonatomic, weak) id<CountdownCellDelegate> delegate;
- (void)startCountDown;
- (void)stopCountDown;
@end
