//
//  ViewController.m
//  my二维码
//
//  Created by jacky on 15/11/26.
//  Copyright © 2015年 jacky. All rights reserved.
//

#import "ViewController.h"
#import "codeCreateController.h"
#import <AVFoundation/AVFoundation.h>

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define microWindow CGRectMake((screenHeight-200)*0.5, (screenWidth-200)*0.5, 200, 200)

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,weak) AVCaptureMetadataOutput *output;

//文件导入得到的图片
@property (nonatomic,strong) UIImage *fileImage;

//非网页弹出文本页面
@property (nonatomic,weak) UITextView *tView;

//退出按钮
@property (nonatomic,strong) UIButton *exitBtn;
//从文件导入按钮
@property (nonatomic,strong) UIButton *fileBtn;
//遮罩按钮
@property (nonatomic,strong) UIButton *shadowBtn;
//跳转生成二维码按钮
@property (nonatomic,strong) UIButton *jumpBtn;

//存储播放动画layer的数组
@property (nonatomic,strong) NSMutableArray *layerArr;

//存储的shadowlayer
@property (nonatomic,weak) CAShapeLayer *top;
@property (nonatomic,weak) CAShapeLayer *left;
@property (nonatomic,weak) CAShapeLayer *right;
@property (nonatomic,weak) CAShapeLayer *bottom;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupDevice];
    
    [self setupSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //隐藏navigationBar
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - 创建摄像头
- (void)setupDevice{
    //创建摄像头
    AVCaptureDevice *capDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //输入
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:capDevice error:nil];
    
    //创建会话
    _session = [[AVCaptureSession alloc] init];
    
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    
    //预览视图
    AVCaptureVideoPreviewLayer *preView = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    preView.frame = self.view.bounds;
    [self.view.layer addSublayer:preView];
    
    //输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([_session canAddOutput:output]) {
        [_session addOutput:output];
    }
    self.output = output;
    
//    NSArray *arrTypes = output.availableMetadataObjectTypes;
//    NSLog(@"%@",arrTypes);
    
    output.metadataObjectTypes = @[@"org.iso.QRCode"];
    
    [_session startRunning];
}

#pragma mark - 布局子控件
/**
 * 布局子控件
 */
- (void)setupSubviews{
    //添加退出按钮
    [self setupExitBtn];
    //遮罩
    [self setupShadowBtn];
    //跳转
    [self setupJumpBtn];
    //文件按钮
    [self setupFileBtn];
    
    //约束
    [self setupConstraints];
    
}

/**
 * 文件导入按钮
 */
- (void)setupFileBtn{
    self.fileBtn.backgroundColor = [UIColor greenColor];
    
    [self.fileBtn setTitle:@"从文件导入" forState:UIControlStateNormal];
    [self.fileBtn addTarget:self action:@selector(openFileFromPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.fileBtn];
    
}

/**
 * 退出按钮
 */
- (void)setupExitBtn{
    
    self.exitBtn.backgroundColor = [UIColor grayColor];
    [self.exitBtn setTitle:@"退出" forState:UIControlStateNormal];
    [self.exitBtn addTarget:self action:@selector(appExit) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.exitBtn];
}
/**
 * 遮罩按钮
 */
- (void)setupShadowBtn{
    
    [self.shadowBtn addTarget:self action:@selector(shadowBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.shadowBtn setBackgroundImage:[UIImage imageNamed:@"shadow_normal_"] forState:UIControlStateNormal];
    [self.shadowBtn setBackgroundImage:[UIImage imageNamed:@"shadow_hightlighted_"] forState:UIControlStateSelected];
    
    [self.view addSubview:self.shadowBtn];
}
/**
 * 跳转按钮
 */
- (void)setupJumpBtn{
    
    [self.jumpBtn setBackgroundImage:[UIImage imageNamed:@"jump_normal"] forState:UIControlStateNormal];
    
    [self.jumpBtn addTarget:self action:@selector(jumpToCreateController) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.jumpBtn];
}

/**
 * 设置约束
 */
- (void)setupConstraints{
    //解除约束限制
    self.shadowBtn.translatesAutoresizingMaskIntoConstraints = false;
    self.jumpBtn.translatesAutoresizingMaskIntoConstraints = false;
    self.exitBtn.translatesAutoresizingMaskIntoConstraints = false;
    self.fileBtn.translatesAutoresizingMaskIntoConstraints = false;
    
    //约束
    //遮罩
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    //跳转
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.jumpBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.jumpBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.jumpBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.jumpBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    //退出
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exitBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.shadowBtn attribute:NSLayoutAttributeRight multiplier:1 constant:30]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exitBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.shadowBtn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exitBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exitBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.jumpBtn attribute:NSLayoutAttributeLeft multiplier:1 constant:-30]];
    //文件导入按钮
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fileBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.exitBtn attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fileBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.exitBtn attribute:NSLayoutAttributeTop multiplier:1 constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fileBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.exitBtn attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fileBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.exitBtn attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}


