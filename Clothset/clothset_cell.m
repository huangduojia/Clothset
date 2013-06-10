//
//  clothset_cell.m
//  Clothset
//
//  Created by huang on 13-6-10.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "clothset_cell.h"

@implementation clothset_cell

@synthesize clothview,brand;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
