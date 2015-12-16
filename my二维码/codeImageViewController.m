//
//  codeImageViewController.m
//  my二维码
//
//  Created by jacky on 15/11/28.
//  Copyright © 2015年 jacky. All rights reserved.
//

#import "codeImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SVProgressHUD/SVProgressHUD.h"

@interface codeImageViewController ()

//保存按钮
@property (nonatomic,strong) UIButton *saveBtn;
//退出按钮
@property (nonatomic,strong) UIButton *exitBtn;
@property (nonatomic,weak) UIImageView *imgView;

@end

@implementation codeImageViewController

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubviews];
}

#pragma mark - 布局子控件
- (void)setupSubviews{
    //添加控件
    UIImageView *imgV = [[UIImageView alloc] initWithImage:self.image];
    self.imgView = imgV;
    
    [self.view addSubview:imgV];
    [self setupExitBtn];
    [self setupSaveBtn];
    
    //约束
    imgV.translatesAutoresizingMaskIntoConstraints = false;
    self.exitBtn.translatesAutoresizingMaskIntoConstraints = false;
    self.saveBtn.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imgV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imgV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exitBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.exitBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.saveBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imgV attribute:NSLayoutAttributeBottom multiplier:1 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.saveBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imgV attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

/**
 * 保存按钮
 */
- (void)setupSaveBtn{
    [self.saveBtn setTitle:@"保存到相册" forState:UIControlStateNormal];
    self.saveBtn.backgroundColor = [UIColor greenColor];
    [self.saveBtn addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
}

/**
 * 退出按钮
 */
- (void)setupExitBtn{
    [self.exitBtn setTitle:@"退出" forState:UIControlStateNormal];
    self.exitBtn.backgroundColor = [UIColor grayColor];
    [self.exitBtn addTarget:self action:@selector(exitClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitBtn];
}

#pragma mark - 响应事件
/**
 * 退出
 */
- (void)exitClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * 保存
 */
- (void)saveClick{
//  方法能成功，但是保存的是原始图片的大小
//    CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]];
//    
//    CGImageRef cgImg = [context createCGImage:self.originImage fromRect:[self.originImage extent]];
//    
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library writeImageToSavedPhotosAlbum:cgImg metadata:self.originImage.properties completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error == nil) {
//            NSLog(@"保存成功");
//        }else
//        {
//            NSLog(@"保存失败,Error = %@",error);
//        }
//    }];
//    
//    NSLog(@"imge = %@ ---- ciImage = %@",self.image,self.originImage);
    
    
    
    
    
    
    //该方法保存的比较清晰
    
    CGSize imgSize = self.image.size;
    
    UIGraphicsBeginImageContext(imgSize);
    [self.imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *saveImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"正在保存"];
    
    UIImageWriteToSavedPhotosAlbum(saveImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

/**
 * 保存图片回调方法
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil) {
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    }else{
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"保存失败，Error:%@",error]];
    }
}

#pragma mark - 懒加载
- (UIButton *)saveBtn
{
    if (_saveBtn == nil) {
        _saveBtn = [[UIButton alloc] init];
    }
    return _saveBtn;
}

- (UIButton *)exitBtn
{
    if (_exitBtn == nil) {
        _exitBtn = [[UIButton alloc] init];
    }
    return _exitBtn;
}


@end
