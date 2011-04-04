//
//  iPadTestViewController.m
//  iPadTest
//
//  Created by Nafis Jamal on 3/15/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "iPadTestViewController.h"
#import "MPAdView.h"
#import "SmallViewController.h"
#import "MPLogging.h"

@implementation iPadTestViewController


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
	MPLogSetLevel(MPLogLevelDebug);
	
    [super viewDidLoad];

	//self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 100.0, 320.0, 50.0)];
	self.view.backgroundColor = [UIColor greenColor];
	
	adView = [[MPAdView alloc] initWithAdUnitId:@"agltb3B1Yi1pbmNyDAsSBFNpdGUYkaoMDA" size:MOPUB_BANNER_SIZE];
	adView.delegate = self;
	
	CGSize size = [adView adContentViewSize];
	CGRect frame = adView.frame;
	frame.origin.x = (self.view.bounds.size.width - size.width)/2.0;
	adView.frame = frame;
	
    [adView loadAd];
    [self.view addSubview:adView];
    [adView release];
	
	/*smallVC = [[SmallViewController alloc] initWithNibName:nil bundle:nil];
	CGRect frame = smallVC.view.frame;
	frame.origin.x = (self.view.frame.size.width - smallVC.view.frame.size.width) / 2.0 ;
	smallVC.view.frame = frame;
	smallVC.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	smallVC.parent = self;
	[self.view addSubview:smallVC.view];*/
	
}

- (void)adViewDidLoadAd:(MPAdView *)view_
{
    CGSize size = [view_ adContentViewSize];
    CGRect newFrame = view_.frame;
	
    newFrame.size = size;
	CGSize blah = self.view.bounds.size;
    newFrame.origin.x = (self.view.bounds.size.width - size.width) / 2;
    view_.frame = newFrame;
}

- (UIViewController *)viewControllerForPresentingModalView{
	return self;
}

- (IBAction)refresh{
	[adView refreshAd];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	[adView rotateToOrientation:toInterfaceOrientation];
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	CGSize size = [adView adContentViewSize];
    CGRect newFrame = adView.frame;
	
    newFrame.size = size;
    newFrame.origin.x = (self.view.bounds.size.width - size.width) / 2;	
	adView.frame = newFrame;

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
    [super dealloc];
}

@end
