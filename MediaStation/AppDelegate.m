//
//  AppDelegate.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "AppDelegate.h"
#import "LastFm.h"
#import "LastFmCache.h"
#import <RevMobAds/RevMobAds.h>
#import "iConfigApp.h"
#import "iRate.h"


#define SESSION_KEY @"is.gangverk.lastfm.example.session"
#define USERNAME_KEY @"is.gangverk.lastfm.example.username"

@interface AppDelegate (){
    
    
}

@property (strong, nonatomic) LastFmCache *lastFmCache;

@end
@implementation AppDelegate
@synthesize tabBarController;

//////////////////////////// Irate in

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].applicationBundleID = ApplicationBundleID;
	[iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = ApplicationBundleIDMode;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback     /// set audiosession
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [LastFm sharedInstance].apiKey = lastFmApiKey ;
    [LastFm sharedInstance].apiSecret = lastFmApiSecretKey;
    [LastFm sharedInstance].session = [[NSUserDefaults standardUserDefaults] stringForKey:SESSION_KEY];
    [LastFm sharedInstance].username = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME_KEY];
    [LastFm sharedInstance].cacheDelegate = self.lastFmCache;
    
  //  [RevMobAds startSessionWithAppID:API_REVMOB];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:219.0f/255.0f green:109.0f/255.0f blue:102.0f/255.0f alpha:1.0f]];
    
    UINavigationController* more =
    self.tabBarController.moreNavigationController;
    UIViewController* list = more.viewControllers[0];
    list.title = @"";
    UIBarButtonItem* b = [UIBarButtonItem new];
    b.title = @"Back";
    list.navigationItem.backBarButtonItem = b; // so user can navigate back
    more.navigationBar.barStyle = UIBarStyleBlack;
    more.navigationBar.tintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    
    
    
    return YES;
}
- (void) tabBarController:(UITabBarController *)controller willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    
    // Set the color of the navigationbar if edit was selected
    UIView *editView = [controller.view.subviews objectAtIndex:1];
    UINavigationBar *modalNavBar = [editView.subviews objectAtIndex:0];
    modalNavBar.tintColor = [UIColor orangeColor];
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
