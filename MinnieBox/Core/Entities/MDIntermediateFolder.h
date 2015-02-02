//
//  MDIntermediateFolder.h
//  MinnieBox
//
//  Created by Daniel García García on 29/1/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InodeRepresentationProtocol.h"

@interface MDIntermediateFolder:NSObject<InodeRepresentationProtocol>
@property (copy,nonatomic) NSString *inodeName;
@property (copy,nonatomic) NSString *inodePath;
@property (strong,nonatomic) NSDate *inodeCreationDate;
@property (assign,nonatomic) NSUInteger inodeSize;
@property (assign,nonatomic) InodeType inodeType;
@property (copy,nonatomic) NSString *inodeHumanReadableSize;
- (instancetype)initWithPath:(NSString *)path;
@end
