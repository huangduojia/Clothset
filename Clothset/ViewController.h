//
//  ViewController.h
//  Clothset
//
//  Created by huang on 13-6-8.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate>

{
    UIButton *GetPhoto;
    UIImageView *viewtest;
    
    
}


@property (nonatomic,strong)IBOutlet UIButton *GetPhoto;
@property (nonatomic,strong) IBOutlet UIImageView *viewtest;
-(IBAction)get_a_photo:(id)sender;
- (void) addPicEvent;

@end
