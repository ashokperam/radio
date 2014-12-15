//
//  UserFileViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "UserFileViewController.h"
#import "UIImageView+WebCache.h"
#import "CBAutoScrollLabel.h"
#import "MPDPlayer.h"
#import "HistoryCell.h"




#define kFavoritesPlistName @"record"
#define kRecentsPlistName @"recentSites"
#define kMaxNumberOfRecents 20
#define musicFolder [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/music"]

@interface UserFileViewController ()

@property (retain, nonatomic) IBOutlet UISlider *sliderOutlet;
@property (nonatomic,retain) IBOutlet UIImageView *backs;
@property (retain, nonatomic) IBOutlet UILabel *durationOutlet;
@property (retain, nonatomic) IBOutlet UILabel *durationOutletAll;
@property (nonatomic,retain) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *autoScrollLabel;

@end

@implementation UserFileViewController
@synthesize favorites;
@synthesize tableView;
@synthesize numbersRow,section;
@synthesize coverLable;
@synthesize counter;
@synthesize musicPlayerLoad;
@synthesize tracks;

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.title = [NSString stringWithFormat:@"Download %d tr.",counter+1];
  //  tracks.text = [NSString stringWithFormat:@"Download %d tr.",counter+1];
    
    [self performSelector:@selector(loadFavoritesFromPlistNamed:) withObject:kFavoritesPlistName];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    UIImage *thumbImage = [UIImage imageNamed:@"t-slider.png"];
    [self.sliderOutlet setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.sliderOutlet setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEndU)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseUser)
                                                 name:@"PlayPause"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nextTrackUser)
                                                 name:@"Next"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prevTrackUser)
                                                 name:@"Prev"
                                               object:nil];
    NSLog(@"%d",counter+1);
    
    
    
}



- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    
	if (theEvent.type == UIEventTypeRemoteControl)	{
		switch(theEvent.subtype)		{
			case UIEventSubtypeRemoteControlPlay:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlStop:
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPause" object:nil];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"Next" object:nil];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"Prev" object:nil];
				break;
			default:
				return;
		}
	}
}



- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
}



-(void)playerItemDidReachEndU {
    
    [self nextTrackUser];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(loadFavoritesFromPlistNamed:) withObject:kFavoritesPlistName];
    [tableView reloadData];
   
    
    
}



- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    // [musicPlayerLoad pause];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [favorites count];
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *site = [favorites objectAtIndex:indexPath.row];
        NSString *allTitles2 = [[NSString alloc] initWithString:[site objectForKey:@"link"]];
        NSString *allTitles3 = [[NSString alloc] initWithString:[site objectForKey:@"title"]];
       
        
        NSString *docsPath1 = [NSString stringWithFormat:@"%@/Documents/music/", NSHomeDirectory()];
        
        NSString *allLink2 = [NSString stringWithFormat:@"%@%@",docsPath1,allTitles2];
        NSString *allLink3 = [NSString stringWithFormat:@"%@%@",docsPath1,allTitles3];
        
       
        
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:allLink2 error:nil];
        [fileMgr removeItemAtPath:allLink3 error:nil];
       
        
        
        [self performSelector:@selector(removeSite: fromPlistNamed:) withObject:[favorites objectAtIndex:indexPath.row] withObject:kFavoritesPlistName];
        
        
        
        [favorites removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
       // tracks.text = [NSString stringWithFormat:@"Download %d tr.",counter+1];
    }
}


