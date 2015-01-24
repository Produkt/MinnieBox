//
//  DraftContentInteractor.h
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InodeRepresentationProtocol.h"

@interface DraftContentInteractor : NSObject
@property (strong,nonatomic,readonly) NSMutableSet *draftedInodes;
- (instancetype)initWithDraftedInodes:(NSMutableSet *)draftedInodes;
- (void)addInode:(id<InodeRepresentationProtocol>)inode;
- (void)removeInode:(id<InodeRepresentationProtocol>)inode;
@end
