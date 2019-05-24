//
//  UIAlertController+OneQRCode.m
//  OneApp
//
//  Created by OneLei on 2019/5/21.
//  Copyright © 2019 onelei. All rights reserved.
//

#import "UIAlertController+OneQRCode.h"

@implementation UIAlertController (OneQRCode)

+ (void)one_showTip:(NSString *)tip {
    if (tip.length <= 0) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:tip preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [[UIAlertController presentingVC] presentViewController:alertController animated:YES completion:nil];
}

+ (instancetype)one_actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction * _Nonnull, NSInteger))dismissBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    void (^handler)(UIAlertAction *) = ^(UIAlertAction *action){
        NSInteger index = [alertController.actions indexOfObject:action];
        if (dismissBlock) {
            dismissBlock(action, index);
        }
    };
    if (buttonTitles && buttonTitles.count > 0) {
        for (NSString *buttonTitle in buttonTitles) {
            [alertController addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:handler]];
        }
    }
    if (destructiveTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:handler]];
    }
    if (cancelTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:handler]];
    }
    return alertController;
}
- (void)showInView:(UIView *)view {
    [self show];
}

+ (instancetype)one_alertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction * _Nonnull, NSInteger))dismissBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    void (^handler)(UIAlertAction *) = ^(UIAlertAction *action){
        NSInteger index = [alertController.actions indexOfObject:action];
        if (dismissBlock) {
            dismissBlock(action, index);
        }
    };
    if (buttonTitles && buttonTitles.count > 0) {
        for (NSString *buttonTitle in buttonTitles) {
            [alertController addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:handler]];
        }
    }
    if (destructiveTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:handler]];
    }
    if (cancelTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:handler]];
    }
    return alertController;
}
- (void)show {
    [[UIAlertController presentingVC] presentViewController:self animated:YES completion:nil];
}

+ (UIViewController *)presentingVC {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

@end
