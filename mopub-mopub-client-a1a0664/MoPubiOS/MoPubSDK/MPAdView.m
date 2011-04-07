//
//  MPAdView.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPAdView.h"
#import "MPBaseAdapter.h"
#import "MPAdapterMap.h"
#import "MPTimer.h"
#import <CommonCrypto/CommonDigest.h>
#import <stdlib.h>
#import <time.h>

@interface MPAdView (Internal)
- (void)scheduleAutorefreshTimer;
- (void)setScrollable:(BOOL)scrollable forView:(UIView *)view;
- (UIWebView *)makeAdWebViewWithFrame:(CGRect)frame;
- (void)adLinkClicked:(NSURL *)URL;
- (void)backFillWithNothing;
- (void)trackClick;
- (void)trackImpression;
- (NSDictionary *)dictionaryFromQueryString:(NSString *)query;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
@end

@interface MPAdView ()
@property (nonatomic, copy) NSURL *clickURL;
@property (nonatomic, copy) NSURL *interceptURL;
@property (nonatomic, copy) NSURL *failURL;
@property (nonatomic, copy) NSURL *impTrackerURL;
@property (nonatomic, assign) BOOL shouldInterceptLinks;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, retain) MPTimer *autorefreshTimer;
@end

@implementation MPAdView

@synthesize delegate = _delegate;
@synthesize adUnitId = _adUnitId;
@synthesize URL = _URL;
@synthesize clickURL = _clickURL;
@synthesize interceptURL = _interceptURL;
@synthesize failURL = _failURL;
@synthesize impTrackerURL = _impTrackerURL;
@synthesize creativeSize = _creativeSize;
@synthesize keywords = _keywords;
@synthesize location = _location;
@synthesize shouldInterceptLinks = _shouldInterceptLinks;
@synthesize scrollable = _scrollable;
@synthesize autorefreshTimer = _autorefreshTimer;
@synthesize ignoresAutorefresh = _ignoresAutorefresh;
@synthesize stretchesWebContentToFill = _stretchesWebContentToFill;

#pragma mark -
#pragma mark Lifecycle

+ (void)initialize
{
	srandom(time(NULL));
}

#ifdef __IPHONE_4_0
UIKIT_EXTERN NSString *const UIApplicationDidEnterBackgroundNotification __attribute__((weak_import));
UIKIT_EXTERN NSString *const UIApplicationWillEnterForegroundNotification __attribute__((weak_import));
#endif

- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size 
{   
	CGRect f = (CGRect){{0, 0}, size};
    if ((self = [super initWithFrame:f])) 
	{
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		_adUnitId = (adUnitId) ? [adUnitId copy] : DEFAULT_PUB_ID;
		_data = [[NSMutableData data] retain];
		_shouldInterceptLinks = YES;
		_scrollable = NO;
		_isLoading = NO;
		_ignoresAutorefresh = NO;
		_store = [MPStore sharedStore];
		_animationType = MPAdAnimationTypeNone;
		_originalSize = size;
		
		// register as listener for events for going into and returning from background
		// for iOS 4.0 +
#ifdef __IPHONE_4_0
        NSString *const *p = &UIApplicationDidEnterBackgroundNotification;
        BOOL frameworkSupportsUIApplicationDidEnterBackgroundNotification = p!= NULL;
        
		if (frameworkSupportsUIApplicationDidEnterBackgroundNotification)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationDidEnterBackground) 
														 name:UIApplicationDidEnterBackgroundNotification 
													   object:[UIApplication sharedApplication]];
		}		
		if (frameworkSupportsUIApplicationDidEnterBackgroundNotification)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationWillEnterForeground)
														 name:UIApplicationWillEnterForegroundNotification 
													   object:[UIApplication sharedApplication]];
		}
#endif
        
    }
    return self;
}

- (void)dealloc 
{
	_delegate = nil;
	// If our content is a webview or otherwise has a delegate, set its delegate to nil.
	if ([_adContentView respondsToSelector:@selector(setDelegate:)])
		[_adContentView performSelector:@selector(setDelegate:) withObject:nil];
	[_adContentView release];
	[_currentAdapter unregisterDelegate];
	[_currentAdapter release];
	[_previousAdapter unregisterDelegate];
	[_previousAdapter release];
	[_adUnitId release];
	[_conn cancel];
	[_conn release];
	[_data release];
	[_URL release];
	[_clickURL release];
	[_interceptURL release];
	[_failURL release];
	[_impTrackerURL release];
	[_keywords release];
	[_location release];
	[_autorefreshTimer invalidate];
	[_autorefreshTimer release];
    [super dealloc];
}

