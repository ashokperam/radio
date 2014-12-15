//
//  PDJPodcastViewController.h
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

@interface PDJPodcastViewController : TTUITableViewZoomController <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,GADBannerViewDelegate,GADAdNetworkExtras,GADInterstitialDelegate>{
    
    UIImageView *circleA;
    UIImageView *circleB;
    NSString *podcastUrl;
    NSMutableArray *founded;
    bool searching;
    NSDictionary *itemAll;
    NSDictionary *itemFounded;
    
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

@property (nonatomic,retain) NSDictionary *itemFounded;
@property(nonatomic,retain)NSDictionary *itemAll;
@property (nonatomic,retain) NSMutableArray *founded;
@property (nonatomic,retain) IBOutlet UIImageView *circleA;
@property (nonatomic,retain) IBOutlet UIImageView *circleB;
@property IBOutlet UISearchBar *searchBar;






@end

