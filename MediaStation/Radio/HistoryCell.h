//
//  HistoryCell.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell {
    
    UILabel *titleArtist;
    UILabel *titleRadio;
    UILabel *lableData;
    UILabel *lableNumber;
}

@property (nonatomic,retain) IBOutlet UILabel *titleArtist;
@property (nonatomic,retain) IBOutlet UILabel *lableNumber;




@end
