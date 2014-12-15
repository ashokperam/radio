//
//  PlayerViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "PlayerViewController.h"
#import "Reachability.h"
#import "LastFm.h"
#import "UIImageView+WebCache.h"
#import "CBAutoScrollLabel.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "iConfigApp.h"
#import <RevMobAds/RevMobAds.h>
#import "MPDPlayer.h"
#import "FSAudioStream.h"
#import "FSCheckContentTypeRequest.h"
#import "RadioChatViewController.h"
#import "ProgressHUD.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import "iConfigApp.h"
#import "userdata.h"
#import "LoginChatViewController.h"
#import "ProgressHUD.h"
#import "GADBannerView.h"
#import "GADRequest.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


@interface PlayerViewController (){
    
    NSDictionary *userinfo;
    NSMutableArray *itemz;
    
    UIBarButtonItem *buttonLogin;
    UIBarButtonItem *buttonLogout;
    
    NSArray *accounts;
	NSInteger selected;
    NSString *shareTextSocial;
    NSURL *shareUrlPlay;
    
    
}

@property (nonatomic,retain) IBOutlet UIButton *chatEnabled;

@property (nonatomic, strong)RevMobBanner *bannerWindow;
@property (nonatomic, strong)RevMobBannerView *banner;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *autoScrollLabel;
@property (nonatomic,retain) IBOutlet UILabel *titleArtist;

@end

@implementation PlayerViewController
@synthesize albumCover,coverScreen,albumArt;
@synthesize history;
@synthesize removeItem;
@synthesize backImage;
@synthesize shareText;
@synthesize a1;
@synthesize bannerBlock;
@synthesize backImagez;
@synthesize backback;
@synthesize radioTitle;
@synthesize favoritesRadio;
@synthesize dontDownload;





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    
    _adBanner.delegate = nil;
    
}


-(void)stopRadioPlayer{
    
    [_audioController stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    userinfo = nil;
	self.navigationItem.rightBarButtonItem = buttonLogin;
    
    buttonLogin = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(actionLogin)];
	buttonLogout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(actionLogout)];
    
    
    [removeItem removeObserver:self forKeyPath:@"timedMetadata"];
    self.title = self.radioTitle;
    NSString *zxc = self.urlString;
    
 
    
    NSString *newString = [[zxc componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    
    NSURL *myURL = [NSURL URLWithString:newString];
    shareUrlPlay = myURL;
    
   	if(![self connected]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@" UPS...no internet connect" message:@"Please check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
    } else {
        
       // self.playRadio.rate = 0.0;
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:myURL];
        
        [playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
        removeItem = playerItem;
      //  [[MPDPlayer sharedInstance]playWithInstance:playerItem];
        [[MPDPlayer sharedInstance]playStream:myURL];
        
     
        
        
        ///reqvest meta
        
        FSCheckContentTypeRequest *request = [[FSCheckContentTypeRequest alloc] init];
        request.url = myURL;
        request.onCompletion = ^() {
           // if (self.request.playlist) {
                // The URL is a playlist; now do something with it...
           // }
        };
        request.onFailure = ^() {
        };
        
        [request start];
       
      
       
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioStreamErrorOccurred:)
                                                 name:FSAudioStreamErrorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioStreamMetaDataAvailable:)
                                                 name:FSAudioStreamMetaDataNotification
                                               object:nil];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopMusic)
                                                 name:@"PlayPause"
                                               object:nil];
    
    
    
    
    [self Stylez];
    hidden = YES;
    
    [self checkAuthStatus];
    
    //////BANNER BlOCK
    
    GADBannerView *bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_.adUnitID = kSampleAdUnitID;
    bannerView_.rootViewController = self;
    bannerView_.delegate = self;
    [bannerView_ loadRequest:[GADRequest request]];
    [self.bannerBlock addSubview:bannerView_];

    
    [self startAnimation];
    
}

- (void)audioStreamErrorOccurred:(NSNotification *)notification
{
   // [_statusLabel setHidden:NO];
    
    NSDictionary *dict = [notification userInfo];
    int errorCode = [[dict valueForKey:FSAudioStreamNotificationKey_Error] intValue];
    
    switch (errorCode) {
        case kFsAudioStreamErrorOpen:
            shareText = @"Cannot open the audio stream";
            break;
        case kFsAudioStreamErrorStreamParse:
            shareText = @"Cannot read the audio stream";
            break;
        case kFsAudioStreamErrorNetwork:
            shareText = @"Network failed: cannot play the audio stream";
            break;
        case kFsAudioStreamErrorUnsupportedFormat:
            shareText = @"Unsupported format";
            break;
        default:
            shareText = @"Unknown error occurred";
            break;
    }
}

