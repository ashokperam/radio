//
//  LoginChatViewController.h
//  radiochat
//
//  Created by CODERLAB on 17.03.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

@protocol LoginChatViewControllerDelegate


- (void)didFinishLogin:(NSDictionary *)Userinfo;

@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface LoginChatViewController : UIViewController <UIActionSheetDelegate>


@property (nonatomic, assign) IBOutlet id<LoginChatViewControllerDelegate>delegate;

@end
