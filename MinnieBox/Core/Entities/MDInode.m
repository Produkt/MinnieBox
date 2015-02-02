//
//  MDInode.m
//  MinnieBox
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MDInode.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MDIntermediateFolder.h"

static NSUInteger const pathComponentsPositionsToIncludeSeparator = 1;

@interface MDInode ()
@property (copy,nonatomic,readwrite) NSString *inodeName;
@property (copy,nonatomic,readwrite) NSString *inodePath;
@property (strong,nonatomic,readwrite) NSDate *inodeCreationDate;
@property (assign,nonatomic,readwrite) InodeType inodeType;
@property (copy,nonatomic,readwrite) NSString *inodeHumanReadableSize;
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
        _inodeType = [inodeItem inodeType];
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
    if ([self buildIntermediateNodesAndAddChildInodeRepresentation:childInodeRepresentation]) {
        return YES;
    }
    return [self addChildInode:[[MDInode alloc] initWithInodeItem:childInodeRepresentation andDraftedInodes:self.draftedInodes]];
}
- (BOOL)buildIntermediateNodesAndAddChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    if ([[[self previousPathOfPath:[childInodeRepresentation inodePath]] lowercaseString] isEqualToString:[[self inodePath] lowercaseString]]) {
        return NO;
    }
    MDIntermediateFolder *intermediateFolder = [self intermediateFolderForChildInodeRepresentation:childInodeRepresentation];
    MDInode *firstIntermediateNode = [[MDInode alloc] initWithInodeItem:intermediateFolder andDraftedInodes:self.draftedInodes];
    [firstIntermediateNode addChildInodeRepresentation:childInodeRepresentation];
    return [self addChildInode:firstIntermediateNode];
}
- (MDIntermediateFolder *)intermediateFolderForChildInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    NSString *basePath = [[self inodePath] lowercaseString];
    NSRange basePathRange;
    basePathRange.location = 0;
    basePathRange.length = basePath.length > 1 ? basePath.length : 0;
    NSString *intermediatePaths = [[[childInodeRepresentation inodePath] lowercaseString] stringByReplacingCharactersInRange:basePathRange withString:@""];
    NSArray *pathComponents = [intermediatePaths componentsSeparatedByString:@"/"];
    NSString *firstIntermediatePath = [[[self inodePath] lowercaseString] stringByAppendingPathComponent:[pathComponents objectAtIndex:1]];
    return [[MDIntermediateFolder alloc] initWithPath:firstIntermediatePath];
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
    if ([self replaceIntermediateNodesWithInodeRepresentation:childInodeRepresentation]) {
        return YES;
    }
    return [self addChildInode:[[MDInode alloc] initWithInodeItem:childInodeRepresentation andDraftedInodes:self.draftedInodes]];
}
- (BOOL)replaceIntermediateNodesWithInodeRepresentation:(id<InodeRepresentationProtocol>)childInodeRepresentation{
    if ([childInodeRepresentation inodeType] != InodeTypeFolder) {
        return NO;
    }
    MDInode *intermediateInode = [self existingIntermediateInodeWithPath:[childInodeRepresentation inodePath]];
    if (!intermediateInode) {
        return NO;
    }
    MDInode *inode = [[MDInode alloc] initWithInodeItem:childInodeRepresentation andDraftedInodes:self.draftedInodes];
    for (MDInode *childInode in intermediateInode.inodeChilds) {
        [inode addChildInode:childInode];
    }
    [self removeChildInode:intermediateInode];
    return [self addChildInode:inode];
}
- (MDInode *)existingIntermediateInodeWithPath:(NSString *)path{
    MDInode *intermediateInode;
    for (MDInode *childInode in self.inodeItemChilds) {
        if ([[childInode.inodePath lowercaseString] isEqualToString:[path lowercaseString]]) {
            intermediateInode = childInode;
        }
    }
    return intermediateInode;
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
            @autoreleasepool {
                [inode addChildInode:childInode];
            }
        }
    }
    self.inodeItemChilds = inodes;
    return [self addChildInode:inode];
}
- (MDInode *)parentInodeForPath:(NSString *)path inInodes:(NSArray *)inodes{
    MDInode *parentInode;
    @autoreleasepool {
        for (MDInode *potencialParentInode in inodes) {
            NSString *parentPath = potencialParentInode.inodePath;
            if (![parentPath isEqualToString:@"/"]) {
                parentPath = [NSString stringWithFormat:@"%@/",parentPath];
            }
            if ([[path lowercaseString] hasPrefix:[parentPath lowercaseString]]) {
                parentInode = potencialParentInode;
            }
        }
    }
    return parentInode;
}
- (NSArray *)childInodesForPath:(NSString *)path inInodes:(NSArray *)inodes{
    NSMutableArray *childInodes = [NSMutableArray array];
    @autoreleasepool {
        for (MDInode *potencialChildInode in inodes) {
            NSString *parentPath = path;
            if (![parentPath isEqualToString:@"/"]) {
                parentPath = [NSString stringWithFormat:@"%@/",parentPath];
            }
            if ([[potencialChildInode.inodePath lowercaseString] hasPrefix:[path lowercaseString]]) {
                [childInodes addObject:potencialChildInode];
            }
        }
    }
    return childInodes;
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

- (void)childInodeFileWasAddedToTree:(id<InodeRepresentationProtocol>)childInode{
    self.inodeCachedSize += [childInode inodeSize];
    if ([self.parentInode respondsToSelector:@selector(childInodeFileWasAddedToTree:)]) {
        [self.parentInode childInodeFileWasAddedToTree:childInode];
    }
}
- (void)setInodeCachedSize:(NSUInteger)inodeCachedSize{
    _inodeCachedSize = inodeCachedSize;
    self.inodeHumanReadableSize = nil;
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
    if (!_inodeName) {
        _inodeName = [[self.inodeItem inodeName] copy];
    }
    return _inodeName;
}
- (NSString *)inodePath{
    if (!_inodePath) {
        _inodePath = [[self.inodeItem inodePath] copy];
    }
    return _inodePath;
}
- (NSDate *)inodeCreationDate{
    if (!_inodeCreationDate) {
        _inodeCreationDate = [self.inodeItem inodeCreationDate];
    }
    return _inodeCreationDate;
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
- (NSString *)inodeHumanReadableSize{
    if (!_inodeHumanReadableSize) {
        _inodeHumanReadableSize = [NSByteCountFormatter stringFromByteCount:self.inodeSize countStyle:NSByteCountFormatterCountStyleBinary];
    }
    return _inodeHumanReadableSize;
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