- (void)tableView:(UITableView *)tableViewz didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    NSDictionary *site = [favorites objectAtIndex:indexPath.row];
    
    
    counter = (int)(indexPath.row);
    section = (int)[tableViewz numberOfRowsInSection:indexPath.section];
    
    [self performSelector:@selector(addSite: toPlistWithName:) withObject:site withObject:kRecentsPlistName];
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
    
    [self performSelector:@selector(addSite: toPlistWithName:) withObject:site withObject:kRecentsPlistName];
    NSString *linName = [[NSString alloc] initWithString:[site objectForKey:@"link"]];
    NSString *docsPath = [NSString stringWithFormat:@"%@/Documents/music/", NSHomeDirectory()];
    
    NSString *path = [docsPath stringByAppendingPathComponent:linName];
    
    NSURL *url1 = [[NSURL alloc] initFileURLWithPath: path];
    UIImage *pause = [UIImage imageNamed:@"pause.png"];
    [playPauseButton setImage:pause forState:UIControlStateNormal ];
    
    
    [self playerz:url1];
   
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableViewz cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  
    static NSString *Cellidentifier = @"DataTableCellId";
    HistoryCell *cell = (HistoryCell *) [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"HistoryCell" owner:self options:nil];
        cell = nib[0];
        NSString *titlez = [[favorites objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.titleArtist.text = titlez;
        NSString *intString = [NSString stringWithFormat:@"%d", (int)indexPath.row+1];
        cell.lableNumber.text = intString;
      
        
    }

    
    return cell;
}

- (void)loadFavoritesFromPlistNamed:(NSString*)plistName {
    
    favorites = [NSMutableArray new];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *filePath = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    [filePath appendString:@"/"];
    [filePath appendString:plistName];
    [filePath appendString:@".plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *favoriteSites = [NSDictionary dictionaryWithContentsOfFile:filePath];
        for (int i = (int)[favoriteSites count]-1; i > -1 ; i--) {
            [favorites addObject:[favoriteSites objectForKey:[NSString stringWithFormat:@"Site%d", i]]];
        }
    }
   // tracks.text = [NSString stringWithFormat:@"Download %d tr.",counter+1];
}

- (void)removeSite:(NSDictionary*)site fromPlistNamed:(NSString*)plistName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *filePath = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    [filePath appendString:@"/"];
    [filePath appendString:plistName];
    [filePath appendString:@".plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *favoriteSites = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        for (int i = 0; i < [favoriteSites count]; i++) {
            NSDictionary *currentSite = [favoriteSites objectForKey:[NSString stringWithFormat:@"Site%d", i]];
            
            //When site is found it is overwritten by decrementing index of other sites that come after it.
            if ([currentSite isEqualToDictionary:site]) {
                int j = i;
                for (; j < [favoriteSites count]-1; j++) {
                    [favoriteSites setValue:[favoriteSites objectForKey:[NSString stringWithFormat:@"Site%d", j+1]] forKey:[NSString stringWithFormat:@"Site%d", j]];
                }
                [favoriteSites removeObjectForKey:[NSString stringWithFormat:@"Site%d", j]];
                break;
            }
        }
        [favoriteSites writeToFile:filePath atomically:YES];
    }
}




- (void)addSite:(NSDictionary*)site toPlistWithName:(NSString*)plistName {
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *filePath = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    [filePath appendString:@"/"];
    [filePath appendString:plistName];
    [filePath appendString:@".plist"];
    
    NSMutableDictionary *recents = [[NSMutableDictionary alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [recents setDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:filePath]];
    }
    
    //Check if site is already in recents.
    for (int i = 0; i < [recents count]; i++) {
        NSDictionary *currentSite = [recents objectForKey:[NSString stringWithFormat:@"Site%d", i]];
        if ([currentSite isEqualToDictionary:site]) {
            
            return;
        }
    }
    
    //If recents is full delete the oldest one, and rearrange others.
    if ([recents count] == kMaxNumberOfRecents) {
        for (int i = 0; i < kMaxNumberOfRecents-1; i++) {
            [recents setValue:[recents objectForKey:[NSString stringWithFormat:@"Site%d", i+1]] forKey:[NSString stringWithFormat:@"Site%d", i]];
        }
    }
    
    //Write site to recents.
    [recents setValue:site forKey:[NSString stringWithFormat:@"Site%lu", (unsigned long)[recents count]]];
    [recents writeToFile:filePath atomically:YES];
    
}
-(void)stopMusicUser{
    
    
    self.musicPlayerLoad.rate = 0.0f;
    
}



