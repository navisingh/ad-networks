//
//  MPAdBrowserController.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPAdBrowserController.h"
#import "MPLogging.h"

@implementation MPAdBrowserController

@synthesize webView = _webView;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize safariButton = _safariButton;
@synthesize doneButton = _doneButton;
@synthesize spinnerItem = _spinnerItem;

@synthesize delegate = _delegate;
@synthesize URL = _URL;

static NSArray *BROWSER_SCHEMES, *SPECIAL_HOSTS;

+ (void)initialize 
{
	// Schemes that should be handled by the in-app browser.
	BROWSER_SCHEMES = [[NSArray arrayWithObjects:
					   @"http",
					   @"https",
					   nil] retain];
	
	// Hosts that should be handled by the OS.
	SPECIAL_HOSTS = [[NSArray arrayWithObjects:
					 @"phobos.apple.com",
					 @"maps.google.com",
					 nil] retain];
}

#pragma mark -
#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)URL delegate:(id<MPAdBrowserControllerDelegate>)delegate
{
	if (self = [super initWithNibName:@"MPAdBrowserController" bundle:nil])
	{
		_delegate = delegate;
		_URL = [URL copy];
		MPLogDebug(@"Ad browser (%p) initialized with URL: %@", self, _URL);
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
			UIViewAutoresizingFlexibleHeight;
		_webView.delegate = self;
		
		_spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		[_spinner sizeToFit];
		_spinner.hidesWhenStopped = YES;
	}
	return self;
}

- (void)dealloc
{
	_delegate = nil;
	_webView.delegate = nil;
	[_webView release];
	[_URL release];
	[_backButton release];
	[_forwardButton release];
	[_refreshButton release];
	[_safariButton release];
	[_doneButton release];
	[_spinner release];
	[_spinnerItem release];
	[super dealloc];
}

- (void)viewDidLoad{
	[super viewDidLoad];

	// Set up toolbar buttons
	self.backButton.image = [self backArrowImage];
	self.backButton.title = nil;
	self.forwardButton.image = [self forwardArrowImage];
	self.forwardButton.title = nil;
	self.spinnerItem.customView = _spinner;	
	self.spinnerItem.title = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	// Set button enabled status.
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
	_refreshButton.enabled = NO;
	_safariButton.enabled = NO;
	
	// Load up webview content.
	[_webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

#pragma mark -
#pragma mark Navigation

- (IBAction)refresh 
{
	[_webView reload];
}

- (IBAction)done 
{
	[self.delegate dismissBrowserController:self];
}

- (IBAction)back 
{
	[_webView goBack];
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
}

- (IBAction)forward 
{
	[_webView goForward];
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
}

- (IBAction)safari
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self 
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil 
													otherButtonTitles:@"Open in Safari", nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == 0) 
	{
		// Open in Safari.
		[[UIApplication sharedApplication] openURL:_webView.request.URL];
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
	MPLogDebug(@"Ad browser starting to load request %@", request.URL);
	
	/* 
	 * For all links with http:// or https:// scheme, open in our browser UNLESS
	 * the host is one of our special hosts that should be handled by the OS.
	 */
	if ([BROWSER_SCHEMES containsObject:request.URL.scheme])
	{
		if ([SPECIAL_HOSTS containsObject:request.URL.host])
		{
			[self dismissModalViewControllerAnimated:NO];
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
		}
		else 
		{
			return YES;
		}
	}
	// Non-http(s):// scheme, so ask the OS if it can handle.
	else 
	{
		if ([[UIApplication sharedApplication] canOpenURL:request.URL])
		{
			[self dismissModalViewControllerAnimated:NO];
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
		}
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
	_refreshButton.enabled = YES;
	_safariButton.enabled = YES;
	[_spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
	_refreshButton.enabled = YES;
	_safariButton.enabled = YES;	
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
	[_spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load page." 
													message:[error localizedDescription] 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Drawing

- (CGContextRef)createContext
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,27,27,8,0,
												 colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	return context;
}

- (UIImage *)backArrowImage
{
	CGContextRef context = [self createContext];
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 8.0f, 13.0f);
	CGContextAddLineToPoint(context, 24.0f, 4.0f);
	CGContextAddLineToPoint(context, 24.0f, 22.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return [image autorelease];
}

- (UIImage *)forwardArrowImage
{
	CGContextRef context = [self createContext];
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 24.0f, 13.0f);
	CGContextAddLineToPoint(context, 8.0f, 4.0f);
	CGContextAddLineToPoint(context, 8.0f, 22.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return [image autorelease];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
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


@end
