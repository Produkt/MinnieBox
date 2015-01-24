//
//  TempRepresentation.h
//  MinnieDisk
//
//  Created by Victor Baro on 23/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InodeRepresentationProtocol.h"

@interface TempRepresentation : NSObject <InodeRepresentationProtocol>
@property (nonatomic, copy) NSString *inodeName;
@property (nonatomic, strong) NSDate *inodeCreationDate;
@property (nonatomic, assign) NSUInteger inodeSize;
@property (nonatomic, assign) InodeType inodeType;
@property (nonatomic, strong) NSArray *inodeChilds;
@property (nonatomic, copy) NSString *inodeHumanReadableSize;

@end
