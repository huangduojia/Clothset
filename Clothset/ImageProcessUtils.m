//
//  ImageProcessUtils.m
//  Clothset
//
//  Created by gavin on 13-6-12.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "ImageProcessUtils.h"

@implementation ImageProcessUtils

+(UIImage *) cropImage:(UIImage *) image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    // 保证虚线框的位置在view的正中
    NSLog(@"%f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"orginalX"] floatValue]);
    NSLog(@"%f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"orginalY"] floatValue]);
    NSLog(@"%f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"rectWidth"] floatValue]);
    NSLog(@"%f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"rectHeight"] floatValue]);
    CGRect rect = CGRectMake([[[NSUserDefaults standardUserDefaults] objectForKey:@"orginalX"] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"orginalY"] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"rectWidth"] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"rectHeight"] floatValue]);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropImage;
}

@end
