//
//  PDJPlayerViewController.h
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
#import "ASINetworkQueue.h"
#import "TKProgressBarView.h"
#import <QuartzCore/QuartzCore.h>
#import <CFNetwork/CFNetwork.h>
#import <sys/xattr.h>
#import "LoginChatViewController.h"



@interface PDJPlayerViewController : UIViewController<LoginChatViewControllerDelegate> {
    
    UIImageView *coverLable;
    NSMutableArray *playList;
    AVPlayer *musicPlayer;
    int counter;
    IBOutlet UIButton *playPauseButton;
    ASINetworkQueue *networkQueue;
    float contentLengthOfFile;
    UIImageView *circleA;
    UIImageView *circleB;
    UIView *coverView;
    UIView *gestureSensor;
    NSString *chatRoom;
    
    
}

@property (readwrite, nonatomic) int row;
@property (nonatomic,retain) IBOutlet UIImageView *coverLable;
@property (nonatomic, retain) NSMutableArray *playList;
@property (nonatomic, retain)  AVPlayer *musicPlayer;
@property (nonatomic,readwrite) int counter;
@property (nonatomic,strong) TKProgressBarView *progressBarDown;
@property (nonatomic,retain) IBOutlet UIImageView *circleA;
@property (nonatomic,retain) IBOutlet UIImageView *circleB;
@property (nonatomic,retain) IBOutlet UIView *coverView;
@property (nonatomic,retain) IBOutlet UIView *gestureSensor;
@property (nonatomic,retain)  MPMediaItemArtwork *albumArtz;
@property (nonatomic,retain) NSString *chatRoom;


-(IBAction)download:(id)sender;
-(IBAction)chat:(id)sender;







@end

