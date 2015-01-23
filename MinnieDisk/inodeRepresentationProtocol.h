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

@protocol inodeRepresentationProtocol <NSObject>
@required
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, assign) InodeType type;
@optional
@property (nonatomic, strong) NSArray *childRepresentation;
@end
