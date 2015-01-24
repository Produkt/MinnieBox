//
//  MDInode.h
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InodeRepresentationProtocol.h"

@interface MDInode : NSObject<InodeRepresentationProtocol>
@property (strong,nonatomic,readonly) id<InodeRepresentationProtocol> inodeItem;
@property (strong,nonatomic,readonly) NSSet *draftedInodes;
@property (weak,nonatomic) id<InodeRepresentationProtocol> parentInode;
- (instancetype)initWithInodeItem:(id<InodeRepresentationProtocol>)inodeItem andDraftedInodes:(NSSet *)draftedInodes;
- (void)setInodeRepresentationChilds:(NSArray *)inodeRepresentationChilds;
- (void)removeChildInode:(id<InodeRepresentationProtocol>)childInode;
- (void)updateChildsSort;
@end
