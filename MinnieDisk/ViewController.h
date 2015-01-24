//
//  ViewController.h
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InodeRepresentationProtocol.h"


@interface ViewController : UIViewController
@property (strong,nonatomic) NSMutableSet *draftedInodes;
- (instancetype)initWithInodeRepresentation:(id<InodeRepresentationProtocol>)inode;
- (void)getInodeRepresentation;
@end