- (void)audioStreamMetaDataAvailable:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSDictionary *metaData = [dict valueForKey:FSAudioStreamNotificationKey_MetaData];
    
    NSMutableString *streamInfo = [[NSMutableString alloc] init];
    
    [self determineStationNameWithMetaData:metaData];
    
    if (metaData[@"MPMediaItemPropertyArtist"] &&
        metaData[@"MPMediaItemPropertyTitle"]) {
        [streamInfo appendString:metaData[@"MPMediaItemPropertyArtist"]];
        [streamInfo appendString:@" - "];
        [streamInfo appendString:metaData[@"MPMediaItemPropertyTitle"]];
    } else if (metaData[@"StreamTitle"]) {
        [streamInfo appendString:metaData[@"StreamTitle"]];
    }
    
    if (metaData[@"StreamUrl"] && [metaData[@"StreamUrl"] length] > 0) {
      //  shareText = [NSURL URLWithString:metaData[@"StreamUrl"]];
        
       
    }
    
    
    shareText = streamInfo;
    
    self.autoScrollLabel.text = streamInfo;
    self.autoScrollLabel.backgroundColor = [UIColor colorWithRed:93.0/255.0 green:56.0/255.0 blue:83.0/255.0 alpha:1.0];
    self.autoScrollLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:25.0f];
    self.autoScrollLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.autoScrollLabel.labelSpacing = 35; // distance between start and end labels
    self.autoScrollLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    self.autoScrollLabel.scrollSpeed = 30; // pixels per second
    self.autoScrollLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
    self.autoScrollLabel.fadeLength = 1.f;
    self.autoScrollLabel.scrollDirection = CBAutoScrollDirectionLeft;
    [self.autoScrollLabel observeApplicationNotifications];
    
    self.titleArtist.text = streamInfo;
    
    
    ///image parse
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    
    NSDictionary *items = [NSDictionary dictionaryWithObjectsAndKeys:
                           
                           self.radioTitle,@"station",
                           streamInfo,@"artist",
                           resultString,@"date",
                           nil];
    
    
    
    NSString *filePathDocArray = [DOCUMENTS stringByAppendingPathComponent:@"history.plist"];
    
    NSMutableArray *arrayz = [[NSMutableArray alloc]init];
    arrayz = [NSMutableArray arrayWithContentsOfFile:filePathDocArray];
    
    [arrayz addObject:items];
    
    
    NSLog(@"%@",arrayz);
    
    if(arrayz ==nil){
        
        NSLog(@"bdsm-1");
        NSMutableArray *arrayz = [[NSMutableArray alloc]init];
        [arrayz addObject:items];
        [self writeToPlist:@"history.plist" withData:arrayz];
    }
    // [array writeToFile:@"history.plist" atomically:YES];
    [arrayz writeToFile:filePathDocArray atomically: YES];
    [self writeToPlist:@"history.plist" withData:arrayz];
    
    
    
    //Start parse artist cover image lastFM
    NSArray *artustName = [NSArray alloc];
    artustName = [streamInfo componentsSeparatedByString:@" - "];
    NSString *NameA = [artustName objectAtIndex:0];
    
    
    [[LastFm sharedInstance] getInfoForArtist:NameA successHandler:^(NSDictionary *result) {
        
        NSURL *imagez = [result objectForKey:@"image"];
        NSString *newCover = [imagez absoluteString];
        NSArray *arr = [NSArray alloc];
        arr = [newCover componentsSeparatedByString:@"126/"];
        NSString *strSubStringDigNum = [arr objectAtIndex:1];
        NSString *bigImage = [NSString stringWithFormat:@"http://userserve-ak.last.fm/serve/500/%@",strSubStringDigNum];
        NSURL *image = [NSURL URLWithString:bigImage];
        
        if (strSubStringDigNum == nil) {
            
            [self.coverScreen setImage:[UIImage imageNamed:@"logoS.png"]];
            [self.backImagez setImage:[UIImage imageNamed:@"logoS.png"]];
            
            albumCover = [UIImage imageNamed:@"logoS.png"];
            albumArt  = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"logoS.png"]];
        } else {
            [self.coverScreen setImageWithURL:image placeholderImage:[UIImage imageNamed:@"logoS.png"]];
            [self.backImagez setImageWithURL:image placeholderImage:[UIImage imageNamed:@"logoS.png"]];
            
            albumCover = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
            albumArt  = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:image]]];
        }
        
        NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
        [nowPlayingInfo setObject:@"123" forKey:MPMediaItemPropertyArtist];
        [nowPlayingInfo setObject:streamInfo forKey:MPMediaItemPropertyTitle];
        [nowPlayingInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
        
    } failureHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

}

