//
//  CategoryCellTwo.h
//  MediaStation
//
//  Created by CODERLAB on 24.04.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCellTwo : UITableViewCell{
    
    UILabel *title1;
    UILabel *title2;
    UIImageView *imgs;
}

@property( nonatomic,retain) IBOutlet UILabel *title1;
@property( nonatomic,retain) IBOutlet UILabel *title2;
@property (nonatomic,retain) IBOutlet UIImageView *imgs;

@end
