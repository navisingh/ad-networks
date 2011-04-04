//
//  RootViewController.h
//  InMobiSampleApp_iPhone
//
//  Created by Rishabh Chowdhary on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InMobiAdView.h"
#import "InMobiAdDelegate.h"
#import "InMobiEnumTypes.h"

@interface RootViewController : UIViewController <InMobiAdDelegate> {
	InMobiAdView *inmobiAdView;
	NSTimer *timer;
}

@property( nonatomic, retain) InMobiAdView *inmobiAdView;
@end
