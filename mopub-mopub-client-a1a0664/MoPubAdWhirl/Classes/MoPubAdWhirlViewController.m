//
//  MoPubAdWhirlViewController.m
//  MoPubAdWhirl
//
//  Created by Nafis Jamal on 3/19/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MoPubAdWhirlViewController.h"
#import "AdWhirlView.h"

@implementation MoPubAdWhirlViewController

@synthesize mopubAdapter;

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
	adWhirlView = [[AdWhirlView requestAdWhirlViewWithDelegate:self] retain];
	[self.view addSubview:adWhirlView];
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	[adWhirlView rotateToOrientation:interfaceOrientation];
	[mopubAdapter rotateToOrientation:interfaceOrientation];
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	CGSize size = [adWhirlView actualAdSize];
    CGRect newFrame = adWhirlView.frame;
	
    newFrame.size = size;
    newFrame.origin.x = (self.view.bounds.size.width - size.width) / 2;	
	adWhirlView.frame = newFrame;
	
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
	[mopubAdapter release];
	[adWhirlView release];
    [super dealloc];
}

# pragma 
# pragma AdWhirlDelegates
# pragma
- (NSString *)adWhirlApplicationKey {
	return @"19bfcf33611242bb969624e43520e347";
}

- (UIViewController *)viewControllerForPresentingModalView {
	return self;
}

# pragma
# pragma AdWhirlDelegates
# pragma
- (CLLocation *)locationInfo{
	return [[[CLLocation alloc] initWithLatitude:10.0 longitude:10.0] autorelease];
}

- (NSString *)postalCode{
	return @"94107";
}
- (NSString *)areaCode{
	return @"650";
}
- (NSDate *)dateOfBirth{
	return [NSDate dateWithTimeIntervalSince1970:520344000];
}
- (NSString *)gender{
	return @"m";
}; // user's gender (e.g. @"m" or @"f")
- (NSString *)keywords{
	return @"cookies,cream,chocolate,coffee";
}; // keywords the user has provided or that are contextually relevant, e.g. @"twitter client iPhone"
- (NSString *)searchString{
	return @"this is what i am searching for";
} // a search string the user has provided, e.g. @"Jasmine Tea House San Francisco"
- (NSUInteger)incomeLevel{
	return 5;
}

# pragma
# pragma custom selector
# pragma

- (void)mopubLoadAd:(AdWhirlView *)awView {
	// replace banner content
	self.mopubAdapter = [AdWhirlCustomEventAdapterMoPub requestMoPubAdForAdUnitID:@"agltb3B1Yi1pbmNyDAsSBFNpdGUYkaoMDA" 
														 withAdWhirlDelegate:adWhirlView.delegate 
															  forAdWhirlView:adWhirlView];
}

@end
