//
//  DBMetadata+InodeRepresentation.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "DBMetadata+InodeRepresentation.h"

@implementation DBMetadata (InodeRepresentation)
- (NSString *)inodeName{
    return self.filename;
}
- (NSDate *)inodeCreationDate{
    return self.clientMtime;
}
- (NSString *)inodePath{
    return self.path;
}
- (NSUInteger)inodeSize{
    return self.totalBytes;
}
- (NSString *)inodeHumanReadableSize{
    return self.humanReadableSize;
}
- (InodeType)inodeType{
    return self.isDirectory ? InodeTypeFolder : InodeTypeFile;
}
- (NSArray *)inodeChilds{
    return self.contents;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"<DBMetadata> %@",self.path];
}
@end
