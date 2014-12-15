//
//  AboutViewController.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <MessageUI/MessageUI.h>
#import "LoginChatViewController.h"

@interface AboutViewController : UIViewController <UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,LoginChatViewControllerDelegate>{
    
    UILabel *titleAbout;
}

@property (nonatomic,retain) IBOutlet UILabel *titleAbout;




-(IBAction)site:(id)sender;
-(IBAction)mailMe:(id)sender;
-(IBAction)support:(id)sender;



@end
