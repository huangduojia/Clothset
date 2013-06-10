//
//  ViewController.h
//  Clothset
//
//  Created by huang on 13-6-8.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <sqlite3.h>


@interface ViewController : UIViewController <UIImagePickerControllerDelegate>

{
    UIButton *GetPhoto;
    UIImageView *ShotPhoto;
    UITextField *brands;
    NSString *databasepath;
    sqlite3 *clothsetDB;
    UIImage *image ;
    int note;
}


@property (nonatomic,strong)IBOutlet UIButton *GetPhoto;
@property (nonatomic,strong) IBOutlet UIImageView *ShotPhoto;
@property (nonatomic,strong) IBOutlet UITextField *brands;
static UIImage *ShrinkImage(UIImage *original_image,CGSize size);
static UIImage *scale(UIImage *image ,CGSize size);
-(IBAction)get_a_photo:(id)sender;
-(IBAction)select_to_clothset:(id)sender;
-(IBAction)textfielddoneedit:(id)sender;
-(IBAction)backgroundtap:(id)sender;
-(void) addPicEvent;

@end
