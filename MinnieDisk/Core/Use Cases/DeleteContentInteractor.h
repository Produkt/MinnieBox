//
//  DeleteContentInteractor.h
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InodeRepresentationProtocol.h"

@class DBRestClient,DraftContentInteractor;
@interface DeleteContentInteractor : NSObject
@property (strong,nonatomic) DraftContentInteractor *draftContentInteractor;
@property (strong,nonatomic) DBRestClient *dbRestClient;
- (void)deleteInode:(id<InodeRepresentationProtocol>)inode withCompletion:(void(^)(void))completion;
- (void)deleteInodes:(NSArray *)inodes withCompletion:(void(^)(void))completion;
@end