#pragma mark - 摄像头回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    AVMetadataMachineReadableCodeObject *code = metadataObjects.lastObject;
    
    NSLog(@"code = %@",code.stringValue);
    
    [self checkQRcode:code.stringValue];
    
    [_session stopRunning];
}


#pragma mark - 响应事件

/**
 * 屏幕点击事件
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if (self.tView != nil) {
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.tView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.tView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                self.tView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.tView removeFromSuperview];
                self.tView = nil;
                self.view.userInteractionEnabled = YES;
                //如果没有扫描，则开始扫描
                if (![_session isRunning]) {
                    [_session startRunning];
                }
            }];
        }];
    }else{
        if (![_session isRunning]) {
            [_session startRunning];
        }
    }
    
//    NSLog(@"self.tView = %@" , self.tView);
}

/**
 * 遮罩按钮事件
 */
- (void)shadowBtnClick{
    
    
    if (!self.shadowBtn.selected) { //未被选中状态，添加阴影
        [self shadowInRect:microWindow];
        
        CGRect rect = microWindow;
        
        //改变扫描范围
        CGFloat x = ((screenWidth - rect.size.width)*0.5)/ screenWidth;
        CGFloat y = rect.origin.y / screenHeight;
        CGFloat width = rect.size.width / screenWidth;
        CGFloat height = rect.size.height / screenHeight;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.output.rectOfInterest =  CGRectMake(y , x, height, width);
        });
        
        NSLog(@"rect = %@",NSStringFromCGRect(rect));
        
        NSLog(@"(%f,%f,%f,%f)",y,x,height,width);
        
        [self.view bringSubviewToFront:self.shadowBtn];
        [self.view bringSubviewToFront:self.exitBtn];
        [self.view bringSubviewToFront:self.jumpBtn];
        [self.view bringSubviewToFront:self.fileBtn];
    }else{//取消选中，移除阴影
        [self removeShadow];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.output.rectOfInterest = CGRectMake(0, 0, 1, 1);
            
        });
        
    }
    self.shadowBtn.selected = !self.shadowBtn.selected;
}

/**
 * 文件导入
 */
- (void)openFileFromPhoto{
    [self.session stopRunning];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/**
 * 添加遮罩
 */
- (void)shadowInRect:(CGRect)rect{
    CGFloat leftWidth = (screenWidth - rect.size.width) / 2;
    
    CAShapeLayer* layerTop   = [[CAShapeLayer alloc] init];
    layerTop.fillColor       = [UIColor blackColor].CGColor;
    layerTop.opacity         = 0.5;
    layerTop.path            = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, screenWidth, rect.origin.y)].CGPath;
    [self.view.layer addSublayer:layerTop];
    
    CAShapeLayer* layerLeft   = [[CAShapeLayer alloc] init];
    layerLeft.fillColor       = [UIColor blackColor].CGColor;
    layerLeft.opacity         = 0.5;
    layerLeft.path            = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.origin.y, leftWidth, rect.size.height)].CGPath;
    [self.view.layer addSublayer:layerLeft];
    
    CAShapeLayer* layerRight   = [[CAShapeLayer alloc] init];
    layerRight.fillColor       = [UIColor blackColor].CGColor;
    layerRight.opacity         = 0.5;
    layerRight.path            = [UIBezierPath bezierPathWithRect:CGRectMake(screenWidth - leftWidth, rect.origin.y, rect.size.width, rect.size.height)].CGPath;
    [self.view.layer addSublayer:layerRight];
    
    CAShapeLayer* layerBottom   = [[CAShapeLayer alloc] init];
    layerBottom.fillColor       = [UIColor blackColor].CGColor;
    layerBottom.opacity         = 0.5;
    layerBottom.path            = [UIBezierPath bezierPathWithRect:CGRectMake(0, CGRectGetMaxY(rect), screenWidth, screenHeight - CGRectGetMaxY(rect))].CGPath;
    [self.view.layer addSublayer:layerBottom];
    
    [self.layerArr addObjectsFromArray:@[layerTop,layerLeft,layerBottom,layerRight]];
    
    CAMediaTimingFunction *mTime = [CAMediaTimingFunction functionWithControlPoints:0 :0 :-0.1 :1];
    
    //动画
    [layerTop addAnimation:[self shadowAnimationFrom:CGPointMake(0, -rect.origin.y) to:CGPointZero mediaTime:mTime duration:.5 stateAvailable:false] forKey:nil];
    
    [layerBottom addAnimation:[self shadowAnimationFrom:CGPointMake(0, screenHeight - CGRectGetMaxY(rect)) to:CGPointZero mediaTime:mTime duration:.5 stateAvailable:false] forKey:nil];
    
    [layerLeft addAnimation:[self shadowAnimationFrom:CGPointMake(-leftWidth, 0) to:CGPointZero mediaTime:mTime duration:.5 stateAvailable:false] forKey:nil];
    
    [layerRight addAnimation:[self shadowAnimationFrom:CGPointMake(leftWidth, 0) to:CGPointZero mediaTime:mTime duration:.5 stateAvailable:false] forKey:nil];
    
    self.top = layerTop;
    self.left = layerLeft;
    self.right = layerRight;
    self.bottom = layerBottom;
    
}

