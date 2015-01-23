//
//  ListContentInteractorTests.m
//  MinnieDisk
//
//  Created by Daniel García on 23/01/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ListContentInteractor.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ListContentInteractorTests : XCTestCase
@property (strong,nonatomic) ListContentInteractor *listContentInteractor;
@end

@implementation ListContentInteractorTests

- (void)setUp {
    [super setUp];
    self.listContentInteractor = [[ListContentInteractor alloc] init];
    self.listContentInteractor.dbRestClient = mock([DBRestClient class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test {
    
}

@end
