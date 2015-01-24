//
//  UIImage+PixelColor.h
//  Thoughts
//
//  Created by Victor Baro on 12/01/2015.
//  Copyright (c) 2015 Produkt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PixelColor)
- (UIColor*) getPixelColorAtLocation:(CGPoint)point;
@end
