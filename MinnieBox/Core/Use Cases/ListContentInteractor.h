//
//  ListContentInteractor.h
//  MinnieBox
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InodeRepresentationProtocol.h"
@class DBRestClient;

typedef NS_ENUM(NSUInteger, MDLoadProgressState) {
    MDLoadProgressStateRequest,
    MDLoadProgressStateProccess
};

typedef void (^loadContentCallback)(id<InodeRepresentationProtocol> inode);
typedef void (^loadContentProgress)(NSUInteger processedItems, NSUInteger total, MDLoadProgressState progressState);

@interface ListContentInteractor : NSObject
@property (strong,nonatomic) DBRestClient *dbRestClient;
@property (strong,nonatomic) NSSet *draftedInodes;
- (void)listDropboxTreeWithCompletion:(loadContentCallback)completion progress:(loadContentProgress)progress;
@end
