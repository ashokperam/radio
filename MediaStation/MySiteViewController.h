//
//  MySiteViewController.h
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySiteViewController : UIViewController <UIWebViewDelegate> {
    
    UIWebView *webView;
}
@property(nonatomic,retain) IBOutlet  UIWebView *webView;

-(IBAction)back:(id)sender;


@end
