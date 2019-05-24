//
//  UIImage+OneQRCode.h
//  OneApp
//
//  Created by OneLei on 2019/5/23.
//  Copyright © 2019 onelei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (OneQRCode)

/**
 * @brief creat QRCode with info string and width
 */
+ (UIImage *)qrCodeWithInfo:(NSString *)info width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
