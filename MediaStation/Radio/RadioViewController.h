//
//  RadioViewController.h
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

@interface RadioViewController : TTUITableViewZoomController <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UISearchBarDelegate, UISearchDisplayDelegate,NSXMLParserDelegate,GADBannerViewDelegate,GADAdNetworkExtras,GADInterstitialDelegate>{
    
    NSString *podcastUrl;
    IBOutlet UISwitch *customCellOff;
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
@property (nonatomic,retain) NSMutableArray *founded;
@property (nonatomic,retain) NSDictionary *itemAll;
@property (nonatomic,retain) NSDictionary *itemFounded;


@property IBOutlet UISearchBar *searchBar;
@property(nonatomic, strong)  GADBannerView *adBanner;




@end

