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


@synthesize GetPhoto;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)get_a_photo:(id)sender
{
    
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
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
    picker  = nil;
    //[picker release];
}
- (void)saveImage:(UIImage *)image {
	NSLog(@"finish");
}
#pragma mark -
#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(saveImage:)
               withObject:image
               afterDelay:0.5];
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}


@end
