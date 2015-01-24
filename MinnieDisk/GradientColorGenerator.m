//
//  GradientColorGenerator.m
//  MinnieDisk
//
//  Created by Victor Baro on 24/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import "GradientColorGenerator.h"
#import "UIImage+PixelColor.h"

@interface GradientColorGenerator ()
@property (nonatomic, assign) CGFloat lenght;
@property (nonatomic, strong) UIImage *gradientImage;
@end

@implementation GradientColorGenerator

- (instancetype)initWithColors:(NSArray *)colors length:(CGFloat)length {
    self = [super init];
    if (self) {
        _colors = colors;
        _lenght = length;
        [self generateImage];
    }
    return self;
}

- (UIColor *)colorAtPosition:(CGFloat)position {
    return [self.gradientImage getPixelColorAtLocation:CGPointMake(0, position)];
}

- (void)generateImage{
    CGRect frame = CGRectMake(0, 0, 1, self.lenght);
    UIColor *startColor = self.colors[0];
    UIColor *endColor = self.colors[1];
    
    // Create a new bitmap-based image context, and make it current.
    // This way we'll be able to draw stuff in the context and get an UIImage back from it.
    //
    CGSize size = frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // Define the "locations" of the gradient, the points where the color(s) transformation starts and ends
    //
    size_t gradientNumberOfLocations = 2;
    CGFloat gradientLocations[2] = { 0.0, 1.0 };
    
    // Get the color components out of startColor and endColor
    //
    // This is all just because I'm lazy and don't want to write the numbers myself.
    //
    CGFloat r0 = 0, g0 = 0, b0 = 0, a0 = 0;
    CGFloat r1 = 0, g1 = 0, b1 = 0, a1 = 0;
    [startColor getRed:&r0 green:&g0 blue:&b0 alpha:&a0];
    [endColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    CGFloat gradientComponents[8] = {
        r0, g0, b0, a0,
        r1, g1, b1, a1,
    };
    
    // Build a CGGradientRef structure with the values just gathered
    //
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    
    // Draw the gradient in the current context
    //
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    // Get an image from the content of the curret context
    //
    self.gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Release stuff and clean the context
    //
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
}
@end
