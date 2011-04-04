//
//  IBAdViewController.h
//  InMobiSampleApp_iPhone
//

//

#import <UIKit/UIKit.h>
#import "InMobiAdView.h"
#import "InMobiAdDelegate.h"
#import "InMobiEnumTypes.h"

@interface IBAdViewController : UIViewController <InMobiAdDelegate> {
	
	IBOutlet InMobiAdView *inmobiAdView;
	NSTimer *timer;
}

@property(nonatomic,retain) InMobiAdView *inmobiAdView;
- (void)loadInMobiAd;
@end

