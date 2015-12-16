//
//  codeCreateController.m
//  my二维码
//
//  Created by jacky on 15/11/28.
//  Copyright © 2015年 jacky. All rights reserved.
//

#import "codeCreateController.h"
#import "codeImageViewController.h"

@interface codeCreateController ()

//文本框
@property (nonatomic,strong) UITextView *tView;
//生成按钮
@property (nonatomic,strong) UIButton *generateBtn;


@end

@implementation codeCreateController

- (void)loadView{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"生成二维码";
    
    [self setupSubviews];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}


#pragma mark - 布局子控件
- (void)setupSubviews{
    //文本框
    [self setupTextView];
    //按钮
    [self setupGBtn];
    
    //约束
    [self setupConstraits];
}

/**
 * 文本框
 */
- (void)setupTextView{
    self.tView.layer.borderColor = [UIColor blackColor].CGColor;
    self.tView.layer.borderWidth = 2;
    
    [self.view addSubview:self.tView];
}

/**
 * 按钮
 */
- (void)setupGBtn{
    [self.generateBtn setTitle:@"开始生成" forState:UIControlStateNormal];
    self.generateBtn.backgroundColor = [UIColor greenColor];
    [self.generateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.generateBtn addTarget:self action:@selector(startGenerateCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.generateBtn];
}

/**
 * 约束
 */
- (void)setupConstraits{
    self.tView.translatesAutoresizingMaskIntoConstraints = false;
    self.generateBtn.translatesAutoresizingMaskIntoConstraints = false;
    
    //文本框
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:250]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200]];
    //按钮
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.generateBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.tView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.generateBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tView attribute:NSLayoutAttributeBottom multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.generateBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.generateBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25]];
}

#pragma mark - 响应事件
//view点击
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/**
 * 开始生成二维码
 */
- (void)startGenerateCode
{
//    NSArray *filenames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
//    NSLog(@"%@", filenames);
    //使用系统自带的生成器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    NSData *data = [self.tView.text dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *cImage = [filter outputImage];
    CGAffineTransform scale = CGAffineTransformMakeScale(10, 10);
    CIImage *cSImage = [cImage imageByApplyingTransform:scale];
    
    //创建modal控制器，将生成的图片显示出来
    codeImageViewController *imageVC = [[codeImageViewController alloc] init];
    imageVC.image = [UIImage imageWithCIImage:cSImage];
    imageVC.originImage = cSImage;
    [self presentViewController:imageVC animated:YES completion:nil];
}

#pragma mark - 懒加载
-(UITextView *)tView
{
    if (_tView == nil) {
        _tView = [[UITextView alloc] init];
    }
    return _tView;
}

- (UIButton *)generateBtn
{
    if (_generateBtn == nil) {
        _generateBtn = [[UIButton alloc] init];
    }
    return _generateBtn;
}


@end
