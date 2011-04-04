//
//  SimpleAdsAppDelegate.h
//  Copyright (c) 2010 MoPub Inc.
//

#import <UIKit/UIKit.h>

@class SimpleAdsViewController;
@class MPInterstitialAdController;

@interface SimpleAdsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController* tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController* tabBarController;

@end