- (void)determineStationNameWithMetaData:(NSDictionary *)metaData
{
    if (metaData[@"IcecastStationName"] && [metaData[@"IcecastStationName"] length] > 0) {
      //  self.navigationController.navigationBar.topItem.title = metaData[@"IcecastStationName"];
    } else {
      //  FSPlaylistItem *playlistItem = self.audioController.currentPlaylistItem;
     //   NSString *title = playlistItem.title;
        
    //    if ([playlistItem.title length] > 0) {
      //      self.navigationController.navigationBar.topItem.title = title;
      //  } else {
            /* The last resort - use the URL as the title, if available */
          //  if (metaData[@"StreamUrl"] && [metaData[@"StreamUrl"] length] > 0) {
          //      self.navigationController.navigationBar.topItem.title = metaData[@"StreamUrl"];
         //   }
      //  }
    }
}




-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"GO BACK");
    
}

-(void)startAnimation{
    
    //ANIMATION
    
    CABasicAnimation *imageRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    imageRotation.removedOnCompletion = NO; // Do not turn back after anim. is finished
    imageRotation.fillMode = kCAFillModeForwards;
    
    imageRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/-180)];
    
    imageRotation.duration = 4;
    imageRotation.repeatCount = 9000000000;
    
    [conImg1.layer setValue:imageRotation.toValue forKey:imageRotation.keyPath];
    [conImg1.layer addAnimation:imageRotation forKey:@"imageRotation"];
    
    imageRotation.duration = 14;
    imageRotation.repeatCount = 900000000;
    
    
    [conImg2.layer setValue:imageRotation.toValue forKey:imageRotation.keyPath];
    [conImg2.layer addAnimation:imageRotation forKey:@"imageRotation"];

}

- (BOOL) connected
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.ya.ru"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL internet;
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
        internet = NO;
    } else {
        internet = YES;
    }
    return internet;
}


-(void)Stylez {
    
    [playPauseButton setShowsTouchWhenHighlighted:YES];
    control.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    hidden = YES;
  
    
}




- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change context:(void*)context {
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        AVPlayerItem* playerItem = object;
        
        
        a1 = 0;
        
        for (AVMetadataItem* metadata in playerItem.timedMetadata)
        {
            
            a1 = a1+1;
            NSLog(@"%d",a1);
            
            NSLog(@"\nkey: %@\nkeySpace: %@\ncommonKey: %@\nvalue: %@", [metadata.key description], metadata.keySpace, metadata.commonKey, metadata.stringValue);
            
            if(a1>1){   /// for read only one shoutcast data
                
                return;
            }
            
            NSString *info = [NSString stringWithFormat:@"%@", metadata.stringValue]; // Title view and parse artist name
        
            
            
            
          //  shareText = info;
            // setup the auto scroll label
         /*   self.autoScrollLabel.text = shareText;
            self.autoScrollLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            self.autoScrollLabel.labelSpacing = 35; // distance between start and end labels
            self.autoScrollLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
            self.autoScrollLabel.scrollSpeed = 30; // pixels per second
            self.autoScrollLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
            self.autoScrollLabel.fadeLength = 1.f;
            self.autoScrollLabel.scrollDirection = CBAutoScrollDirectionLeft;
            [self.autoScrollLabel observeApplicationNotifications]; */
            
            NSDate *currentTime = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
            NSString *resultString = [dateFormatter stringFromDate: currentTime];
           
            NSDictionary *items = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                                                        self.radioTitle,@"station",
                                                                        info,@"artist",
                                                                        resultString,@"date",
                                   nil];
          
            
           
            NSString *filePathDocArray = [DOCUMENTS stringByAppendingPathComponent:@"history.plist"];
            
            NSMutableArray *arrayz = [[NSMutableArray alloc]init];
            arrayz = [NSMutableArray arrayWithContentsOfFile:filePathDocArray];
            
            [arrayz addObject:items];
            
            
            NSLog(@"%@",arrayz);
            
            if(arrayz ==nil){
                
                NSLog(@"bdsm-1");
                NSMutableArray *arrayz = [[NSMutableArray alloc]init];
                [arrayz addObject:items];
                [self writeToPlist:@"history.plist" withData:arrayz];
            }
           // [array writeToFile:@"history.plist" atomically:YES];
           [arrayz writeToFile:filePathDocArray atomically: YES];
            [self writeToPlist:@"history.plist" withData:arrayz];
            
            
            
            //Start parse artist cover image lastFM
            NSArray *artustName = [NSArray alloc];
            artustName = [info componentsSeparatedByString:@" - "];
            NSString *NameA = [artustName objectAtIndex:0];
            
            
            [[LastFm sharedInstance] getInfoForArtist:NameA successHandler:^(NSDictionary *result) {
                
                NSURL *imagez = [result objectForKey:@"image"];
                NSString *newCover = [imagez absoluteString];
                NSArray *arr = [NSArray alloc];
                arr = [newCover componentsSeparatedByString:@"126/"];
                NSString *strSubStringDigNum = [arr objectAtIndex:1];
                NSString *bigImage = [NSString stringWithFormat:@"http://userserve-ak.last.fm/serve/500/%@",strSubStringDigNum];
                NSURL *image = [NSURL URLWithString:bigImage];
                
                if (strSubStringDigNum == nil) {
                    
                    [self.coverScreen setImage:[UIImage imageNamed:@"logoS.png"]];
                    [self.backImagez setImage:[UIImage imageNamed:@"logoS.png"]];
                    
                    albumCover = [UIImage imageNamed:@"logoS.png"];
                    albumArt  = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"logoS.png"]];
                } else {
                    [self.coverScreen setImageWithURL:image placeholderImage:[UIImage imageNamed:@"logoS.png"]];
                    [self.backImagez setImageWithURL:image placeholderImage:[UIImage imageNamed:@"logoS.png"]];
                   
                    albumCover = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
                    albumArt  = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:image]]];
                }
                
                NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
                [nowPlayingInfo setObject:@"123" forKey:MPMediaItemPropertyArtist];
                [nowPlayingInfo setObject:info forKey:MPMediaItemPropertyTitle];
                [nowPlayingInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
                
            } failureHandler:^(NSError *error) {
                NSLog(@"error: %@", error);
            }];
            
            
            
            
            
        }
        
        
        
        
        
    }
    
  
    
    
    
}

-(void)lableName:(NSString*)artist{
    
}



-(IBAction)playButton:(id)sender
{
    UIImage *play = [UIImage imageNamed:@"play.png"];
    UIImage *pause = [UIImage imageNamed:@"pause.png"];
    if ([playPauseButton.currentImage isEqual:pause]) {
        [[[MPDPlayer sharedInstance]aPlayer]pause];
        [[MPDPlayer sharedInstance]stopStream];
        
      
        [playPauseButton setImage:play forState:UIControlStateNormal ];
        
        [conImg1.layer removeAllAnimations];
        [conImg2.layer removeAllAnimations];
        
    } else {
       [[[MPDPlayer sharedInstance]aPlayer]play];
        [[MPDPlayer sharedInstance]playStream:shareUrlPlay];
      
        [playPauseButton setImage:pause forState:UIControlStateNormal];
        [self startAnimation];
        
        
    }
}

-(void)stopMusic{
    
    if([[[MPDPlayer sharedInstance]aPlayer]rate] == 1.0){
        [[[MPDPlayer sharedInstance]aPlayer]pause];
    }else{
        [[[MPDPlayer sharedInstance]aPlayer]play];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    hidden = YES;
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        
        
    }
    [super viewWillDisappear:animated];
    
    NSLog(@"Player out");
    
 
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)upControl:(UIGestureRecognizer*)recognizer {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelay:0.0];
    control.frame = CGRectMake(0, -150, control.frame.size.width, control.frame.size.height);
    [UIView commitAnimations];
    hidden = YES;
}

-(void)dwnControl:(UIGestureRecognizer*)recognizer {
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelay:0.0];
    control.frame = CGRectMake(0, height -100, control.frame.size.width, control.frame.size.height);
    [UIView commitAnimations];
    self.view.layer.backgroundColor = [[UIColor blackColor] CGColor];
    hidden = NO;
}

