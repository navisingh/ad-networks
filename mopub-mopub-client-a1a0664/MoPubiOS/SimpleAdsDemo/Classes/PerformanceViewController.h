//
//  PerformanceViewController.h
//  SimpleAds
//
//  Created by James Payne on 2/4/11.
//  Copyright 2011 MoPub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

#define PUB_ID_320x50 @"agltb3B1Yi1pbmNyDAsSBFNpdGUYkaoMDA"

@interface PerformanceViewController : UIViewController <MPAdViewDelegate, UITextFieldDelegate> {
	IBOutlet UITextView* console;
	
	IBOutlet UITextField* keyword;
	IBOutlet UIView* adView;
	
	MPAdView* mpAdView;
	
	NSTimeInterval _adRequestStartTime;
}
@property(nonatomic,retain) IBOutlet UITextView* console;

@property(nonatomic,retain) IBOutlet UITextField* keyword;
@property(nonatomic,retain) IBOutlet UIView* adView;
@property(nonatomic,retain) MPAdView* mpAdView;

-(IBAction) refreshAd;
-(void) clearConsole;
-(void) outputLine:(NSString*)line;

@end
