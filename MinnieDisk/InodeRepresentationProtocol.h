//
//  inodeRepresentation.h
//  MinnieDisk
//
//  Created by Victor Baro on 23/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

typedef NS_ENUM(NSUInteger, InodeType) {
    InodeTypeFile,
    InodeTypeFolder
};

@protocol InodeRepresentationProtocol <NSObject>
@required
- (NSString *)inodeName;
- (NSString *)inodePath;
- (NSDate *)inodeCreationDate;
- (NSUInteger)inodeSize;
- (InodeType)inodeType;
- (NSString *)inodeHumanReadableSize;
@optional
- (id<InodeRepresentationProtocol>)parentInode;
- (NSArray *)inodeChilds;
- (NSArray *)inodeUndraftedChilds;
- (void)removeChildInode:(id<InodeRepresentationProtocol>)childInode;
@end