/**
 * 移除阴影
 */
- (void)removeShadow{
    
    self.shadowBtn.userInteractionEnabled = false;
    
    CAMediaTimingFunction *mediaTime = [CAMediaTimingFunction functionWithControlPoints:1.1 : 0: 1 :1 ];
    
    CGRect rect = microWindow;
    CGFloat rightWidth = (screenWidth - rect.size.width) / 2;
    CGFloat bottomHeight = (screenHeight - CGRectGetMaxY(rect));
    
    [self.top addAnimation:[self shadowAnimationFrom:CGPointZero to:CGPointMake(0, - rect.origin.y) mediaTime:mediaTime duration:0.7 stateAvailable:true] forKey:nil];
    [self.left addAnimation:[self shadowAnimationFrom:CGPointZero to:CGPointMake(- rightWidth,0) mediaTime:mediaTime duration:0.7 stateAvailable:true] forKey:nil];
    [self.right addAnimation:[self shadowAnimationFrom:CGPointZero to:CGPointMake(rightWidth,0) mediaTime:mediaTime duration:0.7 stateAvailable:true] forKey:nil];
    [self.bottom addAnimation:[self shadowAnimationFrom:CGPointZero to:CGPointMake(0, bottomHeight) mediaTime:mediaTime duration:0.7 stateAvailable:true] forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (CAShapeLayer *layer in self.layerArr) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
        [self.layerArr removeAllObjects];
        self.shadowBtn.userInteractionEnabled = true;
    });
}

/**
 * 快速添加动画
 */
- (CABasicAnimation *)shadowAnimationFrom:(CGPoint)from to:(CGPoint)to mediaTime:(CAMediaTimingFunction*)mTime duration:(CGFloat)duration stateAvailable:(BOOL)available{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:from];
    anim.toValue = [NSValue valueWithCGPoint:to];
    anim.timingFunction = mTime;
    anim.duration = duration;
    
    if (available) {
        anim.removedOnCompletion = false;
        anim.fillMode = kCAFillModeForwards;
    }
    
    return anim;
}

/**
 * 跳转控制器
 */
- (void)jumpToCreateController{
    
    [self.navigationController pushViewController:[[codeCreateController alloc] init] animated:YES];
}


/**
 * 退出应用
 */
- (void)appExit{
    exit(0);
}

/**
 * 将二维码图片转化为字符
 */
- (NSString *)stringFromFileImage:(UIImage *)img{
    CIImage *cImg = [CIImage imageWithCGImage:img.CGImage];
    CIDetector *det = [CIDetector detectorOfType:@"CIDetectorTypeQRCode" context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    NSArray *arr = [det featuresInImage:cImg];
    
    CIQRCodeFeature *qrStr = arr.firstObject;
    //只返回第一个扫描到的二维码
    return qrStr.messageString;
}

/**
 * 判断二维码
 */
- (void)checkQRcode:(NSString *)str{
    
    if (str.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"找不到二维码" message:@"导入的图片里并没有找到二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([str hasPrefix:@"http"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }else{
        //弹出一个view显示二维码内容
        [self popViewWithString:str];
    }
}

#pragma mark - ImagePicker代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.fileImage = info[@"UIImagePickerControllerOriginalImage"];
}

#pragma mark - 弹出view
- (void)popViewWithString:(NSString *)str
{
    UITextView *tView = [[UITextView alloc] init];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.8;
    CGFloat height = [UIScreen mainScreen].bounds.size.height * 0.4;
    
    tView.bounds = CGRectMake(0, 0, width, height);
    tView.center = self.view.center;
    tView.backgroundColor = [UIColor whiteColor];
    tView.text = str;
    
    self.tView = tView;
    [self.view addSubview:tView];
    
    //弹出动画
    tView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5  initialSpringVelocity:0.001 options:UIViewAnimationOptionCurveLinear animations:^{
        tView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - setter方法
/**
 * 得到图片时
 */
- (void)setFileImage:(UIImage *)fileImage
{
    _fileImage = fileImage;
    
    if(_fileImage != nil){
        [self checkQRcode:[self stringFromFileImage:_fileImage]];
    }
}

#pragma mark - 懒加载
- (UIButton *)fileBtn
{
    if (_fileBtn == nil) {
        _fileBtn = [[UIButton alloc] init];
    }
    return _fileBtn;
}

- (UIButton *)exitBtn
{
    if (_exitBtn == nil) {
        _exitBtn = [[UIButton alloc] init];
    }
    return _exitBtn;
}

- (UIButton *)jumpBtn
{
    if (_jumpBtn == nil) {
        _jumpBtn = [[UIButton alloc] init];
    }
    return _jumpBtn;
}

- (UIButton *)shadowBtn
{
    if (_shadowBtn == nil) {
        _shadowBtn = [[UIButton alloc] init];
    }
    return _shadowBtn;
}

- (NSMutableArray *)layerArr
{
    if (_layerArr == nil) {
        _layerArr = [NSMutableArray array];
    }
    return _layerArr;
}

@end
