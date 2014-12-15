//
//  CategoryRadioViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "CategoryRadioViewController.h"
#import "TBXML.h"
#import "APIDownload.h"
#import "PlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "CategoryCell.h"
#import "CategoryCellTwo.h"
#import "MPDPlayer.h"
#import "iConfigApp.h"
#import "RadioViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"


@interface CategoryRadioViewController ()

@property (nonatomic,retain) NSMutableArray *myPodcast;

@property (nonatomic,retain) NSString *urlImagez;

@end

@implementation CategoryRadioViewController
@synthesize adBanner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                              //      [UIImage imageNamed:@"back2-t"]];
    
    
	//self.title = titleYourApp;
    
    CGRect frame = CGRectMake(0, 0, 20, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:25.0f];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    label.text = titleYourApp;
  /*
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
    */
    
    ///Parce Podcast
    
    //CACHE
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    NSString *myPodcast = categoryPlaylist;
    
    
    [APIDownload downloadWithURL:myPodcast delegate:self];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                                                                            forState:UIControlStateNormal];
    
    self.cellZoomInitialAlpha = [NSNumber numberWithFloat:0.1]; //these six properties are optional. If you don't supply them defaults will be used.
    self.cellZoomAnimationDuration = [NSNumber numberWithFloat:0.8];
    self.cellZoomXScaleFactor = [NSNumber numberWithFloat:1.6];
    self.cellZoomYScaleFactor = [NSNumber numberWithFloat:1.6];
    self.cellZoomXOffset = [NSNumber numberWithFloat:0];
    self.cellZoomYOffset = [NSNumber numberWithFloat:145];
    
    [[MPDPlayer sharedInstance]aPlayer].rate = 0.0f;
    
    
    
    
}

- (void)changeSorting
{
    
    NSString *myPodcast = categoryPlaylist;
    [APIDownload downloadWithURL:myPodcast delegate:self];
    [self performSelector:@selector(updateTable) withObject:nil
               afterDelay:2];
}

- (void)updateTable
{
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)APIDownload:(APIDownload*)request {
    NSError *error;
    TBXML *tbxml = [TBXML newTBXMLWithXMLData:request.downloadData error:&error];
    if (error) {
        NSLog(@"Error parsing:%@", error.localizedDescription);
        return;
    }
    
    TBXMLElement *root = tbxml.rootXMLElement;
    if (!root) {
        NSLog(@"Error read XML");
        return;
    }
    
    TBXMLElement *channel = [TBXML childElementNamed:@"channel" parentElement:root];
    if (channel) {
        
        self.myPodcast = [NSMutableArray array];
        
        TBXMLElement *item = [TBXML childElementNamed:@"item" parentElement:channel];
        while (item) {
            TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:item];
            TBXMLElement *link = [TBXML childElementNamed:@"url" parentElement:item];
            TBXMLElement *image = [TBXML childElementNamed:@"image" parentElement:item];
            
            NSDictionary *newsItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [TBXML textForElement:title], @"title",
                                      [TBXML textForElement:link], @"link",
                                      [TBXML textForElement:image], @"image",
                                      //  [TBXML textForElement:desc], @"desc",
                                      nil];
            [self.myPodcast addObject:newsItem];
            item = [TBXML nextSiblingNamed:@"item" searchFromElement:item];
            
            
        }
    }
    
    
    
    
    [self.tableView reloadData];
    [self writeToPlist:@"mixes.plist" withData:self.myPodcast];
}

- (void)flushCache
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

- (void) writeToPlist: (NSString*)fileName withData:(NSMutableArray *)data
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [data writeToFile:finalPath atomically: YES];
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myPodcast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cellidentifier = @"DataTableCellId";
    int rs = (int) indexPath.row;
    if (rs % 2 == 0) {
        NSLog(@"Chet");
        
        
        CategoryCell *cell = (CategoryCell *) [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
        if (cell == nil) {
            
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CategoryCell" owner:self options:nil];
            cell = nib[0];
            
            NSDictionary *newsItem = [self.myPodcast objectAtIndex:indexPath.row];
            NSURL * imageURL = [NSURL URLWithString:[newsItem objectForKey:@"image"]];
            NSString *titlez = [newsItem objectForKey:@"title"];
            titlez = [titlez stringByReplacingOccurrencesOfString:@"&amp;"
                                                       withString:@"&"];
            titlez = [titlez stringByReplacingOccurrencesOfString:@"&quot;"
                                                       withString:@"\""];
            cell.title1.text =titlez;
            [cell.imgs setImageWithURL:imageURL
                      placeholderImage:[UIImage imageNamed:@"120_icon.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        }
        return cell;
        
    } else{
        
        NSLog(@"ne chet");
        
        
        CategoryCellTwo *cell = (CategoryCellTwo *) [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
        if (cell == nil) {
            
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CategoryCellTwo" owner:self options:nil];
            cell = nib[0];
            
            NSDictionary *newsItem = [self.myPodcast objectAtIndex:indexPath.row];
            NSURL * imageURL = [NSURL URLWithString:[newsItem objectForKey:@"image"]];
            NSString *titlez = [newsItem objectForKey:@"title"];
            titlez = [titlez stringByReplacingOccurrencesOfString:@"&amp;"
                                                       withString:@"&"];
            titlez = [titlez stringByReplacingOccurrencesOfString:@"&quot;"
                                                       withString:@"\""];
            cell.title1.text =titlez;
            [cell.imgs setImageWithURL:imageURL
                      placeholderImage:[UIImage imageNamed:@"120_icon.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        
        
    
            return cell;
    
        }
    
        return cell;
    }
    
    
    
   // return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"List" sender:indexPath];
    NSLog(@"tap");
   // RadioViewController *playerz = [self.storyboard instantiateViewControllerWithIdentifier:@"RadioViewController"];
    // [self.navigationController pushViewController:playerz animated:YES];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"List"])
    {
        RadioViewController *playerz = [self.storyboard instantiateViewControllerWithIdentifier:@"RadioViewController"];
        playerz = segue.destinationViewController;
      
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *linz = [_myPodcast[indexPath.row] objectForKey: @"link"];
     //   NSString *imgs = [_myPodcast[indexPath.row] objectForKey: @"image"];
        NSString *title = [_myPodcast[indexPath.row] objectForKey: @"title"];
        [[segue destinationViewController] setUrlString:linz];
        [[segue destinationViewController]setTitleRadio:title];
        //[[segue destinationViewController] setUrlImage:imgs];
        //[[segue destinationViewController] setRadioTitle:title];
        
        
     //  UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
      //  RadioViewController * dez = (RadioViewController *)[navController topViewController];
       // RadioViewController *destz = [navController topViewController];
       // dest.url = linz;
       // [dez setUrl:linz];
        
           }
}

#pragma mark GADRequest generation

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    adBanner.adUnitID = kSampleAdUnitID;
    adBanner.rootViewController = self;
   
    [adBanner loadRequest:[GADRequest request]];
    
    
    adBanner.delegate = self;
    
    
    return adBanner;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    
    return 50;
    
}


- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"Banner adapter class name: %@", bannerView.adNetworkClassName);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"Interstitial adapter class name: %@", interstitial.adNetworkClassName);
}







@end
