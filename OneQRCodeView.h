//
//  OneQRCodeView.h
//  OneApp
//
//  Created by OneLei on 2019/5/21.
//  Copyright © 2019 onelei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OneQRCodeView;

@protocol OneQRCodeViewDelegate <NSObject>
@optional
- (void)qrCodeView:(OneQRCodeView *)qrcodeView scanFailedWithError:(NSError *)error;
- (void)qrCodeView:(OneQRCodeView *)qrCodeView scanSuccessWithResult:(NSString *)result;
@end

@interface OneQRCodeView : UIView

@property (nonatomic, weak) id <OneQRCodeViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
