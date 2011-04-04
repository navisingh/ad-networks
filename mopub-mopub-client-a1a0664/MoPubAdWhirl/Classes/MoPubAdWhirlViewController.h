//
//  MoPubAdWhirlViewController.h
//  MoPubAdWhirl
//
//  Created by Nafis Jamal on 3/19/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "AdWhirlCustomEventAdapterMoPub.h"

@interface MoPubAdWhirlViewController : UIViewController <AdWhirlDelegate> {
															  
	AdWhirlView *adWhirlView;			
	AdWhirlCustomEventAdapterMoPub *mopubAdapter;
	
}

@property (nonatomic,retain) AdWhirlCustomEventAdapterMoPub *mopubAdapter;

- (void)mopubLoadAd:(AdWhirlView *)awView; 

@end

