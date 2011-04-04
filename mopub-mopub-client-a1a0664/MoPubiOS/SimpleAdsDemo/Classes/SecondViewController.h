//
//  SecondViewController.h
//  SimpleAds
//
//  Created by Nafis Jamal on 9/24/10.
//  Copyright (c) 2010 MoPub Inc.
//

#import <UIKit/UIKit.h>
#import "MPInterstitialAdController.h"

@interface SecondViewController : UIViewController <MPInterstitialAdControllerDelegate> {

}

- (IBAction) showInterstitial:(id)sender;

@end
