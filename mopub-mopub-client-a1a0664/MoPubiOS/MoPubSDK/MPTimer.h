//
//  MPTimer.h
//  MoPub
//
//  Created by Andrew He on 3/8/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPTimer : NSObject {
	NSTimer *_timer;
	BOOL _isPaused;
	NSTimeInterval _secondsLeft;
	NSDate *_pauseDate;
}

+ (MPTimer *)timerWithTimeInterval:(NSTimeInterval)seconds target:(id)target 
						  selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats;

- (BOOL)isValid;
- (void)invalidate;
- (BOOL)isScheduled;
- (void)scheduleNow;
- (void)pause;
- (void)resume;

@end
