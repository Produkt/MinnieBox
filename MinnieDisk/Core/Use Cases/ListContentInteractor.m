//
//  ListContentInteractor.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "ListContentInteractor.h"
#import <DropboxSDK/DropboxSDK.h>

@implementation ListContentInteractor
- (DBRestClient *)dbRestClient{
    if (!_dbRestClient) {
        _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    return _dbRestClient;
}
@end
