//
//  HistoryCell.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell
@synthesize titleArtist,lableNumber;

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
