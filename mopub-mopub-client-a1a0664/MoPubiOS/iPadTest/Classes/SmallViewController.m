    //
//  SmallViewController.m
//  iPadTest
//
//  Created by Nafis Jamal on 3/15/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "SmallViewController.h"
#import "MPAdView.h"
#import "MPLogging.h"

@implementation SmallViewController
@synthesize parent;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	//MPLogSetLevel(MPLogLevelTrace);
	
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
	self.view.backgroundColor = [UIColor greenColor];
	
	adView = [[MPAdView alloc] initWithAdUnitId:@"agltb3B1Yi1pbmNyDAsSBFNpdGUY1uYfDA" size:MOPUB_BANNER_SIZE];
	adView.delegate = self;
	
	CGSize size = [adView adContentViewSize];
	CGRect frame = adView.frame;
	frame.origin.x = (self.view.bounds.size.width - size.width)/2.0;
	adView.frame = frame;
	
    [adView loadAd];
    [self.view addSubview:adView];
    [adView release];
	
}

- (void)adViewDidLoadAd:(MPAdView *)view_
{
    CGSize size = [view_ adContentViewSize];
    CGRect newFrame = view_.frame;
	
    newFrame.size = size;
    newFrame.origin.x = (self.view.bounds.size.width - size.width) / 2;
    view_.frame = newFrame;
}


- (UIViewController *)viewControllerForPresentingModalView{
	return self.parent;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[adView rotateToOrientation:interfaceOrientation];
	
	CGSize size = [adView adContentViewSize];

	CGRect newFrame = adView.frame;
	
	newFrame.size = size;
	newFrame.origin.x = (self.view.bounds.size.width - size.width) / 2.0 ;
		
	adView.frame = newFrame;
	
	return YES;
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
