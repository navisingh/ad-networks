//
//  MPIAdAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBaseAdapter.h"
#import <iAd/iAd.h>

@interface MPIAdAdapter : MPBaseAdapter <ADBannerViewDelegate> 
{
	ADBannerView *_adBannerView;
	BOOL _hasReceivedFirstResponse;
}

@end
