//
//  MDInode.m
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MDInode.h"
#import <DropboxSDK/DropboxSDK.h>

static NSUInteger const pathComponentsPositionsToIncludeSeparator = 1;

@interface MDInode ()
@property (strong,nonatomic,readwrite) id<InodeRepresentationProtocol> inodeItem;
@property (strong,nonatomic,readwrite) NSSet *draftedInodes;
@property (strong,nonatomic) NSArray *inodeItemChilds;
@property (assign,nonatomic) NSUInteger inodeCachedSize;
@end
@implementation MDInode
- (instancetype)initWithInodeItem:(id<InodeRepresentationProtocol>)inodeItem andDraftedInodes:(NSSet *)draftedInodes
{
    self = [super init];
    if (self) {
        _inodeItem = inodeItem;
        _draftedInodes = draftedInodes;
        _inodeItemChilds = @[];
        _inodeCachedSize = [inodeItem inodeType] == InodeTypeFile ? [inodeItem inodeSize] : 0;
    }
    return self;
}
- (BOOL)addChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    if ([self addInodeToChildInodeFromChildInodeRepresentation:childInodeRepresentation]) {
        return YES;
    }
    if ([self addFirstChildWithChildInodeRepresentation:childInodeRepresentation]) {
        return YES;
    }
    if ([self moveChildsToNewInodeAndAddItAsFirstChilddWithChildInodeRepresentation:childInodeRepresentation]) {
        return YES;
    }
    return [self addChildInode:[[MDInode alloc] initWithInodeItem:childInodeRepresentation andDraftedInodes:self.draftedInodes]];
}
- (BOOL)addInodeToChildInodeFromChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    MDInode *parentInode = [self parentInodeForPath:[childInodeRepresentation inodePath] inInodes:self.inodeItemChilds];
    if (!parentInode) {
        return NO;
    }
    return [parentInode addChildInodeRepresentation:childInodeRepresentation];
}
- (BOOL)addFirstChildWithChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    NSString *parentPath = [self previousPathOfPath:[childInodeRepresentation inodePath]];
    if (![self.inodePath isEqualToString:parentPath]) {
        return NO;
    }
    return [self addChildInode:[[MDInode alloc] initWithInodeItem:childInodeRepresentation andDraftedInodes:self.draftedInodes]];
}
- (NSString *)previousPathOfPath:(NSString *)path{
    NSString *lastComponent = [path lastPathComponent];
    NSRange pathComponentRange;
    pathComponentRange.length = lastComponent.length + pathComponentsPositionsToIncludeSeparator;
    pathComponentRange.location = path.length - lastComponent.length - pathComponentsPositionsToIncludeSeparator;
    NSString *previousPath = [path stringByReplacingCharactersInRange:pathComponentRange withString:@""];
    if ([previousPath isEqualToString:@""]) {
        return @"/";
    }
    return previousPath;
}
- (BOOL)moveChildsToNewInodeAndAddItAsFirstChilddWithChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    NSArray *childInodes = [self childInodesForPath:[childInodeRepresentation inodePath] inInodes:self.inodeItemChilds];
    if (!childInodes.count) {
        return NO;
    }
    NSMutableArray *inodes = [self.inodeItemChilds mutableCopy];
    MDInode *inode = [[MDInode alloc] initWithInodeItem:childInodeRepresentation andDraftedInodes:self.draftedInodes];
    if (childInodes.count) {
        [inodes removeObjectsInArray:childInodes];
        for (MDInode *childInode in childInodes) {
            [inode addChildInode:childInode];
        }
    }
    self.inodeItemChilds = inodes;
    [self addChildInode:inode];
    return YES;
}
- (BOOL)addChildInode:(MDInode *)childInode{
    NSMutableArray *childs = [self.inodeItemChilds mutableCopy];
    [childs addObject:childInode];
    childInode.parentInode = self;
    self.inodeItemChilds = childs;
    if ([childInode inodeType] == InodeTypeFile) {
        [self childInodeFileWasAddedToTree:childInode];
    }
    [self updateChildsSort];
    return YES;
}
- (MDInode *)parentInodeForPath:(NSString *)path inInodes:(NSArray *)inodes{
    MDInode *parentInode;
    for (MDInode *potencialParentInode in inodes) {
        NSString *parentPath = potencialParentInode.inodePath;
        if (![parentPath isEqualToString:@"/"]) {
            parentPath = [NSString stringWithFormat:@"%@/",parentPath];
        }
        if ([[path lowercaseString] containsString:[parentPath lowercaseString]]) {
            parentInode = potencialParentInode;
        }
    }
    return parentInode;
}
- (NSArray *)childInodesForPath:(NSString *)path inInodes:(NSArray *)inodes{
    NSMutableArray *childInodes = [NSMutableArray array];
    for (MDInode *potencialChildInode in inodes) {
        NSString *parentPath = path;
        if (![parentPath isEqualToString:@"/"]) {
            parentPath = [NSString stringWithFormat:@"%@/",parentPath];
        }
        if ([[potencialChildInode.inodePath lowercaseString] containsString:[path lowercaseString]]) {
            [childInodes addObject:potencialChildInode];
        }
    }
    return childInodes;
}

