//
//  ViewController.h
//  Clothset
//
//  Created by huang on 13-6-8.
//  Copyright (c) 2013年 huang. All rights reserved.
//


#import "opencv2/opencv.hpp"
#import <vector>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <sqlite3.h>
#import "UIImage+OpenCV.h"
#import <CoreImage/CIFilter.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

{
    UIButton *captureImageButton;
    UIImageView *capturedImage;
    UITextField *brands;
    NSString *databasepath;
    sqlite3 *clothsetDB;
    UIImage *imageClothes;
    int note;
    UISlider *myslider;
    UISlider *myslider2;
}

@property (nonatomic,strong) IBOutlet UIImageView *capturedImage;
@property (strong,nonatomic) IBOutlet UIButton *cameraButton;
@property (nonatomic,strong) IBOutlet UITextField *brands;
@property (nonatomic,strong) IBOutlet UISlider *myslider;
@property (nonatomic,strong) IBOutlet UISlider *myslider2;
//static UIImage *shrinkImage(UIImage *original_image,CGSize size);
static UIImage *scale(UIImage *image, CGSize size);
static UIImage *cropImage(UIImage *image, CGPoint *points, int pointCount);
-(IBAction)takePhoto:(id)sender;
-(IBAction)cancelPhoto:(id)sender;
-(IBAction)toCaptureImage:(id)sender;
-(IBAction)enterClothset:(id)sender;
-(IBAction)textFieldEditDone:(id)sender;
-(IBAction)backgroundtap:(id)sender;
-(void) addPicEvent;
- (IBAction)sliderChanged:(id)sender;

@end