#pragma mark -

- (void)setAdContentView:(UIView *)view
{
	if (!view)
		return;
	
	[view retain];
	
	self.hidden = NO;
	
	// We don't necessarily know where this view came from, so make sure its scrollability
	// corresponds to our value of _scrollable.
	[self setScrollable:_scrollable forView:view];
	
	MPAdAnimationType type = (_animationType == MPAdAnimationTypeRandom) ? 
		(random() % (MPAdAnimationTypeCount - 2)) + 2 : _animationType;
	
	// Special case: if there's currently no ad content view, certain transitions will
	// look strange (e.g. CurlUp / CurlDown). We'll just omit the transition.
	if (!_adContentView)
		type = MPAdAnimationTypeNone;
	
	if (type == MPAdAnimationTypeFade)
		view.alpha = 0.0;
	MPLogDebug(@"Ad view (%p) is using animationType: %d", self, type);
	
	[UIView beginAnimations:@"MPAdTransition" context:view];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:1.0];
	
	switch (type)
	{
		case MPAdAnimationTypeFlipFromLeft:
			[self addSubview:view];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft 
								   forView:self 
									 cache:YES];
			break;
		case MPAdAnimationTypeFlipFromRight:
			[self addSubview:view];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
								   forView:self 
									 cache:YES];
			break;
		case MPAdAnimationTypeCurlUp:
			[self addSubview:view];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
								   forView:self 
									 cache:YES];
			break;
		case MPAdAnimationTypeCurlDown:
			[self addSubview:view];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
								   forView:self 
									 cache:YES];
			break;
		case MPAdAnimationTypeFade:
			[UIView setAnimationCurve:UIViewAnimationCurveLinear];
			[self addSubview:view];
			view.alpha = 1.0;
			break;
		default:
			[self addSubview:view];
			break;
	}
	
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished 
				 context:(void *)context
{
	// context is the view that we just added to the view hierarchy (i.e. the view 
	// passed to -setAdContentView:).
	UIView *view = (UIView *)context;
	
	// Remove the old _adContentView from the view hierarchy, but first confirm that it's
	// not the same as view; otherwise, we'll be left with no content view.
	if (view != _adContentView)
		[_adContentView removeFromSuperview];
	
	// Release _adContentView regardless of whether it was the same as view, since 
	// -setAdContentView: retained it.
	[_adContentView release];
	
	_adContentView = view;
}

- (CGSize)adContentViewSize
{
	return (!_adContentView) ? MOPUB_BANNER_SIZE : _adContentView.bounds.size;
}

- (void)setIgnoresAutorefresh:(BOOL)ignoresAutorefresh
{
	_ignoresAutorefresh = ignoresAutorefresh;
	
	if (_ignoresAutorefresh) 
	{
		MPLogInfo(@"Ad view (%p) is now ignoring autorefresh.", self);
		if ([self.autorefreshTimer isScheduled]) [self.autorefreshTimer pause];
	}
	else 
	{
		MPLogInfo(@"Ad view (%p) is no longer ignoring autorefresh.", self);
		if ([self.autorefreshTimer isScheduled]) [self.autorefreshTimer resume];
	}
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
	// Pass along this notification to the adapter, so that it can handle the orientation change.
	[_currentAdapter rotateToOrientation:newOrientation];
}

- (void)loadAd
{
	[self loadAdWithURL:nil];
}

- (void)refreshAd
{
	[self.autorefreshTimer invalidate];
	[self loadAdWithURL:nil];
}

- (void)forceRefreshAd
{
	// Cancel any existing request to the ad server.
	[_conn cancel];
	
	_isLoading = NO;
	[self.autorefreshTimer invalidate];
	[self loadAdWithURL:nil];
}

