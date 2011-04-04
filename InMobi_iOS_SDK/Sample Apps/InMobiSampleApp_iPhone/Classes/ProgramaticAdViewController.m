//
//  InMobiSampleApp_iPhoneViewController.m
//  InMobiSampleApp_iPhone
//

//

#import "ProgramaticAdViewController.h"

@implementation ProgramaticAdViewController

@synthesize inmobiAdView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Programmatic Ad";
	self.inmobiAdView = [InMobiAdView requestAdUnit:INMOBI_AD_UNIT_320x48 withDelegate:self];
	timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(loadInMobiAd) userInfo:nil repeats:YES];
}

- (void)loadInMobiAd {
	NSLog(@"load new inmobi ad");
	[inmobiAdView loadNewAd];
}

#pragma mark InMobiAdDelegate methods required

- (NSString *)siteId {
	//this should be prefilled.
	return @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
}

- (UIViewController *)rootViewControllerForAd {
	return self.navigationController;
}

#pragma mark InMobiAdDelegate optional methods for an ad request.

- (BOOL)isLocationInquiryAllowed {
	return YES;
}
- (CLLocation *)currentLocation {
	return NULL;
}
- (BOOL)testMode {
	return NO;
}

- (NSString *)postalCode {
	//this is just an example
	return @"12345";
}
- (NSString *)areaCode {
	//this is just an example
	return @"123";
}
- (NSDate *)dateOfBirth {
	//return birth date 23rd April 1990
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"MMM dd yyyy HH:mm:ss ZZZ"];
	return [dateFormatter dateFromString:@"Apr 23 1990 00:00:00 +0000"];
}

- (Gender)gender {
	//this is just an example
	return G_M;
}

- (NSString *)keywords {
	//this is just an example
	return @"";
}

- (NSString *)searchString {
	//this is just an example
	return @"iphone games";
}

- (NSUInteger)income {
	//this is just an example
	return 10000;
}
- (Education)education {
	//this is just an example
	return Edu_InCollege;
}

- (Ethnicity)ethnicity {
	//this is just an example
	return Eth_White;
}

- (NSUInteger)age {
	//this is just an example
	return 21;
}

- (NSString *)interests {
	//this is just an example
	return @"mobile,clothes,games";
}

#pragma mark InMobiAdDelegate optional notification methods

- (void)adReceivedNotification:(InMobiAdView*)adView {
	NSLog(@"InMobi ad received..");
	if (![inmobiAdView superview]) {
		//check so that adview is not added to superview multiple times
		[self.view addSubview:inmobiAdView];
	}
}

- (void)adFailedNotification:(InMobiAdView*)adView {
	NSLog(@"ad failed to load..this should probably be ok..");
}

- (void)adModalScreenDisplayNotification:(InMobiAdView*)adView {
	NSLog(@"InMobi ad clicked, pause timers,animations etc..");
}

- (void)adModalScreenDismissNotification:(InMobiAdView*)adView {
	NSLog(@"InMobi ad modal screen dismissed..resume timers,animations etc..");
}

- (void)applicationWillTerminateFromAd:(InMobiAdView *)adView {
	NSLog(@"app will terminate from ad");
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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
	[inmobiAdView setDelegate:nil];
	[inmobiAdView release];
	[timer invalidate]; timer = nil;
    [super dealloc];
}

@end
