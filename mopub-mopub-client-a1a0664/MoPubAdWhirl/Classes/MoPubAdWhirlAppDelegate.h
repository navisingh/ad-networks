//
//  MoPubAdWhirlAppDelegate.h
//  MoPubAdWhirl
//
//  Created by Nafis Jamal on 3/19/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoPubAdWhirlViewController;

@interface MoPubAdWhirlAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MoPubAdWhirlViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MoPubAdWhirlViewController *viewController;

@end

