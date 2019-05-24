//
//  OneQRScanView.m
//  OneApp
//
//  Created by OneLei on 2019/5/21.
//  Copyright © 2019 onelei. All rights reserved.
//

#import "OneQRScanView.h"

@implementation OneQRScanView

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setScanRect:(CGRect)scanRect {
    _scanRect = scanRect;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, bounds);
    
    [self.backgroundColor setFill];
    CGRect topRect = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetMinY(_scanRect));
    CGRect bottomRect = CGRectMake(0, CGRectGetMaxY(_scanRect), CGRectGetWidth(bounds), CGRectGetHeight(bounds) - CGRectGetMaxY(_scanRect));
    CGRect leftRect = CGRectMake(0, CGRectGetMinY(_scanRect), CGRectGetMinX(_scanRect), CGRectGetHeight(_scanRect));
    CGRect rightRect = CGRectMake(CGRectGetMaxX(_scanRect), CGRectGetMinY(_scanRect), CGRectGetWidth(bounds) - CGRectGetMaxX(_scanRect), CGRectGetHeight(_scanRect));
    
    CGContextAddRect(context, topRect);
    CGContextAddRect(context, bottomRect);
    CGContextAddRect(context, leftRect);
    CGContextAddRect(context, rightRect);
    
    CGContextFillPath(context);
}

@end
