//
//  iPadTestAppDelegate.h
//  iPadTest
//
//  Created by Nafis Jamal on 3/15/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iPadTestViewController;

@interface iPadTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iPadTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPadTestViewController *viewController;

@end

