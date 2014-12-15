//
//  PDJPlayerViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "PDJPlayerViewController.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>
#import "CBAutoScrollLabel.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import <CFNetwork/CFNetwork.h>
#import <sys/xattr.h>
#import "UserFileViewController.h"
#import "MPDPlayer.h"
#import "MBProgressHUD.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import "iConfigApp.h"
#import "userdata.h"
#import "LoginChatViewController.h"
#import "ProgressHUD.h"
#import "RadioChatViewController.h"




#define kFavoritesPlistName @"favoriteSites"
#define kRecordPlistName @"record"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define documentsFolder	   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define tempFolder	   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cache"]
#define cacheFolder [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/music"]

@interface PDJPlayerViewController (){
    
    NSDictionary *userinfo;
    NSMutableArray *itemz;
    
    UIBarButtonItem *buttonLogin;
    UIBarButtonItem *buttonLogout;
    
    NSArray *accounts;
	NSInteger selected;
    NSString *shareTextSocial;
    NSURL *shareUrlPlay;

}

@property (retain, nonatomic) IBOutlet UISlider *sliderOutlet;
@property (nonatomic, weak) IBOutlet FXBlurView *blurView;
@property (nonatomic, weak) IBOutlet FXBlurView *blurViewScreen;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *autoScrollLabel;
@property (weak, nonatomic) IBOutlet UIButton *togglePlayPause;
@property (retain, nonatomic) IBOutlet UILabel *durationOutlet;
@property (retain, nonatomic) IBOutlet UILabel *durationOutletAll;
@property (nonatomic,retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic,retain) IBOutlet UIImageView *buttomControlView;
@property (nonatomic,retain) IBOutlet UIButton *downloadBtn;
@property (nonatomic, retain) IBOutlet UIButton *stopBtn;
@property (nonatomic,retain) IBOutlet UIView *progressView;

@property (nonatomic,retain) IBOutlet UIButton *chatEnabled;
@property (nonatomic,retain) IBOutlet  UIBarButtonItem *buttonLogin;
@property (nonatomic,retain) IBOutlet UILabel *titleArtist;





@end

@implementation PDJPlayerViewController
@synthesize coverLable;
@synthesize playList;
@synthesize musicPlayer;
@synthesize counter;
@synthesize circleA;
@synthesize circleB;
@synthesize coverView;
@synthesize gestureSensor;
@synthesize albumArtz,chatRoom;
@synthesize buttonLogin;


