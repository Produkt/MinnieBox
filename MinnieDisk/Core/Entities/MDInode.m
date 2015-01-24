//
//  MDInode.m
//  MinnieDisk
//
//  Created by Daniel García on 24/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MDInode.h"
#import <DropboxSDK/DropboxSDK.h>

@interface MDInode ()
@property (strong,nonatomic,readwrite) id<InodeRepresentationProtocol> inodeItem;
@property (strong,nonatomic,readwrite) NSSet *draftedInodes;
@property (strong,nonatomic) NSArray *inodeItemChilds;
@end
@implementation MDInode
- (instancetype)initWithInodeItem:(id<InodeRepresentationProtocol>)inodeItem andDraftedInodes:(NSSet *)draftedInodes
{
    self = [super init];
    if (self) {
        _inodeItem = inodeItem;
        _draftedInodes = draftedInodes;
        if ([[inodeItem inodeChilds] count]) {
            _inodeItemChilds = [self mdInodesFromInodeItemChilds:[inodeItem inodeChilds]];
        }
    }
    return self;
}
- (void)setInodeRepresentationChilds:(NSArray *)inodeRepresentationChilds{
    self.inodeItemChilds = [self mdInodesFromInodeItemChilds:inodeRepresentationChilds];
}
- (NSArray *)mdInodesFromInodeItemChilds:(NSArray *)childs{
    NSMutableArray *inodes = [NSMutableArray array];
    for (id<InodeRepresentationProtocol> inode in childs) {
        [inodes addObject:[[MDInode alloc] initWithInodeItem:inode andDraftedInodes:self.draftedInodes]];
    }
    return inodes;
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
        return [self.inodeItem inodeSize];
    }
    return [self folderContentSize];
}
- (NSUInteger)folderContentSize{
    NSUInteger size = 0;
    for (MDInode *inode in self.inodeItemChilds) {
        if (![self.draftedInodes containsObject:inode]) {
            size += [inode inodeSize];
        }
    }
    return size;
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
