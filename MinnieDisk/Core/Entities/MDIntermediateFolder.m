//
//  MDIntermediateFolder.m
//  MinnieDisk
//
//  Created by Daniel García García on 29/1/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "MDIntermediateFolder.h"

@implementation MDIntermediateFolder
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _inodeName = [path lastPathComponent];
        _inodePath = [path copy];
        _inodeCreationDate = [NSDate date];
        _inodeType = InodeTypeFolder;
        _inodeHumanReadableSize = [NSByteCountFormatter stringFromByteCount:0 countStyle:NSByteCountFormatterCountStyleBinary];
    }
    return self;
}
@end
