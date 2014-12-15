//
//  RadioPlayerCell.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioPlayerCell : UITableViewCell{
    
    UILabel *title1;
    UILabel *title2;
    UIImageView *imgs;
}

@property( nonatomic,retain) IBOutlet UILabel *title1;
@property( nonatomic,retain) IBOutlet UILabel *title2;
@property (nonatomic,retain) IBOutlet UIImageView *imgs;

@end
