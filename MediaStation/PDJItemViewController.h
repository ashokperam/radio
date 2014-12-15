//
//  PDJItemViewController.h
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

@interface PDJItemViewController : TTUITableViewZoomController <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,GADBannerViewDelegate,GADAdNetworkExtras,GADInterstitialDelegate>{
    
    UIImageView *circleA;
    UIImageView *circleB;
    NSString *podcastUrl;
    
    GADBannerView *adBanner;
    int frameSize;
}

@property (copy, nonatomic) NSString *urlString;
@property (copy,nonatomic) NSString *titleRadio;
@property (nonatomic,retain) NSString *podcastUrl;
@property(nonatomic, strong)  GADBannerView *adBanner;

-(IBAction)stopMusic:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)refresh:(id)sender;

@property (nonatomic,retain) IBOutlet UIImageView *circleA;
@property (nonatomic,retain) IBOutlet UIImageView *circleB;






@end