- (void)childInodeFileWasAddedToTree:(id<InodeRepresentationProtocol>)childInode{
    self.inodeCachedSize += [childInode inodeSize];
    if ([self.parentInode respondsToSelector:@selector(childInodeFileWasAddedToTree:)]) {
        [self.parentInode childInodeFileWasAddedToTree:childInode];
    }
}
- (void)updateChildsSort{
    NSArray *childs = self.inodeItemChilds;
    NSArray *sortedChilds = [childs sortedArrayUsingComparator:^NSComparisonResult(id<InodeRepresentationProtocol> obj1, id<InodeRepresentationProtocol> obj2) {
        return [@([obj2 inodeSize]) compare:@([obj1 inodeSize])];
    }];
    self.inodeItemChilds = sortedChilds;
    [self.parentInode updateChildsSort];
}
- (void)removeChildInode:(id<InodeRepresentationProtocol>)childInode{
    if ([self.inodeItemChilds containsObject:childInode]) {
        NSMutableArray *childs = [self.inodeItemChilds mutableCopy];
        [childs removeObject:childInode];
        self.inodeItemChilds = childs;
    }
}
- (NSString *)inodeName{
    return [self.inodeItem inodeName];
}
- (NSString *)inodePath{
    return [self.inodeItem inodePath];
}
- (NSDate *)inodeCreationDate{
    return [self.inodeItem inodeCreationDate];
}
- (NSUInteger)inodeSize{
    if ([self.inodeItem inodeType] == InodeTypeFile) {
        return self.inodeCachedSize;
    }
    return [self folderContentSize];
}
- (NSUInteger)folderContentSize{
    if (self.inodeCachedSize) {
        return self.inodeCachedSize;
    }else if(self.inodeItemChilds.count){
        NSUInteger size = 0;
        for (MDInode *inode in self.inodeItemChilds) {
            if (![self.draftedInodes containsObject:inode]) {
                size += [inode inodeSize];
            }
        }
        self.inodeCachedSize = size;
        return size;
    }
    return 0;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"<MDInode> %@",[self inodePath]];
}
- (InodeType)inodeType{
    return [self.inodeItem inodeType];
}
- (NSString *)inodeHumanReadableSize{
    return [NSByteCountFormatter stringFromByteCount:[self inodeSize] countStyle:NSByteCountFormatterCountStyleBinary];
}
- (NSArray *)inodeChilds{
    return self.inodeItemChilds;
}
- (NSArray *)inodeUndraftedChilds{
    NSMutableArray *undraftedChilds = [self.inodeItemChilds mutableCopy];
    [undraftedChilds removeObjectsInArray:[self.draftedInodes allObjects]];
    return undraftedChilds;
}
@end
