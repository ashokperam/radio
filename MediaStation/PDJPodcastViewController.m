//
//  PDJPodcastViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "PDJPodcastViewController.h"
#import "TBXML.h"
#import "APIDownload.h"
#import "PlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "MPDStartCell.h"
#import "MPDPlayer.h"
#import "iConfigApp.h"
#import "MBProgressHUD.h"
#import "PDJItemViewController.h"
#import "CategoryCell.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"

@interface PDJPodcastViewController ()

@property (nonatomic,retain) NSMutableArray *myPodcast;

@property (nonatomic,retain) NSString *urlImagez;

@end

@implementation PDJPodcastViewController
@synthesize circleA,circleB;
@synthesize podcastUrl;
@synthesize searchBar;
@synthesize founded;
@synthesize itemAll,itemFounded;
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
    
    
   // self.title = self.radioTitle;
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
    
   // self.tableView.backgroundView = [[UIImageView alloc] initWithImage:    /// set background tableview
                                  //   [UIImage imageNamed:@"back2-t"]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]
                                                                                            forState:UIControlStateNormal];
    
    self.cellZoomInitialAlpha = [NSNumber numberWithFloat:0.1]; //these six properties are optional. If you don't supply them defaults will be used.
    self.cellZoomAnimationDuration = [NSNumber numberWithFloat:0.8];
    self.cellZoomXScaleFactor = [NSNumber numberWithFloat:1.6];
    self.cellZoomYScaleFactor = [NSNumber numberWithFloat:1.6];
    self.cellZoomXOffset = [NSNumber numberWithFloat:0];
    self.cellZoomYOffset = [NSNumber numberWithFloat:145];
    
    
    
}

-(void) searchBar: (UISearchBar*) searchBar textDidChange: (NSString*) text
{
    
    if(text.length==0){
        
        searching = false;
        
        
        
    }else{
        
        searching = true;
        NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",text];
        NSLog(@"string :%@",Predicate);
        
        founded =[[NSMutableArray alloc]init];
        
        for (int i = 0; i < [_myPodcast count];i++ ) {
            
            NSLog(@"%d",i);
            NSArray *item = [_myPodcast objectAtIndex:i];
            NSString * foundTitle = [item valueForKey:@"title"];
            
            if ([foundTitle rangeOfString: text options: NSCaseInsensitiveSearch].location != NSNotFound)
            {
                // self.lblNoRecordsFound.hidden = YES;
                NSLog (@"Yay! '%@' found in '%@'.",foundTitle, text);
                
                [founded addObject:item];
                
                
                
                
            }
            
            
        }
        
    }
    [self.tableView reloadData];
    // self.tableView.backgroundView = [[UIImageView alloc] initWithImage:    /// set background tableview
    // [UIImage imageNamed:@"back2.jpg"]];
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
    
    
    searching = false;
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
    [self writeToPlist:@"mixes-2.plist" withData:self.myPodcast];
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
   // return self.myPodcast.count;
    if (!searching) return self.myPodcast.count;
    else return self.founded.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Cellidentifier = @"DataTableCellId";
    CategoryCell *cell = (CategoryCell *) [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CategoryCell" owner:self options:nil];
        cell = nib[0];
        
        if (!searching) {
            itemAll = [self.myPodcast objectAtIndex:indexPath.row];
        } else{
            itemAll = [self.founded objectAtIndex:indexPath.row];
        }
        
      //  NSDictionary *newsItem = [self.myPodcast objectAtIndex:indexPath.row];
        NSURL * imageURL = [NSURL URLWithString:[itemAll objectForKey:@"image"]];
        NSString *titlez = [itemAll objectForKey:@"title"];
        titlez = [titlez stringByReplacingOccurrencesOfString:@"&amp;"
                                                   withString:@"&"];
        titlez = [titlez stringByReplacingOccurrencesOfString:@"&quot;"
                                                   withString:@"\""];
        cell.title1.text =titlez;
        
        [cell.imgs setImageWithURL:imageURL
                         placeholderImage:[UIImage imageNamed:@"loading.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        
    }
    
    
    
    
    return cell;
    [tableView reloadData];
}
 




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"List3" sender:indexPath];
    NSLog(@"tap");
    // RadioViewController *playerz = [self.storyboard instantiateViewControllerWithIdentifier:@"RadioViewController"];
    // [self.navigationController pushViewController:playerz animated:YES];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"List3"])
    {
        PDJItemViewController *playerz = [self.storyboard instantiateViewControllerWithIdentifier:@"PDJItemViewController"];
        playerz = segue.destinationViewController;
        
        if(!searching){
            
        }else{
            
            _myPodcast = founded;
        }
        
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

