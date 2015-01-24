//
//  MDInodeTests.m
//  
//
//  Created by Daniel García on 24/01/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MDInode.h"

static NSUInteger const numberOfChilds = 10;

@interface MDInodeTests : XCTestCase
@property (strong,nonatomic) MDInode *inode;
@property (strong,nonatomic) NSMutableSet *draftedInodes;
@end

@implementation MDInodeTests

- (void)setUp {
    [super setUp];
    self.draftedInodes = [NSMutableSet set];
    self.inode = [[MDInode alloc] initWithInodeItem:[self inodeMock] andDraftedInodes:self.draftedInodes];
}

- (id<InodeRepresentationProtocol>)inodeMock{
    id<InodeRepresentationProtocol> inodeMock = mockProtocol(@protocol(InodeRepresentationProtocol));
    NSMutableArray *childMocks = [NSMutableArray array];
    for (NSUInteger i = 0; i<numberOfChilds; i++) {
        id<InodeRepresentationProtocol> inodeChildMock = mockProtocol(@protocol(InodeRepresentationProtocol));
        [given([inodeChildMock inodeName]) willReturn:[NSString stringWithFormat:@"/%lu.file",(unsigned long)i]];
        [given([inodeChildMock inodeType]) willReturnInteger:InodeTypeFile];
        [given([inodeChildMock inodeSize]) willReturnInteger:(i+1)*10];
        [childMocks addObject:inodeChildMock];
    }
    [given([inodeMock inodeType]) willReturnInteger:InodeTypeFolder];
    [given([inodeMock inodeChilds]) willReturn:childMocks];
    return inodeMock;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInodeSize {
    NSUInteger expectedSize = 550;
    NSUInteger inodeSize = [self.inode inodeSize];
    XCTAssertEqual(inodeSize, expectedSize);
}

- (void)testInodeSizeWhenRemovingChild {
    [self.draftedInodes addObject:[self.inode inodeChilds][0]];
    XCTAssertEqual([self.inode inodeSize], 540);
    
    [self.draftedInodes addObject:[self.inode inodeChilds][9]];
    XCTAssertEqual([self.inode inodeSize], 440);
    
    [self.draftedInodes addObject:[self.inode inodeChilds][2]];
    XCTAssertEqual([self.inode inodeSize], 410);
}

- (void)testUndraftedChilds{
    [self.draftedInodes addObject:[self.inode inodeChilds][0]];
    [self.draftedInodes addObject:[self.inode inodeChilds][1]];
    XCTAssert(![[self.inode inodeUndraftedChilds]containsObject:[self.inode inodeChilds][0]]);
    XCTAssert(![[self.inode inodeUndraftedChilds]containsObject:[self.inode inodeChilds][1]]);
}

- (void)testInodeHumanReadableSize {
    XCTAssertEqualObjects([self.inode inodeHumanReadableSize], @"550 bytes");
}

@end
