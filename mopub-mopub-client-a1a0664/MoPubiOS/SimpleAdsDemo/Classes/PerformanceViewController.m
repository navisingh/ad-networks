//
//  PerformanceViewController.m
//  SimpleAds
//
//  Created by James Payne on 2/4/11.
//  Copyright 2011 MoPub Inc. All rights reserved.
//

#import "PerformanceViewController.h"
#import "MPAdView.h"

@implementation PerformanceViewController

@synthesize console;
@synthesize keyword;
@synthesize mpAdView;
@synthesize adView;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self clearConsole];
}

-(void)adViewDidLoadAd:(MPAdView *)_adView{
	[self outputLine:[NSString stringWithFormat:@"Calling MoPub with %@", _adView.URL]];
}

- (void)adViewDidReceiveResponseParams:(NSDictionary *)params{
	[self outputLine:[NSString stringWithFormat:@"Server response received: %@", params]];
}

//- (void)adControllerDidLoadAd:(AdController *)_adView{
//	[self outputLine:@"Ad was loaded. Success."];
//	[self outputLine:[NSString stringWithFormat:@"Payload (%d octets) = %@", [a_adViewd.data length], [[NSString alloc] initWithData:_adView.data encoding:NSUTF8StringEncoding]]];
//}

- (void)adViewDidFailToLoadAd:(MPAdView *)_adView{
	[self outputLine:@"Ad did not load."];
//	[self outputLine:[NSString stringWithFormat:@"Payload (%d octets) = %@", [_adView.data length], [[NSString alloc] initWithData:_adView.data encoding:NSUTF8StringEncoding]]];
}

- (IBAction) refreshAd {
	[keyword resignFirstResponder];
	
	// start timer here
	[self clearConsole];
	_adRequestStartTime = [NSDate timeIntervalSinceReferenceDate];
	
	// 320x50 size
	self.mpAdView = [[MPAdView alloc] initWithAdUnitId:PUB_ID_320x50 size:MOPUB_BANNER_SIZE];
	self.mpAdView.delegate = self;
	self.mpAdView.keywords = self.keyword.text;
	[self.mpAdView loadAd];
	[self.adView addSubview:self.mpAdView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self refreshAd];
	return YES;
}

- (void) clearConsole {
	self.console.font = [UIFont fontWithName:@"Courier" size:10];
	self.console.text = @"MoPub Ad Loading Console\n=========================";
}

- (void) outputLine:(NSString*)line {
	self.console.text = [self.console.text stringByAppendingFormat:@"\n[%.3f] %@", [NSDate timeIntervalSinceReferenceDate] - _adRequestStartTime, line];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.keyword = nil;
	self.mpAdView = nil;
	self.adView = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (UIViewController *)viewControllerForPresentingModalView
{
	return self;
}


@end
