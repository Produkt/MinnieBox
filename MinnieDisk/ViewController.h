//
//  ViewController.h
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inodeRepresentationProtocol.h"


@interface ViewController : UIViewController

- (instancetype)initWithInodeRepresentation:(id<inodeRepresentationProtocol>)inode;

@end
