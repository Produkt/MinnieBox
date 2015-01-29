//
//  DraftContentInteractor.m
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "DraftContentInteractor.h"

NSString * const DraftInodesAddInodeNotification = @"DraftInodesAddInodeNotification";
NSString * const DraftInodesRemoveInodeNotification = @"DraftInodesRemoveInodeNotification";
NSString * const DraftInodesWillRemoveInodeNotification = @"DraftInodesWillRemoveInodeNotification";

@interface DraftContentInteractor ()
@property (strong,nonatomic,readwrite) NSMutableSet *draftedInodes;
@end
@implementation DraftContentInteractor
- (instancetype)initWithDraftedInodes:(NSMutableSet *)draftedInodes
{
    NSParameterAssert(draftedInodes);
    self = [super init];
    if (self) {
        _draftedInodes = draftedInodes;
    }
    return self;
}
- (instancetype)init
{
    return [self initWithDraftedInodes:nil];
}
- (void)addInode:(id<InodeRepresentationProtocol>)inode completion:(void(^)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.draftedInodes addObject:inode];
        [[NSNotificationCenter defaultCenter] postNotificationName:DraftInodesAddInodeNotification object:inode];
        completion();
    });
}
- (void)removeInode:(id<InodeRepresentationProtocol>)inode completion:(void(^)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DraftInodesWillRemoveInodeNotification object:inode];
        [self.draftedInodes removeObject:inode];
        [[NSNotificationCenter defaultCenter] postNotificationName:DraftInodesRemoveInodeNotification object:inode];
        completion();
    });
}
@end