-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL*)URL {
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

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
	// Do any additional setup after loading the view.
    
    userinfo = nil;
	self.navigationItem.rightBarButtonItem = buttonLogin;
    
    buttonLogin = [[UIBarButtonItem alloc] initWithTitle:@"Login Chat" style:UIBarButtonItemStyleBordered target:self action:@selector(actionLogin)];
	buttonLogout = [[UIBarButtonItem alloc] initWithTitle:@"Logout Chat" style:UIBarButtonItemStyleBordered target:self action:@selector(actionLogout)];
    
    //cassete animation
    
    CABasicAnimation *imageRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    imageRotation.removedOnCompletion = NO; // Do not turn back after anim. is finished
    imageRotation.fillMode = kCAFillModeForwards;
    
    imageRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/-180)];
    
    imageRotation.duration = 12;
    imageRotation.repeatCount = 900000;
    
    [circleA.layer setValue:imageRotation.toValue forKey:imageRotation.keyPath];
    [circleA.layer addAnimation:imageRotation forKey:@"imageRotation"];
    
    imageRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/-180)];
    
    imageRotation.duration = 4;
    imageRotation.repeatCount = 900000;
    
    [circleB.layer setValue:imageRotation.toValue forKey:imageRotation.keyPath];
    [circleB.layer addAnimation:imageRotation forKey:@"imageRotation"];
    
    
    
    
    ///Get the Layer of any view
    CALayer * l = [coverLable layer];
    [l setMasksToBounds:YES];
   // [l setCornerRadius:100.0];
    
    
    UIImage *thumbImage = [UIImage imageNamed:@"t-slider.png"];
    [self.sliderOutlet setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.sliderOutlet setThumbImage:thumbImage forState:UIControlStateHighlighted];
    self.blurView.blurRadius = 5;
    self.blurViewScreen.blurRadius = 5;
    
    [self readFromPlist:@"mixes-3"];
    NSDictionary *test = [playList objectAtIndex:self.row];
    
    
    NSURL *playUrl = [NSURL URLWithString:[test objectForKey:@"link"]];
    
    
    [[MPDPlayer sharedInstance]aPlayer].rate = 0.0f;
    counter = self.row;
    [self playerz:playUrl];
    
    
    NSURL *imageUrl = [NSURL URLWithString:[test objectForKey:@"image"]];
    NSString *title = [test objectForKey:@"title"];
    
    CGRect frame = CGRectMake(0, 0, 20, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:15.0f];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    label.text = title;
    chatRoom = title;
    
    [coverLable setImageWithURL:imageUrl
               placeholderImage:[UIImage imageNamed:@"logos_i.png"]];
    [_backgroundView setImageWithURL:imageUrl
                    placeholderImage:[UIImage imageNamed:@"bg2@2x.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nextTrack:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc]init];
    }
    [networkQueue reset];
    [networkQueue setShowAccurateProgress:YES];
    [networkQueue go];
    [self.progressBarDown setProgress:0];
	
    
    self.stopBtn.hidden = YES;
    self.downloadBtn.hidden = NO;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pause:)
                                                 name:@"PlayPauseW"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nextTrack:)
                                                 name:@"NextW"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prevTrack:)
                                                 name:@"PrevW"
                                               object:nil];
    
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(prevTrack:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.gestureSensor addGestureRecognizer:left];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextTrack:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.gestureSensor addGestureRecognizer:right];
    
    
    
    
    
    
}



- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    
	if (theEvent.type == UIEventTypeRemoteControl)	{
		switch(theEvent.subtype)		{
			case UIEventSubtypeRemoteControlPlay:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPauseW" object:nil];
				break;
			case UIEventSubtypeRemoteControlPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPauseW" object:nil];
				break;
			case UIEventSubtypeRemoteControlStop:
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPauseW" object:nil];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NextW" object:nil];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PrevW" object:nil];
				break;
			default:
				return;
		}
	}
}
/*
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
*/
-(void)viewDidDisappear:(BOOL)animated{
    
    //[musicPlayer pause];
    // [self.navigationController popViewControllerAnimated:YES];
}
/*
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    [super viewWillDisappear:animated];
}
*/
-(void)viewWillAppear:(BOOL)animated{
    
    counter = self.row;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSMutableArray *) readFromPlist: (NSString *)fileName {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
    
    if (fileExists) {
        playList  = [[NSMutableArray alloc] initWithContentsOfFile:finalPath];
        return playList;
    } else {
        return nil;
    }
}



-(void)playerz:(NSURL*)urlToplay{
    
    
    [[MPDPlayer sharedInstance]aPlayer].rate = 0.0f;
    self.sliderOutlet.value = 0;
    self.durationOutletAll.text = @"00:00";
    self.durationOutlet.text = @"00:00";
    
    AVURLAsset *asset = [AVURLAsset assetWithURL: urlToplay];
    Float64 duration = CMTimeGetSeconds(asset.duration);
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset: asset];
    
    
    [self.musicPlayer replaceCurrentItemWithPlayerItem:item];
    
    [[MPDPlayer sharedInstance]stopStream];  // рубим радио
    [[MPDPlayer sharedInstance]playWithURL:urlToplay];
    [self configurePlayer];
    int dtion = (int)duration;
    int currentMinsz = (int)(dtion/60);
    int currentSecz  = (int)(dtion%60);
    
    NSString *cdown = [NSString stringWithFormat:@"%02d:%02d",currentMinsz,currentSecz];
    
    self.durationOutletAll.text = cdown;
    [self.sliderOutlet setMaximumValue:dtion];
    NSDictionary *test = [playList objectAtIndex:counter];
    NSString *title = [test objectForKey:@"title"];
    
    
    
    NSURL *imageUrl = [NSURL URLWithString:[test objectForKey:@"image"]];
    
    [coverLable setImageWithURL:imageUrl
               placeholderImage:[UIImage imageNamed:@"loading.png"]];
    [_backgroundView setImageWithURL:imageUrl
                    placeholderImage:[UIImage imageNamed:@"loading.png"]];
    
    
    
    
    
    [self titleTextScroll:title];
    title = [title stringByReplacingOccurrencesOfString:@"&amp;"
                                             withString:@"&"];
    title = [title stringByReplacingOccurrencesOfString:@"&quot;"
                                             withString:@"\""];
    
    albumArtz  = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]]];
    
    NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
    [nowPlayingInfo setObject:title forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setObject:title forKey:MPMediaItemPropertyTitle];
    [nowPlayingInfo setObject:albumArtz forKey:MPMediaItemPropertyArtwork];
    
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
    
    
    
}

