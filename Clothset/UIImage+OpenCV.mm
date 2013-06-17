//
//  UIImage+OpenCV.mm
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UIImage+OpenCV.h"

static void ProviderReleaseDataNOP(void *info, const void *data, size_t size)
{
    // Do not release memory
    return;
}



@implementation UIImage (UIImage_OpenCV)

-(cv::Mat)CVMat
{
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(cv::Mat)CVGrayscaleMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
 
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    UIImage *temp = [[UIImage alloc] initWithCVMat:cvMat];
    return temp;
}

-(id)initWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent   
    
    self = [self initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}

+(UIImage *)edgeDetect:(UIImage *)originalImage threshold:(float)threshold
{
    cv::Mat orginalImage = [originalImage CVMat];
    cv::Mat grayImage, gaussImage, cannyImage, diliateImage;
    cv::cvtColor(orginalImage, grayImage, cv::COLOR_RGB2GRAY);
    cv::Canny(grayImage, cannyImage, threshold, threshold * 3, 3);
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
    points = (CGPoint *)malloc(d.size() * sizeof(CGPoint));
    NSLog(@"%d", pointCount);
    for (int j = 0; j < pointCount; j++) {
        points[j] = CGPointMake(d[j].x, d[j].y);
    }
    UIImage *processedImage = cropImage(originalImage, points, pointCount);
    points = nil;
    return processedImage;
}

static UIImage *cropImage(UIImage *image, CGPoint *points, int pointCount)
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextAddLines(context, points, pointCount);
    CGContextClosePath(context);
    CGRect boundsRect = CGContextGetPathBoundingBox(context);
    UIGraphicsEndImageContext();

    UIGraphicsBeginImageContext(boundsRect.size);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, boundsRect.size.width, boundsRect.size.height));
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-boundsRect.origin.x, -boundsRect.origin.y);
    CGPathAddLines(path, &transform, points, pointCount);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    [image drawInRect:CGRectMake(-boundsRect.origin.x, -boundsRect.origin.y, image.size.width, image.size.height)];
    
    UIImage *cropedImage = UIGraphicsGetImageFromCurrentImageContext();
    CGPathRelease(path);
    UIGraphicsEndImageContext();
    return cropedImage;
}

@end