- (void)loadAdWithURL:(NSURL *)URL
{
	// If this ad view is already loading a request, don't proceed; instead, wait
	// for the previous load to finish.
	if (_isLoading) 
	{
		MPLogWarn(@"Ad view (%p) is already loading an ad, wait to finish.", self);
		return;
	}
	
	// If the passed-in URL is nil, construct a URL from our initial parameters.
	if (!URL)
	{
		NSString *urlString = [NSString stringWithFormat:@"http://%@/m/ad?v=3&udid=%@&q=%@&id=%@", 
							   HOSTNAME,
							   [[UIDevice currentDevice] hashedMoPubUDID],
							   [self.keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							   [self.adUnitId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
							   ];
		
		// Append location data if we have it.
		if (self.location)
		{
			urlString = [urlString stringByAppendingFormat:@"&ll=%f,%f",
						 self.location.coordinate.latitude,
						 self.location.coordinate.longitude];
		}
		
		URL = [NSURL URLWithString:urlString];
	}
	
	self.URL = URL;
	MPLogDebug(@"Ad view (%p) calling loadAdWithURL: %@", self, URL);
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:self.URL 
																 cachePolicy:NSURLRequestUseProtocolCachePolicy 
															 timeoutInterval:3.0] autorelease];
	
	// Set the user agent so that we know where the request is coming from. 
	// This is important for targeting!
	if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) 
	{
		NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
		NSString *systemName = [[UIDevice currentDevice] systemName];
		NSString *model = [[UIDevice currentDevice] model];
		NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
		NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];			
		NSString *userAgentString = [NSString stringWithFormat:@"%@/%@ (%@; U; CPU %@ %@ like Mac OS X; %@)",
									 bundleName, appVersion, model,
									 systemName, systemVersion, [[NSLocale currentLocale] localeIdentifier]];
		[request setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
	}		
	
	[_conn release];
	_conn = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
	MPLogInfo(@"Ad view (%p) fired initial ad request.", self);
	_isLoading = YES;
}

- (void)didCloseAd:(id)sender
{
	if ([_adContentView isKindOfClass:[UIWebView class]])
		[(UIWebView *)_adContentView stringByEvaluatingJavaScriptFromString:@"webviewDidClose();"];
	
	if ([self.delegate respondsToSelector:@selector(adViewShouldClose:)])
		[self.delegate adViewShouldClose:self];
}

- (void)adViewDidAppear
{
	if ([_adContentView isKindOfClass:[UIWebView class]])
		[(UIWebView *)_adContentView stringByEvaluatingJavaScriptFromString:@"webviewDidAppear();"];
}

- (void)customEventDidLoadAd
{
	_isLoading = NO;
	[self trackImpression];
}

- (void)customEventDidFailToLoadAd
{
	_isLoading = NO;
	[self loadAdWithURL:self.failURL];
}