-(void)playerz:(NSURL*)urlToplay{
    
    
    self.sliderOutlet.value = 0;
    self.durationOutletAll.text = @"00:00";
    self.durationOutlet.text = @"00:00";
    
    AVURLAsset *asset = [AVURLAsset assetWithURL: urlToplay];
    Float64 duration = CMTimeGetSeconds(asset.duration);
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset: asset];
    
    
    [self.musicPlayerLoad replaceCurrentItemWithPlayerItem:item];
    
    [[MPDPlayer sharedInstance]playWithURL:urlToplay];
    [[[MPDPlayer sharedInstance]aPlayer] addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self configurePlayer];
    
    int dtion = (int)duration;
    int ff = dtion + 0.01;
    int currentMinsz = (int)(ff/60);
    int currentSecz  = (int)(ff%60);
    
    NSString *cdown = [NSString stringWithFormat:@"%02d:%02d",currentMinsz,currentSecz];
    
    self.durationOutletAll.text = cdown;
    [self.sliderOutlet setMaximumValue:dtion];
    NSDictionary *test = [favorites objectAtIndex:counter];
    
    
    NSURL *imageUrl = [NSURL URLWithString:[test objectForKey:@"image"]];
    
    [coverLable setImageWithURL:imageUrl
               placeholderImage:[UIImage imageNamed:@"120_icon.png"]];
    [_backgroundView setImageWithURL:imageUrl
                    placeholderImage:[UIImage imageNamed:@"120_icon.png"]];
    
    NSString *title = [test objectForKey:@"title"];
    [self titleTextScroll:title];
    
    NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
    [nowPlayingInfo setObject:title forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setObject:title forKey:MPMediaItemPropertyTitle];
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
    
    
    
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == [[MPDPlayer sharedInstance]aPlayer] && [keyPath isEqualToString:@"status"]) {
        if (musicPlayerLoad.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if ([[MPDPlayer sharedInstance]aPlayer].status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayer Ready to Play");
        } else if ([[MPDPlayer sharedInstance]aPlayer].status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

-(void)titleTextScroll:(NSString*)text{
    
    
    
    // setup the auto scroll label
    text = [text stringByReplacingOccurrencesOfString:@"&amp;"
                                               withString:@"&"];
    text = [text stringByReplacingOccurrencesOfString:@"&quot;"
                                               withString:@"\""];
    
    self.autoScrollLabel.text = text;
    self.autoScrollLabel.textColor = [UIColor whiteColor];
    self.autoScrollLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:25.0f];
    self.autoScrollLabel.labelSpacing = 35; // distance between start and end labels
    self.autoScrollLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    self.autoScrollLabel.scrollSpeed = 30; // pixels per second
    self.autoScrollLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
    self.autoScrollLabel.fadeLength = 12.f;
    self.autoScrollLabel.scrollDirection = CBAutoScrollDirectionLeft;
    [self.autoScrollLabel observeApplicationNotifications];
}

-(void) configurePlayer {
    //7
    __block UserFileViewController * weakSelf = self;
    //8
    musicPlayerLoad = [[MPDPlayer sharedInstance]aPlayer];
    
    [self.musicPlayerLoad addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
     
     
                                                       queue:NULL
                                                  usingBlock:^(CMTime time) {
                                                      if(!time.value) {
                                                          return;
                                                      }
                                                      
                                                      int currentTime = (int)((weakSelf.musicPlayerLoad.currentTime.value)/weakSelf.musicPlayerLoad.currentTime.timescale);
                                                      int currentMins = (int)(currentTime/60);
                                                      int currentSec  = (int)(currentTime%60);
                                                      
                                                      NSString * durationLabel =
                                                      [NSString stringWithFormat:@"%02d:%02d",currentMins,currentSec];
                                                      weakSelf.durationOutlet.text = durationLabel;
                                                      weakSelf.sliderOutlet.value = currentTime;
                                                      
                                                      
                                                      
                                                      
                                                  }];
    
    
    
}

-(IBAction)nextTrackUser{
    
    if (section == 0) {
        return;
    } else{
    
    if(counter<= section-2){
        
        
        [[[MPDPlayer sharedInstance]aPlayer]pause];
        counter = counter + 1;
        
        
        NSDictionary *test = [favorites objectAtIndex:counter];
        
        
        
        NSString *linName = [[NSString alloc] initWithString:[test objectForKey:@"link"]];
        NSString *docsPath = [NSString stringWithFormat:@"%@/Documents/music/", NSHomeDirectory()];
        
        [self titleTextScroll:[test objectForKey:@"title"]];
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",docsPath,linName];
        
        NSURL *url = [NSURL fileURLWithPath :filePath];
        
        [self playerz:url];
        
        
    } else{
        
        
        [[[MPDPlayer sharedInstance]aPlayer]pause];
        
        counter = 0;
        
       
        NSDictionary *testa = [favorites objectAtIndex:counter];
        [self titleTextScroll:[testa objectForKey:@"title"]];
        NSString *linName = [[NSString alloc] initWithString:[testa objectForKey:@"link"]];
        NSString *docsPath = [NSString stringWithFormat:@"%@/Documents/music/", NSHomeDirectory()];
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",docsPath,linName];
        
        NSURL *url = [NSURL fileURLWithPath :filePath];
        
        
        [self playerz:url];
        
        
        
        
        
    }
    }
}

-(void)ups{
    
    
}

-(IBAction)prevTrackUser{
    
    if (section == 0) {
        return;
    } else{
    
    
    if(counter >= section - counter){
        
        [[[MPDPlayer sharedInstance]aPlayer]pause];
        counter = counter -1;
        
        
        NSDictionary *test = [favorites objectAtIndex:counter];
        [self titleTextScroll:[test objectForKey:@"title"]];
        NSString *linName = [[NSString alloc] initWithString:[test objectForKey:@"link"]];
        NSString *docsPath = [NSString stringWithFormat:@"%@/Documents/music/", NSHomeDirectory()];
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",docsPath,linName];
        
        NSURL *url = [NSURL fileURLWithPath :filePath];
        
        
        [self playerz:url];
        
    } else {
        
        [[[MPDPlayer sharedInstance]aPlayer]pause];
        
        counter = section -1;
        
       
        NSDictionary *test = [favorites objectAtIndex:counter];
        [self titleTextScroll:[test objectForKey:@"title"]];
        NSString *linName = [[NSString alloc] initWithString:[test objectForKey:@"link"]];
        NSString *docsPath = [NSString stringWithFormat:@"%@/Documents/music/", NSHomeDirectory()];
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",docsPath,linName];
        
        NSURL *url = [NSURL fileURLWithPath :filePath];
        
        
        [self playerz:url];
        
    }
  }
}

-(IBAction)pauseUser{
    
    UIImage *play = [UIImage imageNamed:@"play.png"];
    UIImage *pause = [UIImage imageNamed:@"pause.png"];
    
    if ([playPauseButton.currentImage isEqual:play]) {
        [[[MPDPlayer sharedInstance]aPlayer]play];
        [[MPDPlayer sharedInstance]aPlayer].rate = 1.0;
        [playPauseButton setImage:pause forState:UIControlStateNormal ];
        
       
    } else {
        [[[MPDPlayer sharedInstance]aPlayer] pause];
        [[MPDPlayer sharedInstance]aPlayer].rate = 0.0;
        [playPauseButton setImage:play forState:UIControlStateNormal];
        
    }
    
}

-(void)stopMusic{
    
    
    
    if([[MPDPlayer sharedInstance]aPlayer].rate == 1.0){
        [[[MPDPlayer sharedInstance]aPlayer] pause];
    }else{
        [[[MPDPlayer sharedInstance]aPlayer] play];
    }
}

-(IBAction)sliding:(UISlider *)sender{
    
    [[[MPDPlayer sharedInstance]aPlayer] pause];
    
    [self.musicPlayerLoad seekToTime:CMTimeMakeWithSeconds((int)(self.sliderOutlet.value) , 1)];
    
    [[[MPDPlayer sharedInstance]aPlayer] play];
}

- (void)flushCache
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

-(IBAction)back:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

