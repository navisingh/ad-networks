//
//  WelcomeViewController.m
//  SimpleAds
//
//  Created by James Payne on 2/3/11.
//  Copyright 2011 MoPub Inc. All rights reserved.
//

#import "WelcomeViewController.h"


@implementation WelcomeViewController

- (IBAction)visitWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.mopub.com"]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