# pragma mark -
# pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	// If the response is anything but a 200 (OK) or 300 (redirect), consider it a failure and bail.
	if ([response respondsToSelector:@selector(statusCode)])
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400)
		{
			[connection cancel];
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
																		  NSLocalizedString(@"Server returned status code %d",@""),
																		  statusCode]
																  forKey:NSLocalizedDescriptionKey];
			NSError *statusError = [NSError errorWithDomain:@"mopub.com"
													   code:statusCode
												   userInfo:errorInfo];
			[self connection:connection didFailWithError:statusError];
			return;
		}
	}
	
	MPLogInfo(@"Ad view (%p) received valid response from MoPub server.", self);
	
	// Initialize data.
	[_data setLength:0];
	
	if ([self.delegate respondsToSelector:@selector(adViewDidReceiveResponseParams:)])
		[self.delegate adViewDidReceiveResponseParams:[(NSHTTPURLResponse*)response allHeaderFields]];
	
	// Parse response headers, set relevant URLs and booleans.
	NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
	NSString *urlString = nil;
	
	urlString = [headers objectForKey:@"X-Clickthrough"];
	self.clickURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	urlString = [headers objectForKey:@"X-Launchpage"];
	self.interceptURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	urlString = [headers objectForKey:@"X-Failurl"];
	self.failURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	urlString = [headers objectForKey:@"X-Imptracker"];
	self.impTrackerURL = urlString ? [NSURL URLWithString:urlString] : nil;
	
	NSString *shouldInterceptLinksString = [headers objectForKey:@"X-Interceptlinks"];
	if (shouldInterceptLinksString)
		self.shouldInterceptLinks = [shouldInterceptLinksString boolValue];
	
	NSString *scrollableString = [headers objectForKey:@"X-Scrollable"];
	if (scrollableString)
		self.scrollable = [scrollableString boolValue];
	
	NSString *widthString = [headers objectForKey:@"X-Width"];
	NSString *heightString = [headers objectForKey:@"X-Height"];
	
	// Try to get the creative size from the server or otherwise use the original container's size
	if (widthString && heightString)
		self.creativeSize = CGSizeMake([widthString floatValue], [heightString floatValue]);
	else
		self.creativeSize = _originalSize;
	
	// Create the autorefresh timer, which will be scheduled either when the ad appears,
	// or if it fails to load.
	NSString *refreshString = [headers objectForKey:@"X-Refreshtime"];
	if (refreshString && !self.ignoresAutorefresh)
	{
		NSTimeInterval interval = [refreshString doubleValue];
		interval = (interval >= MINIMUM_REFRESH_INTERVAL) ? interval : MINIMUM_REFRESH_INTERVAL;
		self.autorefreshTimer = [MPTimer timerWithTimeInterval:interval
														target:self 
													  selector:@selector(forceRefreshAd) 
													  userInfo:nil 
													   repeats:NO];
	}
	
	NSString *animationString = [headers objectForKey:@"X-Animation"];
	if (animationString)
		_animationType = [animationString intValue];
	
	// Determine ad type.
	NSString *typeHeader = [[(NSHTTPURLResponse *)response allHeaderFields] 
								objectForKey:@"X-Adtype"];
	
	// Dispose of the last adapter stored in _previousAdapter.
	[_previousAdapter unregisterDelegate];
	[_previousAdapter release];
	_previousAdapter = nil;
	
	if (!typeHeader || [typeHeader isEqualToString:@"html"])
	{
		// HTML ad, so just return. connectionDidFinishLoading: will take care of the rest.
		return;
	}
	else if ([typeHeader isEqualToString:@"clear"])
	{
		// Show a blank.
		MPLogInfo(@"*** CLEAR ***");
		[connection cancel];
		_isLoading = NO;
		[self backFillWithNothing];
		return;
	}
	
	// Obtain adapter for specified ad type.
	NSString *classString = [[MPAdapterMap sharedAdapterMap] classStringForAdapterType:typeHeader];
	Class cls = NSClassFromString(classString);
	if (cls != nil)
	{
		// Create a new adapter and update _previousAdapter.
		_previousAdapter = _currentAdapter;
		_currentAdapter = (MPBaseAdapter *)[[cls alloc] initWithAdView:self];
		
		[connection cancel];
		
		// Tell adapter to fire off ad request.
		NSDictionary *params = [(NSHTTPURLResponse *)response allHeaderFields];
		[_currentAdapter getAdWithParams:params];
	}
	// Else: no adapter for the specified ad type, so just fail over.
	else 
	{
		[connection cancel];
		_isLoading = NO;
		
		[self loadAdWithURL:self.failURL];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
	[_data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	MPLogError(@"Ad view (%p) failed to get a valid response from MoPub server. Error: %@", self, error);
	
	// If the initial request to MoPub fails, replace the current ad content with a blank.
	_isLoading = NO;
	[self backFillWithNothing];
	[self scheduleAutorefreshTimer];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Generate a webview to contain the HTML.
	UIWebView *webView = [[self makeAdWebViewWithFrame:(CGRect){{0, 0}, self.creativeSize}] retain];
	webView.delegate = self;
	[webView loadData:_data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:self.URL];
	
	// Print out the response, for debugging.
	NSString *response = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
	MPLogTrace(@"Ad view (%p) loaded HTML content: %@", self, response);
	[response release];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *URL = [request URL];
	
	// Handle the custom mopub:// scheme.
	if ([[URL scheme] isEqualToString:@"mopub"])
	{
		NSString *host = [URL host];
		if ([host isEqualToString:@"close"])
		{
			[self didCloseAd:nil];
		}
		else if ([host isEqualToString:@"finishLoad"])
		{
			_isLoading = NO;
			
			[self setAdContentView:webView];
			
			// Previously retained in -connectionDidFinishLoading, so we have to release here.
			[webView release];
			
			[self scheduleAutorefreshTimer];
			
			// Notify delegate that an ad has been loaded.
			if ([self.delegate respondsToSelector:@selector(adViewDidLoadAd:)]) 
				[self.delegate adViewDidLoadAd:self];
		}
		else if ([host isEqualToString:@"failLoad"])
		{
			_isLoading = NO;
			
			// Previously retained in -connectionDidFinishLoading, so we have to release here.
			[webView release];
			
			// Start a new request using the fall-back URL.
			[self loadAdWithURL:self.failURL];
		}
		else if ([host isEqualToString:@"inapp"])
		{
			NSDictionary *queryDict = [self dictionaryFromQueryString:[URL query]];
			[_store initiatePurchaseForProductIdentifier:[queryDict objectForKey:@"id"] 
												quantity:[[queryDict objectForKey:@"num"] intValue]];
		}
		
		return NO;
	}
	
	// Intercept non-click forms of navigation (e.g. "window.location = ...") if the target URL
	// has the interceptURL prefix. Launch the ad browser.
	if (navigationType == UIWebViewNavigationTypeOther && 
		self.shouldInterceptLinks && 
		self.interceptURL &&
		[[URL absoluteString] hasPrefix:[self.interceptURL absoluteString]])
	{
		[self adLinkClicked:URL];
		return NO;
	}
	
	// Launch the ad browser for all clicks (if shouldInterceptLinks is YES).
	if (navigationType == UIWebViewNavigationTypeLinkClicked && self.shouldInterceptLinks)
	{
		[self adLinkClicked:URL];
		return NO;
	}
	
	// Other stuff (e.g. JavaScript) should load as usual.
	return YES;
}

#pragma mark -
#pragma mark MPAdBrowserControllerDelegate

- (void)dismissBrowserController:(MPAdBrowserController *)browserController
{
	_adActionInProgress = NO;
	[[self.delegate viewControllerForPresentingModalView] dismissModalViewControllerAnimated:YES];
	
	if ([self.delegate respondsToSelector:@selector(didDismissModalViewForAd:)])
		[self.delegate didDismissModalViewForAd:self];
	
	if (_autorefreshTimerNeedsScheduling)
	{
		[self.autorefreshTimer scheduleNow];
		_autorefreshTimerNeedsScheduling = NO;
	}
	else if ([self.autorefreshTimer isScheduled])
		[self.autorefreshTimer resume];
}

#pragma mark -
#pragma mark MPAdapterDelegate

- (void)adapterDidFinishLoadingAd:(MPBaseAdapter *)adapter
{	
	_isLoading = NO;
	[self trackImpression];
	[self scheduleAutorefreshTimer];
	
	if ([self.delegate respondsToSelector:@selector(adViewDidLoadAd:)])
		[self.delegate adViewDidLoadAd:self];
}

- (void)adapter:(MPBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
	// Ignore fail messages from the previous adapter.
	if (adapter == _previousAdapter) return;
	
	_isLoading = NO;
	MPLogError(@"Adapter (%p) failed to load ad. Error: %@", adapter, error);
	
	// Dispose of the current adapter, because we don't want it to try loading again.
	[_currentAdapter unregisterDelegate];
	[_currentAdapter release];
	_currentAdapter = nil;
	
	// Start a new request using the fall-back URL.
	if (!_adActionInProgress)
		[self loadAdWithURL:self.failURL];
	else
		[self scheduleAutorefreshTimer];
}

- (void)userActionWillBeginForAdapter:(MPBaseAdapter *)adapter
{
	_adActionInProgress = YES;
	[self trackClick];
	
	if ([self.autorefreshTimer isScheduled])
		[self.autorefreshTimer pause];
	
	// Notify delegate that the ad will present a modal view / disrupt the app.
	if ([self.delegate respondsToSelector:@selector(willPresentModalViewForAd:)])
		[self.delegate willPresentModalViewForAd:self];
}

- (void)userActionDidEndForAdapter:(MPBaseAdapter *)adapter
{
	_adActionInProgress = NO;
	
	if (_autorefreshTimerNeedsScheduling)
	{
		[self.autorefreshTimer scheduleNow];
		_autorefreshTimerNeedsScheduling = NO;
	}
	else if ([self.autorefreshTimer isScheduled])
		[self.autorefreshTimer resume];
	
	// Notify delegate that the ad's modal view was dismissed, returning focus to the app.
	if ([self.delegate respondsToSelector:@selector(didDismissModalViewForAd:)])
		[self.delegate didDismissModalViewForAd:self];
}

#pragma mark -
#pragma mark Internal

- (void)scheduleAutorefreshTimer
{
	if (!_adActionInProgress) [self.autorefreshTimer scheduleNow];
	else 
	{
		MPLogDebug(@"Ad action in progress: MPTimer will be scheduled after action ends.");
		_autorefreshTimerNeedsScheduling = YES;
	}
}

- (void)setScrollable:(BOOL)scrollable forView:(UIView *)view
{
	// For webviews, find all subviews that are UIScrollViews or subclasses
	// and set their scrolling and bounce.
	if ([view isKindOfClass:[UIWebView class]])
	{
		UIScrollView *scrollView = nil;
		for (UIView *v in view.subviews)
		{
			if ([v isKindOfClass:[UIScrollView class]])
			{
				scrollView = (UIScrollView *)v;
				scrollView.scrollEnabled = scrollable;
				scrollView.bounces = scrollable;
			}
		}
	}
	// For normal UIScrollView subclasses, use the provided setter.
	else if ([view isKindOfClass:[UIScrollView class]])
	{
		[(UIScrollView *)view setScrollEnabled:scrollable];
	}
}

- (UIWebView *)makeAdWebViewWithFrame:(CGRect)frame
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	if (self.stretchesWebContentToFill)
		webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webView.backgroundColor = [UIColor clearColor];
	webView.opaque = NO;
	webView.delegate = self;
	return [webView autorelease];
}

