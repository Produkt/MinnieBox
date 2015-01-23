//
//  ListContentInteractor.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ListContentInteractor.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ListContentInteractor ()<DBRestClientDelegate>
@property (copy,nonatomic) loadContentCallback callback;
@end
@implementation ListContentInteractor
@synthesize dbRestClient = _dbRestClient;
- (void)listRootContentWithCompletion:(loadContentCallback)completion{
    [self listRootContentWithInode:nil WithCompletion:completion];
}
- (void)listRootContentWithInode:(id<InodeRepresentationProtocol>)inode WithCompletion:(loadContentCallback)completion{
    self.callback = completion;
    [self.dbRestClient loadMetadata:inode?[inode inodePath]:@"/"];
}
#pragma mark - DBRestClientDelegate
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata{
    self.callback(@[metadata.contents]);
    self.callback = nil;
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
