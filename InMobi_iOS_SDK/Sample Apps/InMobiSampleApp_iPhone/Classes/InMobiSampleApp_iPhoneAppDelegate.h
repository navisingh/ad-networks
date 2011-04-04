//
//  InMobiSampleApp_iPhoneAppDelegate.h
//  InMobiSampleApp_iPhone
//

//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface InMobiSampleApp_iPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *viewController;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