- (void)adLinkClicked:(NSURL *)URL
{
	_adActionInProgress = YES;
	
	// Construct the URL that we want to load in the ad browser, using the click-tracking URL.
	NSString *redirectURLString = [[URL absoluteString] URLEncodedString];	
	NSURL *desiredURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&r=%@",
											  _clickURL,
											  redirectURLString]];
	
	// Notify delegate that the ad browser is about to open.
	if ([self.delegate respondsToSelector:@selector(willPresentModalViewForAd:)])
		[self.delegate willPresentModalViewForAd:self];
	
	if ([self.autorefreshTimer isScheduled])
		[self.autorefreshTimer pause];
	
	// Present ad browser.
	MPAdBrowserController *browserController = [[MPAdBrowserController alloc] initWithURL:desiredURL 
																				 delegate:self];
	[[self.delegate viewControllerForPresentingModalView] presentModalViewController:browserController 
																			animated:YES];
	[browserController release];
}

- (void)backFillWithNothing
{
	// Make the ad view disappear.
	self.backgroundColor = [UIColor clearColor];
	self.hidden = YES;
	
	// Notify delegate that the ad has failed to load.
	if ([self.delegate respondsToSelector:@selector(adViewDidFailToLoadAd:)])
		[self.delegate adViewDidFailToLoadAd:self];
}

