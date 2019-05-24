//
//  UIAlertController+OneQRCode.h
//  OneApp
//
//  Created by OneLei on 2019/5/21.
//  Copyright © 2019 onelei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (OneQRCode)
#pragma mark - Tips
+ (void)one_showTip:(NSString *)tip;

#pragma mark - ActionSheet
+ (instancetype)one_actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction *action, NSInteger index))dismissBlock;
- (void)showInView:(nullable UIView *)view;

#pragma mark - Alert
+ (instancetype)one_alertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(nullable NSArray *)buttonTitles destructiveTitle:(nullable NSString *)destructiveTitle cancelTitle:(nullable NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction *action, NSInteger index))dismissBlock;
- (void)show;

@end

NS_ASSUME_NONNULL_END
