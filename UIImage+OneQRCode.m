//
//  UIImage+OneQRCode.m
//  OneApp
//
//  Created by OneLei on 2019/5/23.
//  Copyright © 2019 onelei. All rights reserved.
//

#import "UIImage+OneQRCode.h"

@implementation UIImage (OneQRCode)

/**
 * @brief creat QRCode with info string and width
 */
+ (UIImage *)qrCodeWithInfo:(NSString *)info width:(CGFloat)width {
    NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CGRect extent = CGRectIntegral(filter.outputImage.extent);
    CGFloat scale = MIN(width / CGRectGetWidth(extent), width / CGRectGetHeight(extent));
    // creat bitmap;
    size_t w = CGRectGetWidth(extent) * scale;
    size_t h = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, w, h, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImageRef = [context createCGImage:filter.outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImageRef);
    // save bitmap image
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bitmapRef);
    UIImage *image = [UIImage imageWithCGImage:scaledImageRef];
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImageRef);
    CGImageRelease(scaledImageRef);
    return image;
}

@end
