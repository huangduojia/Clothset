//
//  ViewController.m
//  Clothset
//
//  Created by huang on 13-6-8.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end



@implementation ViewController


@synthesize GetPhoto,viewtest;


-(void) imagePath
{
    
}
- (void)viewDidLoad
{
    //viewtest.hidden = YES;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"finish");
    //viewtest.hidden = NO;
   // viewtest = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 240)];
    //NSString *filePath=[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
   // [self imagePath];
    //NSData *data=[NSData dataWithContentsOfFile:imagePath];
    //UIImage *image2=[UIImage imageWithData:data];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //获取沙盒位置
    // NSLog(@"%@", path);
    NSString *documentPath = [path objectAtIndex:0];  //获取document位置
    
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];  //创建图片文件夹
    
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil]; //保存图片的路径
    NSString *image_name = @"image.png";
    NSString *imagePath = [imageDocPath stringByAppendingPathComponent:image_name];
    UIImage *images=[UIImage imageWithContentsOfFile:imagePath];
    [viewtest setImage:images];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)clickbutton:(id)sender
{
	[self addPicEvent];
    
}

- (void) addPicEvent
{
	UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
		sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    //picker.wantsFullScreenLayout = YES;
   // CGAffineTransform cameraTransform = CGAffineTransformMakeScale(1.25,1.25);
   // picker.cameraViewTransform = cameraTransform;
    [self presentModalViewController:picker animated:YES];
    picker  = nil;
    //[picker release];
}
- (void)saveImage:(UIImage *)image {
    NSData *image_data;
    NSLog(@"finish");
    if (image != nil) {
        //图片显示在界面上
     //   [changeImg setBackgroundImage:image forState:UIControlStateNormal];
        
        //以下是保存文件到沙盒路径下
        //把图片转成NSData类型的数据来保存文件
       
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            image_data = UIImagePNGRepresentation(image);
        }
        else
        {
            //返回为JPEG图像。
            image_data = UIImageJPEGRepresentation(image, 1.0);
        }
        //保存
     //   [[NSFileManager defaultManager] createFileAtPath:self.imagePath contents:data attributes:nil];
        
    }
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //获取沙盒位置
   // NSLog(@"%@", path);
    NSString *documentPath = [path objectAtIndex:0];  //获取document位置

    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];  //创建图片文件夹

    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil]; //保存图片的路径
    NSString *image_name = @"image.png";
    NSString *imagePath = [imageDocPath stringByAppendingPathComponent:image_name];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:image_data attributes:nil]; //保存图片
    //关闭相册界面
   // [picker dismissModalViewControllerAnimated:YES];
    
   // NSLog(@"finish");
}
#pragma mark -
#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(saveImage:)
               withObject:image
               afterDelay:0];
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}


@end
