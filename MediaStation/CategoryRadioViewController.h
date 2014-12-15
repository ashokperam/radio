//
//  CategoryRadioViewController.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTUITableViewZoomController.h"
#import "GADBannerViewDelegate.h"
#import "GADInterstitial.h"
#import "GADAdNetworkExtras.h"
@class GADBannerView;
@class GADRequest;

@interface CategoryRadioViewController : TTUITableViewZoomController <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,GADBannerViewDelegate,GADAdNetworkExtras,GADInterstitialDelegate>{
    
    GADBannerView *adBanner;
    int frameSize;
    
}

@property(nonatomic, strong)  GADBannerView *adBanner;






@end