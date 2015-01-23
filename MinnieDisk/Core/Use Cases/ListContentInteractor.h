//
//  ListContentInteractor.h
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBRestClient;
@interface ListContentInteractor : NSObject
@property (strong,nonatomic) DBRestClient *dbRestClient;
- (void)listRootContentWithCompletion:(void(^)(id<>))completion;
@end
