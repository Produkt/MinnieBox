//
//  MinnieBoxViewController.h
//  MinnieDisk
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MinnieBoxViewController : UIViewController
@property (strong,nonatomic,readonly) NSSet *draftedInodes;
- (instancetype)initWithDraftedInodes:(NSSet *)draftedInodes;
@end