-(void)titleTextScroll:(NSString*)text{
    
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
    
    self.titleArtist.text = text;
}

-(void) configurePlayer {
    //7
    __block PDJPlayerViewController * weakSelf = self;
    //8
    
    musicPlayer = [[MPDPlayer sharedInstance]aPlayer];
    [self.musicPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time) {
                                                  if(!time.value) {
                                                      return;
                                                  }
                                                  
                                                  
                                                  
                                                  int currentTime = (int)((weakSelf.musicPlayer.currentTime.value)/weakSelf.musicPlayer.currentTime.timescale);
                                                  int currentMins = (int)(currentTime/60);
                                                  int currentSec  = (int)(currentTime%60);
                                                  
                                                  
                                                  
                                                  NSString * durationLabel =
                                                  [NSString stringWithFormat:@"%02d:%02d",currentMins,currentSec];
                                                  weakSelf.durationOutlet.text = durationLabel;
                                                  weakSelf.sliderOutlet.value = currentTime;
                                                  
                                                  
                                                  
                                              }];
    
    
    
}

-(IBAction)nextTrack:(id)sender{
    
    
    
    if(counter < playList.count-1){
        
        
        [[MPDPlayer sharedInstance]aPlayer].rate = 0.0f;
        
        counter = counter + 1;
        
        
        NSDictionary *test = [playList objectAtIndex:counter];
        
        
        
        
        
        NSURL *playUrl = [NSURL URLWithString:[test objectForKey:@"link"]];
        
        [self playerz:playUrl];
        
        
        [self coverAnimations];
        
        
        return;
        
        
    }
    if (counter == playList.count -1)
    {
        
        
        [[MPDPlayer sharedInstance]aPlayer].rate = 0.0f;
        
        counter = 0;
        
        NSDictionary *test = [playList objectAtIndex:counter];
        
        NSURL *playUrl = [NSURL URLWithString:[test objectForKey:@"link"]];
        
        [self playerz:playUrl];
        
    }
    
}

-(IBAction)prevTrack:(id)sender{
    
    
    if(counter >= 1){
        
        [[[MPDPlayer sharedInstance]aPlayer] pause];
        
        counter = counter - 1;
        
        
        NSDictionary *test = [playList objectAtIndex:counter];
        
        
        NSURL *playUrl = [NSURL URLWithString:[test objectForKey:@"link"]];
        
        [self playerz:playUrl];
        
        
    } else {
        
        [[[MPDPlayer sharedInstance]aPlayer] pause];
        
        counter = 0;
        
        NSDictionary *test = [playList objectAtIndex:counter];
        
        
        NSURL *playUrl = [NSURL URLWithString:[test objectForKey:@"link"]];
        
        [self playerz:playUrl];
        
    }
}

