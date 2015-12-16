# QRCode
二维码查看和生成器 for iOS 8 以上，其余未测试，必须真机(Devices required)

###主要界面  
需要摄像头权限，一种是全屏扫描，另一种是局部扫描  
![image](https://github.com/spxvszero/QRCode/blob/master/imgIntroduce/1.png)
![image](https://github.com/spxvszero/QRCode/blob/master/imgIntroduce/2.png)
  
###扫描结果 
面对http开头的二维码，会自动跳转，其余的会显示一个窗口告知内容，实测微信和qq加好友的二维码可跳转到应用，只有qq能到对应界面，其余没有接口也就没有弄了  
(其实主要目的是方便扫一些网站的，加好友关注什么的还是老老实实用相应应用内置的二维码吧)
![image](https://github.com/spxvszero/QRCode/blob/master/imgIntroduce/3.png)  
  
###生成二维码界面  
自己看吧。。。不过记得二维码有字数限制的好像，没做  
![image](https://github.com/spxvszero/QRCode/blob/master/imgIntroduce/4.png)  
<pre><code>
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
</code></pre>
  
###预览界面与保存  
自动保存到相册中，当然需要权限  
![image](https://github.com/spxvszero/QRCode/blob/master/imgIntroduce/5.png)  
  
###保存效果  
用了好几种方法，这种保存出来的是比较好的  
![image](https://github.com/spxvszero/QRCode/blob/master/imgIntroduce/6.png) 
<pre><code>
//该方法保存的比较清晰
    
    CGSize imgSize = self.image.size;
    
    UIGraphicsBeginImageContext(imgSize);
    [self.imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *saveImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"正在保存"];
    
    UIImageWriteToSavedPhotosAlbum(saveImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
</code></pre>
  
###文件导入  
顾名思义就是从文件中导入二维码，没测试过多个二维码的情况。。。图片不存在二维码会提示  
<pre><code>
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
</code></pre>


