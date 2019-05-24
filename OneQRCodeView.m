//
//  OneQRCodeView.m
//  OneApp
//
//  Created by OneLei on 2019/5/21.
//  Copyright © 2019 onelei. All rights reserved.
//

#import "OneQRCodeView.h"
#import "OneQRScanView.h"

#import "UIAlertController+OneQRCode.h"

#import <AVFoundation/AVFoundation.h>

@interface OneQRCodeView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) OneQRScanView *scanView;
@property (nonatomic, strong) UIImageView *scanRectView, *scanLineView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) CIDetector *detector;

@end

@implementation OneQRCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        
        CGFloat scanWidth = CGRectGetWidth(frame)*2/3.f;
        CGFloat topMargin = (CGRectGetHeight(frame)-scanWidth)/2.f;
        CGFloat leftMargin = (CGRectGetWidth(frame)-scanWidth)/2.f;
        CGRect scanRect = CGRectMake(leftMargin, topMargin, scanWidth, scanWidth);
        
        NSError *error;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!captureDeviceInput) {
            [UIAlertController one_showTip:error.localizedDescription];
        } else {
            // 会话的输入设备
            AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
            [captureSession addInput:captureDeviceInput];
            // 对应输出
            AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("one_capture_queue", NULL)];
            [captureSession addOutput:captureMetadataOutput];
            
            // 条形码类型
            if (![captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
                [UIAlertController one_showTip:@"摄像头不支持扫描二维码"];
            } else {
                [captureMetadataOutput setMetadataObjectTypes:captureMetadataOutput.availableMetadataObjectTypes];
            }
            
            // 设置扫描区域，默认是手机头向左的横屏坐标系（逆时针旋转90度）
            captureMetadataOutput.rectOfInterest = CGRectMake(CGRectGetMinY(scanRect)/CGRectGetHeight(self.frame),
                                                              1-CGRectGetMaxX(scanRect)/CGRectGetWidth(self.frame),
                                                              CGRectGetHeight(scanRect)/CGRectGetHeight(self.frame),
                                                              CGRectGetWidth(scanRect)/CGRectGetWidth(self.frame));
            // 将捕获的数据流展现出来
            _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
            [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [_videoPreviewLayer setFrame:self.bounds];
        }
        [self.layer addSublayer:_videoPreviewLayer];
        
        _scanView = [[OneQRScanView alloc] initWithFrame:self.bounds];
        _scanView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _scanView.scanRect = scanRect;
        [self addSubview:_scanView];
        
        _scanRectView = [[UIImageView alloc] initWithFrame:scanRect];
        _scanRectView.image = [[UIImage imageNamed:@"qrcode_scan_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
        _scanRectView.clipsToBounds = YES;
        [self addSubview:_scanRectView];
        
        _scanLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2.f, CGRectGetWidth(scanRect), 2)];
        _scanLineView.image = [UIImage imageNamed:@"qrcode_scan_line"];
        _scanLineView.contentMode = UIViewContentModeScaleToFill;
        [_scanRectView addSubview:_scanLineView];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(scanRect), CGRectGetMinY(scanRect)-16-30, CGRectGetWidth(scanRect), 30.f)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont boldSystemFontOfSize:16];
        _tipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _tipLabel.text = @"将二维码放入框内，即可自动扫描";
        [self addSubview:_tipLabel];
        
        [_videoPreviewLayer.session startRunning];
        [self lineStartScan];
    }
    return self;
}

- (void)lineStartScan {
    [self lineStopScan];
    
    CABasicAnimation *scanAnim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnim.fromValue = @(-CGRectGetHeight(_scanLineView.frame));
    scanAnim.toValue = @(-CGRectGetHeight(_scanLineView.frame)+CGRectGetHeight(_scanRectView.frame));
    
    scanAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scanAnim.repeatCount = CGFLOAT_MAX;
    scanAnim.duration = 2.f;
    [_scanLineView.layer addAnimation:scanAnim forKey:@"basic"];
}

- (void)lineStopScan {
    [_scanLineView.layer removeAllAnimations];
}

#pragma mark - NSNotificationCenter
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self startScan];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self stopScan];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 判断是否有数据，是否是二维码数据
    if (metadataObjects.count > 0) {
        __block AVMetadataMachineReadableCodeObject *result = nil;
        [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
                result = obj;
                *stop = YES;
            }
        }];
        if (!result) {
            result = [metadataObjects firstObject];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self analyseResult:result];
        });
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:10001 userInfo:@{NSLocalizedDescriptionKey:@"非二维码数据"}];
        if ([self.delegate respondsToSelector:@selector(qrCodeView:scanFailedWithError:)]) {
            [self.delegate qrCodeView:self scanFailedWithError:error];
        }
    }
}

- (void)analyseResult:(AVMetadataMachineReadableCodeObject *)result {
    NSError *error;
    if (![[result type] isEqualToString:AVMetadataObjectTypeQRCode]) {
        error = [NSError errorWithDomain:NSURLErrorDomain code:10001 userInfo:@{NSLocalizedDescriptionKey:@"非二维码数据"}];
        if ([self.delegate respondsToSelector:@selector(qrCodeView:scanFailedWithError:)]) {
            [self.delegate qrCodeView:self scanFailedWithError:error];
        }
        return;
    }
    NSString *resultStr = result.stringValue;
    if (resultStr.length <= 0) {
        error = [NSError errorWithDomain:NSURLErrorDomain code:10002 userInfo:@{NSLocalizedDescriptionKey:@"二维码数据为空"}];
        if ([self.delegate respondsToSelector:@selector(qrCodeView:scanFailedWithError:)]) {
            [self.delegate qrCodeView:self scanFailedWithError:error];
        }
        return;
    }
    // 停止扫描
    [self stopScan];
    // 震动反馈
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // 扫描成功回调
    if ([self.delegate respondsToSelector:@selector(qrCodeView:scanSuccessWithResult:)]) {
        [self.delegate qrCodeView:self scanSuccessWithResult:resultStr];
    }
}

#pragma mark - Public
- (BOOL)isScaning{
    return _videoPreviewLayer.session.isRunning;
}

- (void)startScan{
    [_videoPreviewLayer.session startRunning];
    [self lineStartScan];
}

- (void)stopScan{
    [_videoPreviewLayer.session stopRunning];
    [self lineStopScan];
}

#pragma mark - Privite
- (void)dealloc {
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
    [self stopScan];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter
- (CIDetector *)detector {
    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    }
    return _detector;
}

@end