-(IBAction)pause:(id)sender{
    
    UIImage *play = [UIImage imageNamed:@"play.png"];
    UIImage *pause = [UIImage imageNamed:@"pause.png"];
    
    if ([playPauseButton.currentImage isEqual:pause]) {
        [[[MPDPlayer sharedInstance]aPlayer] pause];
        [[MPDPlayer sharedInstance]aPlayer].rate = 0.0;
        [playPauseButton setImage:play forState:UIControlStateNormal ];
        
    } else {
        [[[MPDPlayer sharedInstance]aPlayer] play];
        [[MPDPlayer sharedInstance]aPlayer].rate = 1.0;
        [playPauseButton setImage:pause forState:UIControlStateNormal];
        
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
    
    [self.musicPlayer seekToTime:CMTimeMakeWithSeconds((int)(self.sliderOutlet.value) , 1)];
    
    
    
    
    [[[MPDPlayer sharedInstance]aPlayer] play];
}

- (void)flushCache
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}


/////////////////////////////////DOWNLOAD

- (IBAction)download:(id)sender {
    
    
    self.downloadBtn.hidden = YES;
    self.stopBtn.hidden = NO;
    
    [self.progressView addSubview:self.progressBarDown];
    [self manageFile];
    ASIHTTPRequest *request;
    
    
    
    
    NSDictionary *test = [playList objectAtIndex:counter];
    NSString *url = [test objectForKey:@"link"];
    NSString *name = [test objectForKey:@"title"];
    
    
    
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *filename = [self getFileName:url];
    NSString *savePath = [cacheFolder stringByAppendingPathComponent:filename];
	NSString *tempPath = [tempFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",filename]];
    [request setDownloadDestinationPath:savePath];
    [request setTemporaryFileDownloadPath:tempPath];
    [request setUserInfo:[NSDictionary dictionaryWithObject:filename forKey:@"name"]];
    //  [request setAllowResumeForFileDownloads:_switchTest.isOn];
    [request setDownloadProgressDelegate:self.progressBarDown];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    [networkQueue addOperation:request];
    
    
    NSString *folderPath = [DOCUMENTS stringByAppendingPathComponent:@"music"];
    NSURL *pathURL= [NSURL fileURLWithPath:folderPath];
    
    
    
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    NSDictionary *siter = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:name, filename,  nil] forKeys:[NSArray arrayWithObjects:@"title", @"link",  nil]];
    [self performSelector:@selector(addOrRemoveSiter: inPlistNamed:) withObject:siter withObject:kRecordPlistName];
    
    name = [name stringByReplacingOccurrencesOfString:@"&amp;"
                                           withString:@"&"];
    name = [name stringByReplacingOccurrencesOfString:@"&quot;"
                                           withString:@"\""];
    
    NSString *downTitle = [[NSString alloc]initWithFormat:@"%@ loading",name];
    
    
    UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:downTitle
                                                     message:@"Please wait..."
                                                    delegate: self
                                           cancelButtonTitle:@"Ok?"
                                           otherButtonTitles: nil];
    
    [alert2 show];
    
    
    
    
    
    
    
}

- (IBAction)stop:(id)sender {
    for (ASIHTTPRequest *request in [networkQueue operations]) {
        [request clearDelegatesAndCancel];
        [request setDelegate: nil];
        [request setDidFinishSelector: nil];
        [self.progressBarDown setProgress:0];
        [self.progressBarDown removeFromSuperview];
        self.downloadBtn.hidden = NO;
        self.stopBtn.hidden = YES;
	}
}


-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    
    contentLengthOfFile = request.contentLength/1024.0/1024.0;
}


-(void)requestFinished:(ASIHTTPRequest *)request{
    
    NSDictionary *test = [playList objectAtIndex:counter];
    NSString *url = [test objectForKey:@"link"];
    NSString *folderPath = [DOCUMENTS stringByAppendingPathComponent:@"music"];
    NSString *filename = [self getFileName:url];
    NSString *pz=[NSString stringWithFormat:@"%@/%@",folderPath,filename];
    [self libraryFilez:pz];
    [self.view addSubview:self.progressBarDown];
    [self.progressBarDown removeFromSuperview];
    [self.progressBarDown setProgress:0];
    self.downloadBtn.hidden = NO;
    self.stopBtn.hidden = YES;
    
}

-(void)libraryFilez:(NSString*)libString{
    
    NSDictionary *protectionNone = [NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey];
    [[NSFileManager defaultManager] setAttributes:protectionNone ofItemAtPath:libString error:nil];
    
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Cache Failed:%@",cacheFolder);
}


