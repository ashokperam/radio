//
//  MPDPlayer.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@class FSAudioStream;
@class FSAudioController;
@protocol MPDPlayerDelegate;


@interface MPDPlayer : NSObject {
    
    AVPlayer *aPlayer;
    FSAudioStream *_audioStream;
    FSAudioController *_audioController;
    
}




@property (nonatomic, assign) id <MPDPlayerDelegate> delegate;
@property(readonly) AVPlayer *aPlayer;


+(MPDPlayer *)sharedInstance;
-(void)playWithURL:(NSURL *)url;
-(void)playWithInstance:(AVPlayerItem*)itemInstanse;
-(void)playStream:(NSURL *)url;
-(void)stopStream;
//-(float)currentPlaybackTime;
@end