//
//  SmallViewController.h
//  iPadTest
//
//  Created by Nafis Jamal on 3/15/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"


@interface SmallViewController : UIViewController <MPAdViewDelegate> {
	MPAdView *adView;
	UIViewController *parent;
}

@property (nonatomic,retain) UIViewController *parent;

@end
