//
//  InMobiSampleApp_iPadAppDelegate.h
//  InMobiSampleApp_iPad
//
//  Created by Rishabh Chowdhary on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface InMobiSampleApp_iPadAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) RootViewController *rootViewController;

@end

