//
//  ViewController.m
//  Clothset
//
//  Created by huang on 13-6-8.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController ()
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@end



@implementation ViewController

@synthesize cameraButton, capturedImage, brands;

- (void)viewDidLoad
{
    //viewtest.hidden = YES;
    
    [super viewDidLoad];
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
    imageClothes = scale(originalImages, capturedImage.frame.size);
    [capturedImage setImage:imageClothes];
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
    UIImage *originalimage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *image = scale(originalimage,capturedImage.frame.size);
    [self performSelector:@selector(saveImage:)
               withObject:image
               afterDelay:0];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.imagePickerController = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
 static UIImage *ShrinkImage(UIImage *original_image,CGSize size)
 {
 CGFloat scale = [UIScreen mainScreen].scale;
 CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
 // CGColorSpaceRef colorspace = kCGColorSpaceGenericRGB;
 CGContextRef context = CGBitmapContextCreate(NULL, size.width*scale, size.height*scale, 8, 0, colorspace, kCGImageAlphaPremultipliedFirst);
 CGContextDrawImage(context, CGRectMake(0, 0, size.width*scale, size.height*scale), (__bridge CGImageRef)(original_image.CIImage));
 CGImageRef shrunken = CGBitmapContextCreateImage(context);
 UIImage *final = [UIImage imageWithCGImage:shrunken];
 CGContextRelease(context);
 CGColorSpaceRelease(colorspace);
 CGImageRelease(shrunken);
 //shrunken = nil;
 return final;
 }
 */

static UIImage *scale(UIImage *image ,CGSize size)
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