- (void)setProgress:(float)newProgress {
    
    _progressBarDown.progress = newProgress;
    
}

- (TKProgressBarView *) progressBarDown{
	if(_progressBarDown) return _progressBarDown;
	_progressBarDown = [[TKProgressBarView alloc] initWithStyle:TKProgressBarViewStyleLong];
	_progressBarDown.center = CGPointMake(self.view.bounds.size.width/2, 0) ;
    
	return _progressBarDown;
    
}



-(void)manageFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheFolder] || ![fileManager fileExistsAtPath:tempFolder]) {
        NSError *error;
        [fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error];
        
        NSError *error2 = nil;
        [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:&error2];
    }
}


- (NSString *)getFileName:(NSString *)url{
    NSString *name = [url lastPathComponent];
    return name;
}


- (NSString *)getFileType:(NSString *)url{
    NSString *type = [url pathExtension];
    if ([type rangeOfString:@"?" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSArray *urlArray = [type componentsSeparatedByString:@"?"];
        type = [NSString stringWithFormat:@"%@",[urlArray objectAtIndex:[urlArray count]-1]];
    }
    return type;
}




- (BOOL)isSiter:(NSDictionary*)siter storedInPlistNamed:(NSString*)plistNamer {
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *filePath = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    [filePath appendString:@"/"];
    [filePath appendString:plistNamer];
    [filePath appendString:@".plist"];
    
    NSMutableDictionary *favorites;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        favorites = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    else {
        return NO;
    }
    
    BOOL inFavorties = NO;
    for (int i = 0; i < [favorites count]; i++) {
        NSDictionary *currentSite = [favorites objectForKey:[NSString stringWithFormat:@"Site%d", i]];
        if ([currentSite isEqualToDictionary:siter]) {
            inFavorties = YES;
            break;
        }
    }
    
    return inFavorties;
}

//Removes given site from plist with given name, or adds the site if it is not in plist.
- (void)addOrRemoveSiter:(NSDictionary*)siter inPlistNamed:(NSString*)plistNamer {
    
    
    
    BOOL inFavorites = [self isSiter:siter storedInPlistNamed:plistNamer];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *filePath = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    [filePath appendString:@"/"];
    [filePath appendString:plistNamer];
    [filePath appendString:@".plist"];
    
    NSMutableDictionary *favorites = [[NSMutableDictionary alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [favorites setDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:filePath]];
    }
    
    //If site is in favorites remove it and rearrange favorites
    if (inFavorites) {
        for (int i = 0; i < [favorites count]; i++) {
            NSDictionary *currentSite = [favorites objectForKey:[NSString stringWithFormat:@"Site%d", i]];
            //When site is found it is overwritten by decrementing index of other sites that come after it.
            if ([currentSite isEqualToDictionary:siter]) {
                int j = i;
                for (; j < [favorites count]-1; j++) {
                    [favorites setValue:[favorites objectForKey:[NSString stringWithFormat:@"Site%d", j+1]] forKey:[NSString stringWithFormat:@"Site%d", j]];
                }
                [favorites removeObjectForKey:[NSString stringWithFormat:@"Site%d", j]];
                break;
            }
        }
    }
    //If site is not in favorites add it as last.
    else {
        [favorites setValue:siter forKey:[NSString stringWithFormat:@"Site%lu", (unsigned long)[favorites count]]];
    }
    [favorites writeToFile:filePath atomically:YES];
    
}

-(void)coverAnimations{
    
    // CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.0];
    coverView.frame = CGRectMake(35,350, coverView.frame.size.width, coverView.frame.size.height);
    [UIView commitAnimations];
    
    [self coverAnimationGo];
}

-(void)coverAnimationGo{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelay:0.0];
    coverView.frame = CGRectMake(35,73, coverView.frame.size.width, coverView.frame.size.height);
    [UIView commitAnimations];
    
}

-(IBAction)chat:(id)sender{
    
    NSLog(@"Tap chatBtn");
    
    if (userinfo != nil)
	{
		NSString *chatroom = chatRoom;
		
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
