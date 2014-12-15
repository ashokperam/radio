//
//  utils.m
//  radiochat
//
//  Created by CODERLAB on 17.03.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import "userdata.m"

NSDictionary* UserData(NSDictionary *dict)

{
	NSString *userid = [dict valueForKey:@"id"];
	NSString *nameuser = [dict valueForKey:@"displayName"];
	NSString *imageuser = [dict objectForKey:@"profile_image_url"];
	
	if (imageuser == nil) imageuser = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userid];
	
	return @{@"uid":userid, @"image":imageuser, @"name":nameuser};
}


