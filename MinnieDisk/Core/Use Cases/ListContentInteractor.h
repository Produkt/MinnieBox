//
//  ListContentInteractor.h
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InodeRepresentationProtocol.h"

typedef void (^loadContentCallback)(NSArray *inodes);

@class DBRestClient;
@interface ListContentInteractor : NSObject
@property (strong,nonatomic) DBRestClient *dbRestClient;
- (void)listRootContentWithCompletion:(loadContentCallback)completion;
- (void)listRootContentWithInode:(id<InodeRepresentationProtocol>)inode WithCompletion:(loadContentCallback)completion;
@end
