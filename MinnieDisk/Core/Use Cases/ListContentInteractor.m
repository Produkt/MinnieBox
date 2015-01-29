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

@interface ListContentInteractor ()<DBRestClientDelegate>
@property (strong,nonatomic) MDInode *rootInode;
@property (copy,nonatomic) loadContentCallback completion;
@property (assign,nonatomic) NSUInteger nodesCount;
@property (strong,nonatomic) NSMutableArray *dbMetadata;
@end
@implementation ListContentInteractor
- (void)listDropboxTreeWithCompletion:(loadContentCallback)completion{
    self.nodesCount = 1;
    self.completion = completion;
    [self.dbRestClient loadMetadata:@"/"];
}
- (void)requestDeltaWithCursor:(NSString *)cursor{
    NSLog(@"---");
    [self.dbRestClient loadDelta:cursor];
}
- (void)finishedReadingDropboxContent{
    NSArray *sortedMetadata = [self.dbMetadata sortedArrayUsingComparator:^NSComparisonResult(id<InodeRepresentationProtocol> obj1, id<InodeRepresentationProtocol> obj2) {
        return [[obj1 inodePath] compare:[obj2 inodePath]];
    }];
    self.dbMetadata = nil;
    for (id<InodeRepresentationProtocol> inodeRepresentation in sortedMetadata) {
        [self.rootInode addChildInodeRepresentation:inodeRepresentation];
    }
    NSLog(@"Finish processing %lu nodes",(unsigned long)self.nodesCount);
    self.completion(self.rootInode);
    self.completion = nil;
    self.rootInode = nil;
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
    for (DBDeltaEntry *deltaEntry in entries) {
        DBMetadata *inodeMetadata = deltaEntry.metadata;
        [self.dbMetadata addObject:inodeMetadata];
        _nodesCount ++;
    }
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
@end
