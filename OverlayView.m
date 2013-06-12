//
//  ImageProcess.m
//  Clothset
//
//  Created by gavin on 13-6-12.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = [self bounds];
    CGPoint orginal;
    CGSize rectSize;
    rectSize.height = 200;
    [self savePlot:rectSize.height key:@"rectHeight"];
    rectSize.width = 200;
    [self savePlot:rectSize.width key:@"rectWidth"];
    orginal.x = bounds.origin.x + (bounds.size.width - rectSize.width) / 2.0;
    [self savePlot:orginal.x key:@"orginalX"];
    orginal.y = bounds.origin.y + (bounds.size.height - rectSize.height) / 2.0;
    [self savePlot:orginal.y key:@"orginalY"];
    CGRect cropRect;
    // 保证虚线框的位置在view的正中
    cropRect = CGRectMake(orginal.x, orginal.y, rectSize.width, rectSize.height);
    CGContextAddEllipseInRect(context, cropRect);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)savePlot:(float)plot key:(NSString *)mKey
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:mKey] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:plot] forKey:mKey];
    }
}

@end
