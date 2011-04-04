//
//  MPGoogleAdSenseAdapter.h
//  MoPub
//
//  Created by Andrew He on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBaseAdapter.h"
#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"

@interface MPGoogleAdSenseAdapter : MPBaseAdapter <GADAdViewControllerDelegate> 
{
	GADAdViewController *_adViewController;
}

@end
