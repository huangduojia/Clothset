//
//  ViewController.m
//  Clothset
//
//  Created by huang on 13-6-8.
//  Copyright (c) 2013年 huang. All rights reserved.
//  the new one

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController ()
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@end

const int kCannyAperture = 7;

@implementation ViewController

@synthesize cameraButton, capturedImage, brands, myslider, myslider2;

- (void)viewDidLoad
{
    //viewtest.hidden = YES;
    
    [super viewDidLoad];
    
    brands.hidden = TRUE;
    
    
    NSString *docsDir;
    NSArray *dirPaths;
    //note = 1;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    databasepath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"clothset.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:databasepath] == NO)
    {
        const char *dbpath = [databasepath UTF8String];
        if (sqlite3_open(dbpath, &clothsetDB)==SQLITE_OK)
        {
            char *errMsg;
            const char *sqlStmt = "CREATE TABLE IF NOT EXISTS CLOTHSET(ID INTEGER PRIMARY KEY AUTOINCREMENT, IMAGE BLOB, BRAND TEXT,DESCRIPTION TEXT,TYPE TEXT)";
            if (sqlite3_exec(clothsetDB, sqlStmt, NULL, NULL, &errMsg)!=SQLITE_OK) {
                NSLog(@"创建表失败\n");
            }
        }
        else
        {
            NSLog(@"创建/打开数据库失败");
        }
    }
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    // NSLog(@"finish");
    //viewtest.hidden = NO;
    // viewtest = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 240)];
    //NSString *filePath=[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    // [self imagePath];
    //NSData *data=[NSData dataWithContentsOfFile:imagePath];
    //UIImage *image2=[UIImage imageWithData:data];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //获取沙盒位置
    //  NSLog(@"%@", path);
    NSString *documentPath = [path objectAtIndex:0];  //获取document位置
    
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];  //创建图片文件夹
    
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil]; //保存图片的路径
    NSString *imageName = @"image.png";
    NSString *imagePath = [imageDocPath stringByAppendingPathComponent:imageName];
    UIImage *originalImages=[UIImage imageWithContentsOfFile:imagePath];
    //UIImage *image = ShrinkImage(original_images, capturedImage.frame.size);
//    imageClothes = scale(originalImages, capturedImage.frame.size);
  //  [capturedImage setImage:imageClothes];
    [capturedImage setImage:originalImages];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)toCaptureImage:(id)sender
{
	[self addPicEvent];
    
}

-(IBAction)textFieldEditDone:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)backgroundtap:(id)sender
{
    [brands resignFirstResponder];
}

-(IBAction)enterClothset:(id)sender
{
    if(note == 1)
    {
        sqlite3_stmt *statement;
        
        const char *dbpath = [databasepath UTF8String];
        
        if (sqlite3_open(dbpath, &clothsetDB)==SQLITE_OK) {
            
            
            NSData *imageData=UIImagePNGRepresentation(imageClothes);
            // NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO CLOTHSET(IMAGE,BRAND) VALUES(\"%@\",\"%@\")",imageData,brands.text];
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO CLOTHSET(IMAGE,BRAND) VALUES(?,?)"];
            const char *insertStmt = [insertSQL UTF8String];
            
            if (sqlite3_prepare_v2(clothsetDB, insertStmt, -1, &statement, NULL) == SQLITE_OK)
            {
                sqlite3_bind_blob(statement, 1, [imageData bytes], [imageData length], NULL);
                sqlite3_bind_text(statement, 2, [brands.text UTF8String], -1, NULL);
                if (sqlite3_step(statement)==SQLITE_DONE) {
                    // NSLog(@"保存成功") ;
                }
                else
                {
                    //    NSLog(@"保存失败") ;
                }
                sqlite3_finalize(statement);
                sqlite3_close(clothsetDB);
            }
            note = 0;
        }
    }
}



