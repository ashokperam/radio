//
//  UserFileViewController.h
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
#import "MPDPlayer.h"





@interface UserFileViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    
     NSMutableArray *favorites;
     int numbersRow;
     int section;
     AVPlayer *musicPlayerLoad;
     UIImageView *coverLable;
     int counter;
     IBOutlet UIButton *playPauseButton;
     BOOL wasPlaying;
     UIBackgroundTaskIdentifier bgTaskId;
     id timeObserver;
     NSTimer *audioUpdateTimer;
     UILabel *tracks;
    
   
    
    
}
@property (retain, nonatomic) NSMutableArray *favorites;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int numbersRow;
@property (nonatomic,assign) int section;
@property (nonatomic, retain)  AVPlayer *musicPlayerLoad;
@property (nonatomic,retain) IBOutlet UIImageView *coverLable;
@property (nonatomic,readwrite) int counter;
@property (nonatomic,retain) IBOutlet UILabel *tracks;


-(void)stopMusicUser;
-(IBAction)back:(id)sender;

@end
