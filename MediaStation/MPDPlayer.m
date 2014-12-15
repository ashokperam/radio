//
//  MPDPlayer.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "MPDPlayer.h"
#import "FSAudioStream.h"
#import "FSAudioController.h"

static MPDPlayer *sharedInstance = nil;
@interface MPDPlayer (){
    
}


@end
@implementation MPDPlayer
@synthesize aPlayer;

- (id)init
{
    self = [super init];
    
    if (self) {
        // Work your initialising here as you normally would
    }
    
    return self;
}

+ (MPDPlayer *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}



-(void)playWithURL:(NSURL *)url{
    
    self.aPlayer.rate = 0.0f;
  // [self.aPlayer pause];
    
    [self.aPlayer addObserver:self forKeyPath:@"status" options:0 context:0];
   
    aPlayer = [[AVPlayer alloc] initWithURL:url];
   
   
    [self.aPlayer play];
       

    
}
-(void)playWithInstance:(AVPlayerItem*)itemInstanse{
    
    
    [self.aPlayer addObserver:self forKeyPath:@"status" options:0 context:0];
    self.aPlayer.rate = 0.0f;
   // [self.aPlayer pause];
    aPlayer = [AVPlayer playerWithPlayerItem:itemInstanse];
    [self.aPlayer play];
    
}

-(void)playStream:(NSURL *)url{
    
    [_audioController stop];
    
    _audioController = [[FSAudioController alloc] init];
    _audioController.url = url;
    [_audioController play];
    
}

-(void)stopStream{
    
    [_audioController stop];
    
}

/*
-(float)currentPlaybackTime{
    
  //  return audioPlayer.currentTime;
}
*/
@end