- (void) addPicEvent
{
	UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
		sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    //picker.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    //picker.wantsFullScreenLayout = YES;
    // CGAffineTransform cameraTransform = CGAffineTransformMakeScale(1.25,1.25);
    // picker.cameraViewTransform = cameraTransform;
    
    //在相机界面添加遮挡view
    imagePickerController.showsCameraControls = NO;
    [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    //设备遮挡view的背景图片
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Tshirt.png"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.overlayView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
    //跳转到相机界面
    imagePickerController.cameraOverlayView = self.overlayView;
    self.overlayView = nil;
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    imagePickerController = nil;
}

- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}

- (IBAction)cancelPhoto:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)saveImage:(UIImage *)image {
    NSData *image_data;
    //   NSLog(@"finish");
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
    note = 1;
    //关闭相册界面
    // [picker dismissModalViewControllerAnimated:YES];
    
    // NSLog(@"finish");
}

#pragma mark -
#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
   // UIImage *originalimage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *example = scale([info valueForKey:UIImagePickerControllerOriginalImage], capturedImage.frame.size);
    cv::Mat orginalImage = [example CVMat];
    cv::Mat grayImage, gaussImage, cannyImage, diliateImage;
    cv::cvtColor(orginalImage, grayImage, cv::COLOR_RGB2GRAY);
    cv::Canny(grayImage, cannyImage,
              myslider.value * kCannyAperture * kCannyAperture,
              myslider2.value * kCannyAperture * kCannyAperture,
              kCannyAperture);
    cv::GaussianBlur(cannyImage, gaussImage, cv::Size(3, 3), 0);
    cv::dilate(gaussImage, diliateImage, NULL);
    cv::Mat destiny = cv::Mat::zeros(orginalImage.rows, orginalImage.cols, CV_8UC3);
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    findContours(diliateImage, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    NSLog(@"%zd",contours.size());
    int largestIndex = 0;
    float maxArea = 0.0f;
    for (int i = 0; i < contours.size(); i++) {
        double area = fabs(cv::contourArea(cv::Mat(contours[i])));
        NSLog(@"%f", area);
        if(area > maxArea){
            maxArea = area;
            largestIndex = i;
        }
    }
    cv::Scalar color( rand()&200, rand()&0, rand()&0 );
    drawContours(destiny, contours, -1, color, CV_FILLED, 8, hierarchy);
    CGPoint *points = NULL;
    const std::vector<cv::Point> d = contours[largestIndex];
    const int pointCount = d.size();
    points = (CGPoint *)malloc(10000);
    NSLog(@"%d", pointCount);
    for (int j = 0; j < pointCount; j++) {
        points[j] = CGPointMake(d[j].x, d[j].y);
    }
    UIImage *output = cropImage(example, points, pointCount);
    [self performSelector:@selector(saveImage:)withObject:output afterDelay:0];
    // 存到照片Library
    UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.imagePickerController = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

static UIImage *scale(UIImage *image ,CGSize size)
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (IBAction)sliderChanged:(id)sender
{
    UIImage *example = [UIImage imageNamed:@"EL.jpg"];
    cv::Mat originalImage = [scale(example, capturedImage.frame.size) CVMat];
    
    cv::Mat grayImage, gaussImage, cannyImage, smoothImage, output, output_temp;
    //  cv::GaussianBlur(cvmat_originalimage,gauss_image);
    cv::cvtColor(originalImage, grayImage, cv::COLOR_RGB2GRAY);
    //   adaptiveThreshold(grayimage,output, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C,CV_THRESH_BINARY,51,5);
    //    threshold(grayimage,output, 100, 255,CV_THRESH_BINARY);
    //   UIImage *originalimage_objc = [UIImage imageWithCVMat:output];
    
    cv::Mat destiny = cv::Mat::zeros(originalImage.rows, originalImage.cols, CV_8UC3);
    cv::Canny(grayImage, cannyImage,
              myslider.value * kCannyAperture * kCannyAperture,
              myslider2.value * kCannyAperture * kCannyAperture,
              kCannyAperture);
    cvSmooth(&cannyImage, &smoothImage, CV_GAUSSIAN, 3, 0, 0, 0);
    cvDilate(&smoothImage, &output, NULL, 1);
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    findContours(output, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    //NSLog(@"%zd",contours.size());
    double maxArea = 0;
    int i = 0;
    int largestcontour = 0;
    if (contours.size() != 0) {
        
        for(; i>=0 ; i = hierarchy[i][0])
        {
         //   std::vector<std::vector<cv::Point> > approx;
         //   approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
         
         
            const std::vector<cv::Point> c = contours[i];
            double area = fabs(cv::contourArea(cv::Mat(c)));
             //   NSLog(@"%f",area);
            if( area > maxArea )
            {
                maxArea = area;
                largestcontour= i;
            }
            
        }
       // NSLog(@"%f",maxArea);
        cv::Scalar color( rand()&200, rand()&0, rand()&0 );
        //  drawContours(destiny, contours,-1, color, CV_FILLED,8,hierarchy);
      //  const std::vector<cv::Point> d = contours[largestcontour];
    //    double area2 = fabs(cv::contourArea(cv::Mat(d)));
    //    NSLog(@"%f",area2);
        drawContours(destiny, contours, -1, color, 2);
    }
    
    //   NSLog(@"%f",maxArea);
    //   NSLog(@"%D",largestcontour);
    //  cv::Scalar color( rand()&200, rand()&0, rand()&0 );
    //  drawContours(destiny, contours,-1, color, CV_FILLED,8,hierarchy);
    // drawContours(destiny, contours,-1, color, 2);
    
    //   for ( size_t i=0; i<contours.size(); ++i )
    //  {
    //      cv::Scalar color( rand()&200, rand()&0, rand()&0 );
    //       drawContours(destiny, contours, i, color, 2);
    //  Rect brect = cv::boundingRect(contours[i]);
    //   rectangle(destiny, brect,cv::Scalar(255,0,0));
    //  }
    UIImage *originalimage_objc = [UIImage imageWithCVMat:destiny];
    
    [capturedImage setImage:originalimage_objc];

}

static UIImage *cropImage(UIImage *image, CGPoint *points, int pointCount)
{
//    const int pointCount = 5;
//    CGPoint *points = malloc(sizeof(CGPoint) * pointCount);
//    points[0] = CGPointMake(160, 480);
//    points[1] = CGPointMake(320, 240);
//    points[2] = CGPointMake(480, 480);
//    points[4] = CGPointMake(200, 720);
//    points[3] = CGPointMake(440, 720);
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextAddLines(context, points, pointCount);
    CGContextClosePath(context);
    CGRect boundsRect = CGContextGetPathBoundingBox(context);
    UIGraphicsEndImageContext();
    //    CGSize cropImageSize;
    //    cropImageSize.width = [[[NSUserDefaults standardUserDefaults] objectForKey:@"rectWidth"] floatValue] * 2.0;
    //    cropImageSize.height = [[[NSUserDefaults standardUserDefaults] objectForKey:@"rectHeight"] floatValue] * 2.0;
    //    float orginalX = [[[NSUserDefaults standardUserDefaults] objectForKey:@"orginalX"] floatValue] * 2.0;
    //    float orginalY = [[[NSUserDefaults standardUserDefaults] objectForKey:@"orginalY"] floatValue] * 2.0;
    //    UIGraphicsBeginImageContext(boundsRect.size);
    //    // 让画布往反方向移动
    //    [image drawInRect:CGRectMake(-orginalX, -orginalY, image.size.width, image.size.height)];
    //    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return scaledImage;
    UIGraphicsBeginImageContext(boundsRect.size);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, boundsRect.size.width, boundsRect.size.height));
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-boundsRect.origin.x, -boundsRect.origin.y);
    CGPathAddLines(path, &transform, points, pointCount);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
//    CGContextDrawPath(context, kCGPathStroke);
    [image drawInRect:CGRectMake(-boundsRect.origin.x, -boundsRect.origin.y, image.size.width, image.size.height)];
    
    UIImage *cropedImage = UIGraphicsGetImageFromCurrentImageContext();
    CGPathRelease(path);
    UIGraphicsEndImageContext();
    return cropedImage;
}


@end
