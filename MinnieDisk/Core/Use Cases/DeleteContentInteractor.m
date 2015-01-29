//
//  DeleteContentInteractor.m
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "DeleteContentInteractor.h"
#import <DropboxSDK/DropboxSDK.h>
#import "THOperation.h"
#import "DraftContentInteractor.h"

@interface DeletionOperation : THOperation<DBRestClientDelegate>
@property (strong,nonatomic) DBRestClient *dbRestClient;
@property (strong,nonatomic) id<InodeRepresentationProtocol> inode;
@end

@implementation DeletionOperation
- (instancetype)initWithDBRestClient:(DBRestClient *)restClient inode:(id<InodeRepresentationProtocol>)inode
{
    self = [super init];
    if (self) {
        _dbRestClient = restClient;
        _dbRestClient.delegate = self;
        _inode = inode;
    }
    return self;
}
- (void)start{
    [super start];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dbRestClient deletePath:[self.inode inodePath]];
    });
}
- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
    [[self.inode parentInode] removeChildInode:self.inode];
    [self finish];
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
    [self finish];
}
@end

@interface DeleteContentInteractor ()
@property (strong,nonatomic) NSOperationQueue *deletionQueue;
@end
@implementation DeleteContentInteractor
@synthesize dbRestClient = _dbRestClient;
- (void)deleteInode:(id<InodeRepresentationProtocol>)inode withCompletion:(void(^)(void))completion{
    DeletionOperation *deletionOperation = [[DeletionOperation alloc] initWithDBRestClient:self.dbRestClient inode:inode];
    [deletionOperation setCompletionBlock:completion];
    [self.deletionQueue addOperation:deletionOperation];
}
- (void)deleteInodes:(NSArray *)inodes withCompletion:(void(^)(void))completion{
    dispatch_group_t deletionGroup = dispatch_group_create();
    for (id<InodeRepresentationProtocol> inode in inodes) {
        dispatch_group_enter(deletionGroup);
        [self deleteInode:inode withCompletion:^{
            [self.draftContentInteractor removeInode:inode completion:nil];
            dispatch_group_leave(deletionGroup);
        }];
    }
    dispatch_group_notify(deletionGroup, dispatch_get_main_queue(), ^{
        completion();
    });
}
- (DBRestClient *)dbRestClient{
    if (!_dbRestClient) {
        _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    return _dbRestClient;
}
- (NSOperationQueue *)deletionQueue{
    if (!_deletionQueue) {
        _deletionQueue = [[NSOperationQueue alloc] init];
        _deletionQueue.maxConcurrentOperationCount = 1;
    }
    return _deletionQueue;
}
@end


