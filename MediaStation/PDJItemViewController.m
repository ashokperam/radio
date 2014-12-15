//
//  PDJItemViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "PDJItemViewController.h"
#import "TBXML.h"
#import "APIDownload.h"
#import "PlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "MPDStartCell.h"
#import "MPDPlayer.h"
#import "iConfigApp.h"
#import "MBProgressHUD.h"
#import "PDJPlayerViewController.h"
#import "CategoryCell.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"

@interface PDJItemViewController ()

@property (nonatomic,retain) NSMutableArray *myPodcast;

@property (nonatomic,retain) NSString *urlImagez;

@end

@implementation PDJItemViewController
@synthesize circleA,circleB;
@synthesize podcastUrl;
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
    
    
   // self.title = TitleYourApp;
    CGRect frame = CGRectMake(0, 0, 20, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:20.0f];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    label.text = self.titleRadio;
    podcastUrl = self.urlString;
    
    
    ///Parce Podcast
    
    //CACHE
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    //Link Podcast
    NSString *myPodcast = podcastUrl;
    [APIDownload downloadWithURL:myPodcast delegate:self];
    
    //Refrash tab
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
  //  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:    /// set background tableview
                                 //     [UIImage imageNamed:@"back2-t"]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                                                                            forState:UIControlStateNormal];
    
    self.cellZoomInitialAlpha = [NSNumber numberWithFloat:0.1]; //these six properties are optional. If you don't supply them defaults will be used.
    self.cellZoomAnimationDuration = [NSNumber numberWithFloat:0.8];
    self.cellZoomXScaleFactor = [NSNumber numberWithFloat:1.6];
    self.cellZoomYScaleFactor = [NSNumber numberWithFloat:1.6];
    self.cellZoomXOffset = [NSNumber numberWithFloat:0];
    self.cellZoomYOffset = [NSNumber numberWithFloat:145];
    
    
    
}

-(IBAction)refresh:(id)sender{
    
    [self changeSorting];
}

- (void)changeSorting
{
    NSString *myPodcast = podcastUrl;
    [APIDownload downloadWithURL:myPodcast delegate:self];
    [self performSelector:@selector(updateTable) withObject:nil
               afterDelay:2];
}

- (void)updateTable
{
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        // [self getContent];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        });
    });
    
    
    
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
        NSLog(@"Ошибка парсинга:%@", error.localizedDescription);
        return;
    }
    
    TBXMLElement *root = tbxml.rootXMLElement;
    if (!root) {
        NSLog(@"Ошибка чтения корня XML");
        return;
    }
    
    TBXMLElement *channel = [TBXML childElementNamed:@"channel" parentElement:root];
    if (channel) {
        
        self.myPodcast = [NSMutableArray array];
        
        TBXMLElement *item = [TBXML childElementNamed:@"item" parentElement:channel];
        while (item) {
            TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:item];
            
            TBXMLElement *link = [TBXML childElementNamed:@"media:thumbnail" parentElement:item];
            if (link == NULL){
                link =nil;
                _urlImagez = CustomUrlImageLogo;
            } else {
                
                
                _urlImagez =  [TBXML valueOfAttributeNamed:@"url" forElement:link];
                
            }
            
            
            
            
            
            TBXMLElement *linkmp = [TBXML childElementNamed:@"enclosure" parentElement:item];
            NSString *urlPlayz =  [TBXML valueOfAttributeNamed:@"url" forElement:linkmp];
            
            
            NSDictionary *newsItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [TBXML textForElement:title], @"title",
                                      urlPlayz, @"link",
                                      _urlImagez, @"image",
                                      nil];
            [self.myPodcast addObject:newsItem];
            item = [TBXML nextSiblingNamed:@"item" searchFromElement:item];
            
            
        }
    }
    
    
    
    
    [self.tableView reloadData];
    [self writeToPlist:@"mixes-3" withData:self.myPodcast];
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
    MPDStartCell *cell = (MPDStartCell *) [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"StartCellView" owner:self options:nil];
        cell = nib[0];
        
        NSDictionary *newsItem = [self.myPodcast objectAtIndex:indexPath.row];
        NSURL * imageURL = [NSURL URLWithString:[newsItem objectForKey:@"image"]];
        NSString *titlez = [newsItem objectForKey:@"title"];
        titlez = [titlez stringByReplacingOccurrencesOfString:@"&amp;"
                                                   withString:@"&"];
        titlez = [titlez stringByReplacingOccurrencesOfString:@"&quot;"
                                                   withString:@"\""];
        cell.customLable.text =titlez;
        
        
       // cell.imageCustom.layer.cornerRadius = 155; // 160 is just a guess
        cell.imageCustom.clipsToBounds = YES;
       // cell.imageCustom.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
       // cell.imageCustom.layer.borderWidth = 1.0f;
        
        [cell.imageCustom setImageWithURL:imageURL
                         placeholderImage:[UIImage imageNamed:@"loading.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"Player2" sender:indexPath];
    
    
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"Player2"])
    {
        PDJPlayerViewController *player = [self.storyboard instantiateViewControllerWithIdentifier:@"PDJPlayerViewController"];
        player = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSInteger row = indexPath.row;
        [[segue destinationViewController]setRow:(int)row];
        
    }
}



-(IBAction)stopMusic:(id)sender{
    
    [[MPDPlayer sharedInstance]aPlayer].rate = 0.0f;
}

-(IBAction)back:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
