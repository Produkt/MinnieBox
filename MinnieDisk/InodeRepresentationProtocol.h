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
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *inodePath;
@property (nonatomic) NSDate *creationDate;
@property (nonatomic) NSUInteger size;
@property (nonatomic) InodeType type;
@property (nonatomic) NSString *humanReadableSize;
@optional
@property (nonatomic) NSArray *childRepresentation;
@end