-(IBAction)share:(id)sender{
    
    NSString *text = shareText;
    NSString *textshare = [NSString stringWithFormat:@"I'm listening now %@ in app ",text];
    if (albumCover == nil) {
        albumCover = [UIImage imageNamed:@"logoS.png"];
    }
    UIImage *shareImage = albumCover;
    NSArray *items = [NSArray arrayWithObjects:textshare,shareImage, nil];
    
    UIActivityViewController *activity = [[UIActivityViewController alloc]
                                          initWithActivityItems:items
                                          applicationActivities:nil];
    
   // NSString *downTitle = [[NSString alloc]initWithFormat:@"Post send"];
    
    
   // UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:downTitle
                   //                                  message:@"successfully..."
                   //                                 delegate: self
                   //                        cancelButtonTitle:@"Ok"
                   //                        otherButtonTitles: nil];
    
  //  [alert2 show];
    
    [self presentViewController:activity animated:YES completion:nil];
}



- (void) writeToPlist: (NSString*)fileName withData:(NSMutableArray *)data
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [data writeToFile:finalPath atomically: YES];
    
}

-(IBAction)favorite:(id)sender{
    NSString *filePathDocArray = [DOCUMENTS stringByAppendingPathComponent:@"favorite.plist"];
    NSDictionary *fav = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   self.urlString,@"url",
                                              self.urlImage,@"image",
                                            self.radioTitle,@"title",
                                                            nil];
    
    NSMutableArray *arrayz = [[NSMutableArray alloc]init];
    arrayz = [NSMutableArray arrayWithContentsOfFile:filePathDocArray];
     [arrayz addObject:fav];
    if(arrayz ==nil){
        
        NSLog(@"bdsm-2");
        NSMutableArray *arrayz = [[NSMutableArray alloc]init];
        [arrayz addObject:fav];
        [self writeToPlist:@"favorite.plist" withData:arrayz];
    }
    
    [arrayz writeToFile:filePathDocArray atomically: YES];
    [self writeToPlist:@"favorite.plist" withData:arrayz];
    
    
    NSString *downTitle = [[NSString alloc]initWithFormat:@"Station added"];
    
    
    UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:downTitle
                                                     message:@"successfully..."
                                                    delegate: self
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles: nil];
    
    [alert2 show];

    
    
    
    
    
}








-(IBAction)chat:(id)sender{
    
    NSLog(@"Tap chatBtn");
    
    if (userinfo != nil)
	{
		NSString *chatroom = self.radioTitle;
		
		RadioChatViewController *nonSystemsController = [[RadioChatViewController alloc] initWith:chatroom Userinfo:userinfo];
		[self.navigationController pushViewController:nonSystemsController animated:YES];
        
		
	}
	else {
        
        [self actionLogin];
        
    }
    
    
    // else [self chooseLoginin];
}

- (void)showError:(id)message

{
	[ProgressHUD showError:message Interacton:NO];
}

- (void)checkAuthStatus

{
	[ProgressHUD show:@"Scanning Chat..." Interacton:NO];
    
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	[authClient checkAuthStatusWithBlock:^(NSError *error, FAUser *user)
     {
         if (error == nil)
         {
             [ProgressHUD dismiss];
             
             if (user != nil)
             {
                 userinfo = UserData(user.thirdPartyUserData);
                 self.navigationItem.rightBarButtonItem = buttonLogout;
                 self.chatEnabled.userInteractionEnabled = YES;
                 //[self dismissViewControllerAnimated:YES completion:nil];
             }
             else {
                 self.navigationItem.rightBarButtonItem = buttonLogin;
                 self.chatEnabled.userInteractionEnabled = NO;
             }
             
         }
         else
         {
             NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
             [self performSelectorOnMainThread:@selector(showError:) withObject:message waitUntilDone:NO];
         }
     }];
}

- (void)actionLogin

{
	
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    LoginChatViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"LoginChatViewController"];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)didFinishLogin:(NSDictionary *)Userinfo

{
	userinfo = [Userinfo copy];
	self.navigationItem.rightBarButtonItem = buttonLogout;
    self.chatEnabled.userInteractionEnabled = YES;
    
}

- (void)actionLogout

{
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	[authClient logout];
    
	userinfo = nil;
	self.navigationItem.rightBarButtonItem = buttonLogin;
}




@end