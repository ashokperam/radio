//
//  AboutViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "AboutViewController.h"
#import "iConfigApp.h"
#import "RadioChatViewController.h"
#import "ProgressHUD.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

#import "userdata.h"
#import "LoginChatViewController.h"
#import "ProgressHUD.h"

@interface AboutViewController (){
    
    NSDictionary *userinfo;
    NSMutableArray *itemz;
    
    UIBarButtonItem *buttonLogin;
    UIBarButtonItem *buttonLogout;
    
    NSArray *accounts;
	NSInteger selected;
    NSString *shareTextSocial;
}

@property (nonatomic,retain) IBOutlet UIButton *chatEnabled;

@end

@implementation AboutViewController
@synthesize titleAbout;

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
    
    NSString *myText = NSLocalizedString(@"My text",nil);
    
    titleAbout.text = myText;
    UINavigationController* more =
    self.tabBarController.moreNavigationController;
    UIViewController* list = more.viewControllers[0];
    list.title = @"";
    UIBarButtonItem* b = [UIBarButtonItem new];
    b.title = @"Back";
    list.navigationItem.backBarButtonItem = b; // so user can navigate back
    more.navigationBar.barStyle = UIBarStyleBlack;
    more.navigationBar.tintColor = [UIColor whiteColor];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)mailMe:(id)sender{
    
    // Email Subject
    NSString *emailTitle = MailTitle;
    // Email Content
    NSString *messageBody = EmailMessage;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:YourEmail];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];

    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(IBAction)site:(id)sender{
    
    
}

-(IBAction)support:(id)sender{
   
    
    
    NSLog(@"Tap chatBtn");
    
    if (userinfo != nil)
	{
		NSString *chatroom = @"Support";
		
		RadioChatViewController *nonSystemsController = [[RadioChatViewController alloc] initWith:chatroom Userinfo:userinfo];
		[self.navigationController pushViewController:nonSystemsController animated:YES];
      //  [self presentViewController:nonSystemsController animated:YES completion:nil];
        
		
	}
	else {
        
        [self actionLogin];
        
    }
    

    
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
