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
@property (strong,nonatomic) DBRestClient *dbRestClientMock;
@end

@implementation ListContentInteractorTests

- (void)setUp {
    [super setUp];
    self.dbRestClientMock = mock([DBRestClient class]);
    self.listContentInteractor = [[ListContentInteractor alloc] init];
//    self.listContentInteractor.dbRestClient = self.dbRestClientMock;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeltaRequest {
    [self.listContentInteractor listDropboxTreeWithCompletion:^(id<InodeRepresentationProtocol> inode) {

    }progress:^(NSUInteger processedItems, NSUInteger total, MDLoadProgressState progressState) {
        
    }];
    while (YES) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

//- (void)testDBRestClientList {
//    [self.listContentInteractor listRootContentWithCompletion:^(id<InodeRepresentationProtocol> inode) {
//        
//    }];
//    [MKTVerify(self.dbRestClientMock) loadMetadata:@"/"];
//    
//    
//    id<InodeRepresentationProtocol> inode = mockProtocol(@protocol(InodeRepresentationProtocol));
//    [given([inode inodePath]) willReturn:@"/folder"];
//    
//    [self.listContentInteractor listRootContentWithInode:inode withCompletion:^(id<InodeRepresentationProtocol> inode) {
//        
//    }];
//    [MKTVerify(self.dbRestClientMock) loadMetadata:[inode inodePath]];
//    
//}



@end
