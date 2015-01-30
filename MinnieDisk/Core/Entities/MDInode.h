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
@property (copy,nonatomic,readonly) NSString *inodeName;
@property (copy,nonatomic,readonly) NSString *inodePath;
@property (strong,nonatomic,readonly) NSDate *inodeCreationDate;
@property (assign,nonatomic,readonly) NSUInteger inodeSize;
@property (assign,nonatomic,readonly) InodeType inodeType;
@property (copy,nonatomic,readonly) NSString *inodeHumanReadableSize;
@property (strong,nonatomic,readonly) id<InodeRepresentationProtocol> inodeItem;
@property (strong,nonatomic,readonly) NSSet *draftedInodes;
@property (weak,nonatomic) id<InodeRepresentationProtocol> parentInode;
- (instancetype)initWithInodeItem:(id<InodeRepresentationProtocol>)inodeItem andDraftedInodes:(NSSet *)draftedInodes;
- (BOOL)addChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation;
- (BOOL)addChildInode:(MDInode *)childInode;
- (void)removeChildInode:(id<InodeRepresentationProtocol>)childInode;
- (void)updateChildsSort;
- (void)childInodeFileWasAddedToTree:(id<InodeRepresentationProtocol>)childInode;
@end
