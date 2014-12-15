//
//  FavoriteViewController.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTUITableViewZoomController.h"

@interface FavoriteViewController : TTUITableViewZoomController <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>{
    
    NSMutableArray *favorite;
    
}

@property (nonatomic,retain) NSMutableArray *favorite;


-(IBAction)edit:(id)sender;
-(IBAction)reloadFav:(id)sender;

@end