- (void)trackClick
{
	NSURLRequest *clickURLRequest = [NSURLRequest requestWithURL:self.clickURL];
	[NSURLConnection connectionWithRequest:clickURLRequest delegate:nil];
	MPLogDebug(@"Ad view (%p) tracking click %@", self, self.clickURL);
}

- (void)trackImpression
{
	NSURLRequest *impTrackerURLRequest = [NSURLRequest requestWithURL:self.impTrackerURL];
	[NSURLConnection connectionWithRequest:impTrackerURLRequest delegate:nil];
	MPLogDebug(@"Ad view (%p) tracking impression %@", self, self.impTrackerURL);
}

- (NSDictionary *)dictionaryFromQueryString:(NSString *)query
{
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithCapacity:1];
	NSArray *queryElements = [query componentsSeparatedByString:@"&"];
	for (NSString *element in queryElements) {
		NSArray *keyVal = [element componentsSeparatedByString:@"="];
		NSString *key = [keyVal objectAtIndex:0];
		NSString *value = [keyVal lastObject];
		[queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
					  forKey:key];
	}
	return [queryDict autorelease];
}

# pragma mark -
# pragma UIApplicationNotification responders

- (void)applicationDidEnterBackground
{
	[self.autorefreshTimer pause];
}

- (void)applicationWillEnterForeground
{
	[self forceRefreshAd];
}


@end



#pragma mark -
#pragma mark Categories

@implementation UIDevice (MPAdditions)

- (NSString *)hashedMoPubUDID 
{
	NSString *result = nil;
	NSString *udid = [NSString stringWithFormat:@"mopub-%@", [[UIDevice currentDevice] uniqueIdentifier]];
	
	if (udid) 
	{
		unsigned char digest[16];
		NSData *data = [udid dataUsingEncoding:NSASCIIStringEncoding];
		CC_MD5([data bytes], [data length], digest);
		
		result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				  digest[0], digest[1], 
				  digest[2], digest[3],
				  digest[4], digest[5],
				  digest[6], digest[7],
				  digest[8], digest[9],
				  digest[10], digest[11],
				  digest[12], digest[13],
				  digest[14], digest[15]];
		result = [result uppercaseString];
	}
	return [NSString stringWithFormat:@"md5:%@", result];
}

@end

@implementation NSString (MPAdditions)

- (NSString *)URLEncodedString
{
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																		   (CFStringRef)self,
																		   NULL,
																		   (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
																		   kCFStringEncodingUTF8);
	return result;
}

@end

