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
@property (strong,nonatomic) MDInode *requestedInode;
@property (copy,nonatomic) loadContentCallback callback;
@end
@implementation ListContentInteractor
@synthesize dbRestClient = _dbRestClient;
- (void)listRootContentWithCompletion:(loadContentCallback)completion{
    [self listRootContentWithInode:nil withCompletion:completion];
}
- (void)listRootContentWithInode:(id<InodeRepresentationProtocol>)inode withCompletion:(loadContentCallback)completion{
    self.callback = completion;
    self.requestedInode = [inode isKindOfClass:[MDInode class]] ? inode : nil;
    [self.dbRestClient loadMetadata:inode?[inode inodePath]:@"/"];
}
#pragma mark - DBRestClientDelegate
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata{
    MDInode *mdInode = self.requestedInode;
    if (!mdInode) {
        mdInode = [[MDInode alloc] initWithInodeItem:metadata andDraftedInodes:self.draftedInodes];
    }else{
        [mdInode setInodeRepresentationChilds:metadata.contents];
    }
    self.callback(mdInode);
    self.callback = nil;
    self.requestedInode = nil;
}
- (void)setDbRestClient:(DBRestClient *)dbRestClient{
    _dbRestClient = dbRestClient;
    _dbRestClient.delegate = self;
}
- (DBRestClient *)dbRestClient{
    if (!_dbRestClient) {
        _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _dbRestClient.delegate = self;
    }
    return _dbRestClient;
}
@end
