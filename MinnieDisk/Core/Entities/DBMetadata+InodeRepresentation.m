//
//  DBMetadata+InodeRepresentation.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "DBMetadata+InodeRepresentation.h"

@implementation DBMetadata (InodeRepresentation)
- (NSString *)name{
    return self.filename;
}
- (NSDate *)creationDate{
    return self.clientMtime;
}
- (NSUInteger)size{
    return self.totalBytes;
}
- (InodeType)type{
    return self.isDirectory ? InodeTypeFolder : InodeTypeFile;
}
- (NSArray *)childRepresentation{
    return self.contents;
}
- (NSString *)path{
    return self.path;
}
@end
