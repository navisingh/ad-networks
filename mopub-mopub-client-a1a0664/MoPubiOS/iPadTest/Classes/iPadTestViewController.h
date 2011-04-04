//
//  iPadTestViewController.h
//  iPadTest
//
//  Created by Nafis Jamal on 3/15/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "SmallViewController.h"

@interface iPadTestViewController : UIViewController <MPAdViewDelegate> {
	MPAdView *adView;
}

- (IBAction)refresh;
@end

