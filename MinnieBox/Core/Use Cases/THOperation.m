//
//  THOperation.m
//  Thoughts
//
//  Created by Daniel García García on 16/1/15.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "THOperation.h"

@implementation THOperation{
    BOOL _isExecuting;
    BOOL _isFinished;
    BOOL _isConcurrent;
    BOOL _isCanceled;
}
#pragma mark - NSOperation
- (BOOL)isConcurrent{
    return YES;
}
- (void)start{
    if (_isCanceled) {
        [self finish];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}
- (BOOL)isExecuting{
    return _isExecuting;
}
- (void)cancel{
    [self willChangeValueForKey: @"isExecuting"];
    [self willChangeValueForKey:@"isCanceled"];
    _isExecuting = NO;
    _isCanceled = YES;
    [self didChangeValueForKey:@"isCanceled"];
    [self didChangeValueForKey: @"isExecuting"];
}
- (BOOL)isCancelled{
    return _isCanceled;
}
- (void)finish {
    [self willChangeValueForKey: @"isExecuting"];
    [self willChangeValueForKey: @"isFinished"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey: @"isFinished"];
    [self didChangeValueForKey: @"isExecuting"];
}
- (BOOL)isFinished{
    return _isFinished;
}
@end

