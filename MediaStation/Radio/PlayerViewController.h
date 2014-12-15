//
//  PlayerViewController.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "FSAudioController.h"


#import "LoginChatViewController.h"
@class FSAudioController;
#import "GADBannerView.h"

@class GADBannerView;
@class GADRequest;



@interface PlayerViewController : UIViewController <LoginChatViewControllerDelegate,GADBannerViewDelegate> {
    
    //AVPlayer *playRadio;
    AVPlayerItem *removeItem;
    NSTimer *timerix;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIButton *muteButton;
    IBOutlet UIButton *shareButton;
    IBOutlet UIView *control;
    NSString *shareText;
    BOOL hidden;
    NSString *stationUrl;
    UIImage *albumCover;
    UIImageView *coverScreen;
    MPMediaItemArtwork *albumArt;
    UIImageView *backImagez;
    int a1;
    
    NSMutableArray *history;
    
    
    IBOutlet UIImageView *setBack;
    NSString *backImage;
    UIView *bannerBlock;
    UIImageView *backback;
    NSString *radioTitle;
    
    ///favotite
    NSMutableArray *favoritesRadio;
    IBOutlet UIButton *dontDownload;
    
    UIImageView *conImg1;
    UIImageView *conImg2;
    
   
    
    FSAudioController *_audioController;
    
   
    
   
   
}

@property (nonatomic,retain) AVPlayerItem *removeItem;

@property (nonatomic,retain) IBOutlet UIImageView *backImagez;
@property (nonatomic,retain) IBOutlet UIImageView *backback;
@property (copy, nonatomic) NSString *urlString;
@property (copy, nonatomic) NSString *urlImage;
@property (strong, nonatomic) IBOutlet UIImageView *coverScreen;
@property (nonatomic,retain)  UIImage *albumCover;
@property (nonatomic,retain)  MPMediaItemArtwork *albumArt;
@property (nonatomic,retain) NSString *backImage;
@property (nonatomic,retain) NSString *shareText;
@property (nonatomic,readwrite) int a1;
//@property (nonatomic,retain) AVPlayer *playRadio;
@property (nonatomic,retain)IBOutlet UIView *bannerBlock;
@property (nonatomic,retain) NSMutableArray *history;
@property (nonatomic, copy) NSString *radioTitle;
@property (nonatomic, retain) UIButton *dontDownload;

///favotite
@property (nonatomic,retain) NSMutableArray *favoritesRadio;




//banner
@property(nonatomic, strong) GADBannerView *adBanner;


-(IBAction)playButton:(id)sender;

-(IBAction)share:(id)sender;
-(void)stopMusic;
-(IBAction)favorite:(id)sender;



-(void)stopRadioPlayer;
-(IBAction)chat:(id)sender;



//animations


@end

