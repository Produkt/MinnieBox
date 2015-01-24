//
//  ListContentInteractor.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ListContentInteractor.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MDInode.h"
#import "DBMetadata+InodeRepresentation.h"
#import "THOperation.h"

@interface LoadMetadataOperation : THOperation<DBRestClientDelegate>
@property (strong,nonatomic) DBRestClient *dbRestClient;
@property (strong,nonatomic) id<InodeRepresentationProtocol> inode;
@property (strong,nonatomic) MDInode *requestedInode;
@property (strong,nonatomic) NSSet *draftedInodes;
@property (assign,nonatomic) NSUInteger retries;
@end

@implementation LoadMetadataOperation
- (instancetype)initWithDBRestClient:(DBRestClient *)restClient inode:(id<InodeRepresentationProtocol>)inode
{
    self = [super init];
    if (self) {
//        _dbRestClient = restClient;
//        _dbRestClient.delegate = self;
        _inode = inode;
        _requestedInode = [inode isKindOfClass:[MDInode class]] ? inode : nil;
    }
    return self;
}
- (void)start{
    [super start];
    [self requestMetadata];
}
- (void)requestMetadata{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *path = self.inode?[self.inode inodePath]:@"/";
        NSLog(@"+ Load metadata for path %@",path);
        [self.dbRestClient loadMetadata:path];
    });
}
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata{
    NSLog(@"- Loaded metadata for path %@",metadata.path);
    MDInode *mdInode = self.requestedInode;
    if (!mdInode) {
        mdInode = [[MDInode alloc] initWithInodeItem:metadata andDraftedInodes:self.draftedInodes];
    }else{
        [mdInode setInodeRepresentationChilds:metadata.contents];
    }
    self.requestedInode = mdInode;
    [self finish];
}
- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path{
    NSLog(@"- Loaded metadata for path %@",path);
    [self finish];
}
- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error{
    NSLog(@"- Error loading metadata");
    if (self.retries < 3) {
        self.retries++;
        [self requestMetadata];
    }else{
        [self finish];
    }
}
- (DBRestClient *)dbRestClient{
    if (!_dbRestClient) {
        _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _dbRestClient.delegate = self;
    }
    return _dbRestClient;
}
@end

@interface ListContentInteractor ()<DBRestClientDelegate>
@property (strong,nonatomic) NSOperationQueue *loadMetadataQueue;
@property (strong,nonatomic) MDInode *requestedInode;
@end
@implementation ListContentInteractor
@synthesize dbRestClient = _dbRestClient;
- (void)listRootContentWithCompletion:(loadContentCallback)completion{
    [self listRootContentWithInode:nil withCompletion:completion];
}
- (void)listRootContentWithInode:(id<InodeRepresentationProtocol>)inode withCompletion:(loadContentCallback)completion{
    [self enqueueLoadMetadataForInode:inode withCompletion:^(id<InodeRepresentationProtocol> inode) {
        completion(inode);
    }];
}
- (void)enqueueLoadMetadataForInode:(id<InodeRepresentationProtocol>)inode withCompletion:(loadContentCallback)completion{
    LoadMetadataOperation *loadMetadataOperation = [[LoadMetadataOperation alloc] initWithDBRestClient:self.dbRestClient inode:inode];
    __weak typeof(loadMetadataOperation) weakMetadataOperation = loadMetadataOperation;
    [loadMetadataOperation setCompletionBlock:^{
        if (!self.requestedInode) {
            self.requestedInode = weakMetadataOperation.requestedInode;
        }
        dispatch_group_t loadMetadataGroup = dispatch_group_create();
        for (id<InodeRepresentationProtocol> inodeChild in [weakMetadataOperation.requestedInode inodeChilds]) {
            if ([inodeChild inodeType] == InodeTypeFolder) {
                dispatch_group_enter(loadMetadataGroup);
                [self enqueueLoadMetadataForInode:inodeChild withCompletion:^(id<InodeRepresentationProtocol> inode) {
                    dispatch_group_leave(loadMetadataGroup);
                }];
            }
        }
        dispatch_group_notify(loadMetadataGroup, dispatch_get_main_queue(), ^{
            completion(self.requestedInode);
        });
    }];
    [self.loadMetadataQueue addOperation:loadMetadataOperation];
}
#pragma mark - DBRestClientDelegate
- (NSOperationQueue *)loadMetadataQueue{
    if (!_loadMetadataQueue) {
        _loadMetadataQueue = [[NSOperationQueue alloc] init];
//        _loadMetadataQueue.maxConcurrentOperationCount = 1;
    }
    return _loadMetadataQueue;
}
@end
