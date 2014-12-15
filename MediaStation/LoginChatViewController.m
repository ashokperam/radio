//
//  LoginChatViewController.m
//  radiochat
//
//  Created by CODERLAB on 17.03.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import "ProgressHUD.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

#import "iConfigApp.h"
#import "userdata.h"

#import "LoginChatViewController.h"
#import "PlayerViewController.h"



@interface LoginChatViewController()
{
	NSArray *accounts;
	NSInteger selected;
    
}

@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;

@property (strong, nonatomic) IBOutlet UIButton *cancel;


@end


@implementation LoginChatViewController

@synthesize delegate;
@synthesize btnFacebook;
@synthesize btnTwitter;
@synthesize cancel;



- (void)viewDidLoad {
    
	[super viewDidLoad];
	
  
}



- (void)showError:(id)message {
    
	[ProgressHUD showError:message Interacton:NO];
}


- (IBAction)Facebookbtn:(id)sender

{
	[ProgressHUD show:@"Login:wait..." Interacton:NO];
	
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	
	[authClient loginToFacebookAppWithId:FACEBOOK_KEY permissions:@[@"email"] audience:ACFacebookAudienceOnlyMe
					 withCompletionBlock:^(NSError *error, FAUser *user)
     {
         if (error == nil)
         {
             if (user != nil) [delegate didFinishLogin:UserData(user.thirdPartyUserData)];
             [self dismissViewControllerAnimated:YES completion:^{ [ProgressHUD dismiss]; }];
         }
         else
         {
             NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
             if (message == nil) message = @"Access to Facebook account was not granted";
             [self performSelectorOnMainThread:@selector(showError:) withObject:message waitUntilDone:NO];
         }
     }];
}


- (IBAction)Twitterbtn:(id)sender

{
	[ProgressHUD show:@"Login:wait......" Interacton:NO];
	
	selected = 0;
	
	ACAccountStore *account = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

	[account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             accounts = [account accountsWithAccountType:accountType];
             
             if ([accounts count] == 0)
                 [self performSelectorOnMainThread:@selector(showError:) withObject:@"No Twitter account was found" waitUntilDone:NO];
        
             if ([accounts count] == 1)	[self performSelectorOnMainThread:@selector(Twitterlog) withObject:nil waitUntilDone:NO];
             if ([accounts count] >= 2)	[self performSelectorOnMainThread:@selector(Twitterset) withObject:nil waitUntilDone:NO];
         }
         else [self performSelectorOnMainThread:@selector(showError:) withObject:@"Access to Twitter account was not granted" waitUntilDone:NO];
     }];
}


- (void)Twitterset

{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter account" delegate:self cancelButtonTitle:nil
										  destructiveButtonTitle:nil otherButtonTitles:nil];

	for (NSInteger i=0; i<[accounts count]; i++)
	{
		ACAccount *account = [accounts objectAtIndex:i];
		[action addButtonWithTitle:account.username];
	}

	[action addButtonWithTitle:@"Cancel"];
	action.cancelButtonIndex = accounts.count;
	[action showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		selected = buttonIndex;
		[self Twitterlog];
	}
	else [ProgressHUD dismiss];
}


- (void)Twitterlog

{
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	
	[authClient loginToTwitterAppWithId:TWITTER_KEY multipleAccountsHandler:^int(NSArray *usernames)
     {
         return (int)selected;
     }
                    withCompletionBlock:^(NSError *error, FAUser *user)
     {
         if (error == nil)
         {
             if (user != nil) [delegate didFinishLogin:UserData(user.thirdPartyUserData)];
             [self dismissViewControllerAnimated:YES completion:^{ [ProgressHUD dismiss]; }];
         }
         else
         {
             NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
             [self performSelectorOnMainThread:@selector(showError:) withObject:message waitUntilDone:NO];
         }
     }];
}

-(IBAction)cancel:(id)sender{
    
   
        [self dismissViewControllerAnimated:YES completion:nil];

    
}



@end
