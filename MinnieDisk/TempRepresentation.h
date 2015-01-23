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
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, assign) InodeType type;
@property (nonatomic, strong) NSArray *childRepresentation;
@end
