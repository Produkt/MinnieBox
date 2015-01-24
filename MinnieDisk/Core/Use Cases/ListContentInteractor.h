//
//  ListContentInteractor.h
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InodeRepresentationProtocol.h"

typedef void (^loadContentCallback)(id<InodeRepresentationProtocol> inode);

@class DBRestClient;
@interface ListContentInteractor : NSObject
@property (strong,nonatomic) DBRestClient *dbRestClient;
@property (strong,nonatomic) NSSet *draftedInodes;
- (void)listRootContentWithCompletion:(loadContentCallback)completion;
- (void)listRootContentWithInode:(id<InodeRepresentationProtocol>)inode withCompletion:(loadContentCallback)completion;
@end
