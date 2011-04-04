//
//  InMobiSampleApp_iPhoneViewController.h
//  InMobiSampleApp_iPhone
//

//

#import <UIKit/UIKit.h>
#import "InMobiAdView.h"
#import "InMobiEnumTypes.h"
#import "InMobiAdDelegate.h"

@interface ProgramaticAdViewController : UIViewController <InMobiAdDelegate> {

	InMobiAdView *inmobiAdView;
	NSTimer *timer;
}

@property(nonatomic,retain) InMobiAdView *inmobiAdView;
- (void)loadInMobiAd;
@end

