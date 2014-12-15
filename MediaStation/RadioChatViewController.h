//
//  RadioChatViewController.h
//  radiochat
//
//  Created by CODERLAB on 17.03.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "JSMessagesViewController.h"



@interface RadioChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate,UITabBarDelegate,UITabBarControllerDelegate>{
    
}


- (id)initWith:(NSString *)Chatroom Userinfo:(NSDictionary *)Userinfo;

@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) NSMutableArray *messages;


@end

