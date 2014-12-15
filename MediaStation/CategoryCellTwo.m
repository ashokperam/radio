//
//  CategoryCellTwo.m
//  MediaStation
//
//  Created by CODERLAB on 24.04.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import "CategoryCellTwo.h"

@implementation CategoryCellTwo
@synthesize title1, title2, imgs;


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