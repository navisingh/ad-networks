//
//  SimpleAdsViewController.m
//  Copyright (c) 2010 MoPub Inc.
//

#import "SimpleAdsViewController.h"
#import "MPAdView.h"
#import <CoreLocation/CoreLocation.h>

@implementation SimpleAdsViewController

@synthesize keyword;
@synthesize mpAdView, mpMrectView;
@synthesize adView, mrectView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 320x50 size
	mpAdView = [[MPAdView alloc] initWithAdUnitId:PUB_ID_320x50 size:MOPUB_BANNER_SIZE];
	mpAdView.delegate = self;
	[mpAdView loadAd];
	[self.adView addSubview:mpAdView];
	
	// MRect size
	mpMrectView = [[MPAdView alloc] initWithAdUnitId:PUB_ID_300x250 size:MOPUB_MEDIUM_RECT_SIZE];
	mpMrectView.delegate = self;
	[mpMrectView loadAd];
	[self.mrectView addSubview:mpMrectView];	
	
}

- (IBAction) refreshAd {
	[keyword resignFirstResponder];
	
	// update ad 
	self.mpAdView.keywords = keyword.text;
	[self.mpAdView refreshAd];
	
	// update mrect
	self.mpMrectView.keywords = keyword.text;
	[self.mpMrectView refreshAd];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self refreshAd];
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[mpAdView release];
	[mpMrectView release];
	[super dealloc];
}

- (UIViewController *)viewControllerForPresentingModalView
{
	return self;
}

- (void)dismissInterstitial:(MPInterstitialAdController *)interstitial
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
