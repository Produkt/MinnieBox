//
//  GradientColorGenerator.h
//  MinnieDisk
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradientColorGenerator : NSObject
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, assign) CGFloat lenght;

- (instancetype)initWithColors:(NSArray *)colors length:(CGFloat)length;
- (UIColor *) colorAtPosition:(CGFloat)position;
@end
