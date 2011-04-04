//
//  SimpleAdsViewController.h
//  Copyright (c) 2010 MoPub Inc.
//
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import "SecondViewController.h"

#define PUB_ID_320x50 @"agltb3B1Yi1pbmNyDAsSBFNpdGUYkaoMDA"
#define PUB_ID_300x250 @"agltb3B1Yi1pbmNyDAsSBFNpdGUYycEMDA"

@class InterstitialAdController;

@interface SimpleAdsViewController : UIViewController <UITextFieldDelegate, MPAdViewDelegate, MPInterstitialAdControllerDelegate> {
	IBOutlet UITextField* keyword;
	IBOutlet UIView* adView;
	IBOutlet UIView* mrectView;
	
	MPAdView* mpAdView;
	MPAdView* mpMrectView;
}
@property(nonatomic,retain) IBOutlet UITextField* keyword;
@property(nonatomic,retain) IBOutlet UIView* adView;
@property(nonatomic,retain) IBOutlet UIView* mrectView;
@property(nonatomic,retain) MPAdView* mpAdView;
@property(nonatomic,retain) MPAdView* mpMrectView;

-(IBAction) refreshAd;

@end

