//
//  ListContentInteractor.m
//  MinnieBox
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ListContentInteractor.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MDInode.h"
#import "DBMetadata+InodeRepresentation.h"

@interface ListContentInteractor ()<DBRestClientDelegate>
@property (strong,nonatomic) MDInode *rootInode;
@property (copy,nonatomic) loadContentCallback completion;
@property (copy,nonatomic) loadContentProgress progress;
@property (strong,nonatomic) NSMutableArray *dbMetadata;
@property (strong,nonatomic) NSOperationQueue *nodeProccessOperationQueue;
@end
@implementation ListContentInteractor
- (void)listDropboxTreeWithCompletion:(loadContentCallback)completion progress:(loadContentProgress)progress{
    self.completion = completion;
    self.progress = progress;
    [self.dbRestClient loadMetadata:@"/"];
}
- (void)requestDeltaWithCursor:(NSString *)cursor{
    NSLog(@"---");
    [self.dbRestClient loadDelta:cursor];
}
- (void)finishedReadingDropboxContent{
    NSUInteger index = 0;
    NSUInteger total = self.dbMetadata.count;
    dispatch_group_t proccessNodesGroup = dispatch_group_create();
    for (DBDeltaEntry *deltaEntry in self.dbMetadata) {
        if (deltaEntry.metadata) {
            dispatch_group_enter(proccessNodesGroup);
            NSBlockOperation *proccessNodeOperation = [NSBlockOperation blockOperationWithBlock:^{
                @autoreleasepool {
                    [self.rootInode addChildInodeRepresentation:deltaEntry.metadata];
                }
            }];
            [proccessNodeOperation setCompletionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progress(index+1,total,MDLoadProgressStateProccess);
                    dispatch_group_leave(proccessNodesGroup);
                });
            }];
            [self.nodeProccessOperationQueue addOperation:proccessNodeOperation];
        }
        index++;
    }
    dispatch_group_notify(proccessNodesGroup, dispatch_get_main_queue(), ^{
        NSLog(@"Finish processing %lu nodes",(unsigned long)self.dbMetadata.count);
        self.completion(self.rootInode);
        self.completion = nil;
        self.progress = nil;
        self.rootInode = nil;
        self.dbMetadata = nil;
    });
}

#pragma mark - DBRestClientDelegate
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata{
    NSLog(@"- Loaded metadata for path %@",metadata.path);
    self.rootInode = [[MDInode alloc] initWithInodeItem:metadata andDraftedInodes:self.draftedInodes];
    [self requestDeltaWithCursor:@""];
}
- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path{
    
}
- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error{
    //    if (self.retries < 3) {
    //        self.retries++;
    //        [self requestMetadata];
    //    }
}

- (void)restClient:(DBRestClient*)client loadedDeltaEntries:(NSArray *)entries reset:(BOOL)shouldReset cursor:(NSString *)cursor hasMore:(BOOL)hasMore{
    if (shouldReset && self.dbMetadata.count) {
        NSLog(@"******* Reset requiered *******");
        [self.dbRestClient loadMetadata:@"/"];
        return;
    }
    NSLog(@"--- %lu",(unsigned long)entries.count);
    [self.dbMetadata addObjectsFromArray:entries];
    self.progress(0,self.dbMetadata.count,MDLoadProgressStateRequest);
    if (hasMore) {
        [self requestDeltaWithCursor:cursor];
    }else{
        [self finishedReadingDropboxContent];
    }
}
- (void)restClient:(DBRestClient*)client loadDeltaFailedWithError:(NSError *)error{
    
}
- (NSMutableArray *)dbMetadata{
    if (!_dbMetadata) {
        _dbMetadata = [NSMutableArray array];
    }
    return _dbMetadata;
}
- (DBRestClient *)dbRestClient{
    if (!_dbRestClient) {
        _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _dbRestClient.delegate = self;
    }
    return _dbRestClient;
}
- (NSOperationQueue *)nodeProccessOperationQueue{
    if (!_nodeProccessOperationQueue) {
        _nodeProccessOperationQueue = [[NSOperationQueue alloc] init];
        _nodeProccessOperationQueue.maxConcurrentOperationCount = 1;
    }
    return _nodeProccessOperationQueue;
}
@end
