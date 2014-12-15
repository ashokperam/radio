//
//  MPDStartCell.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPDStartCell : UITableViewCell {
    
    UIImageView *imageCustom;
    UILabel *customLable;
}

@property(nonatomic,retain) IBOutlet UIImageView *imageCustom;
@property (nonatomic,retain) IBOutlet UILabel *customLable;

@end
