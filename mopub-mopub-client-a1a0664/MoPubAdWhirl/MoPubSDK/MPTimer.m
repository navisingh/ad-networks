//
//  MPTimer.m
//  MoPub
//
//  Created by Andrew He on 3/8/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPTimer.h"
#import "MPLogging.h"

@interface MPTimer ()
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, copy) NSDate *pauseDate;
@end

@implementation MPTimer

@synthesize timer = _timer;
@synthesize pauseDate = _pauseDate;

+ (MPTimer *)timerWithTimeInterval:(NSTimeInterval)seconds target:(id)target 
						  selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats
{
	MPTimer *m = [[MPTimer alloc] init];
	m.timer = [NSTimer timerWithTimeInterval:seconds 
									  target:target 
									selector:aSelector 
									userInfo:userInfo 
									 repeats:repeats];
	return [m autorelease];
}

- (void)dealloc
{
	[_timer invalidate];
	[_timer release];
	[_pauseDate release];
	[super dealloc];
}

- (BOOL)isValid
{
	return [self.timer isValid];
}

- (void)invalidate
{
	[self.timer invalidate];
}

- (BOOL)isScheduled
{
	CFRunLoopRef runLoopRef = [[NSRunLoop currentRunLoop] getCFRunLoop];
	return CFRunLoopContainsTimer(runLoopRef, (CFRunLoopTimerRef)self.timer, kCFRunLoopDefaultMode);
}

- (void)scheduleNow
{
	if (![self.timer isValid])
	{
		MPLogWarn(@"Could not schedule invalidated MPTimer (%p).", self);
		return;
	}
	
	MPLogDebug(@"Scheduled MPTimer (%p).", self);
	[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)pause
{
	if (![self.timer isValid])
	{
		MPLogWarn(@"Cannot pause invalidated MPTimer (%p).", self);
		return;
	}
	
	NSDate *fireDate = [self.timer fireDate];
	self.pauseDate = [NSDate date];
	_secondsLeft = [fireDate timeIntervalSinceDate:self.pauseDate];
	if (_secondsLeft <= 0)
	{
		// TODO: Don't think this can happen since we're on the run loop thread.
		MPLogWarn(@"An MPTimer was somehow paused after it was supposed to fire.");
		_secondsLeft = 5;
	}
	else MPLogDebug(@"Paused MPTimer (%p) %.1f seconds left before firing.", self, _secondsLeft);
	
	// Pause the timer by setting its fire date far into the future.
	[self.timer setFireDate:[NSDate distantFuture]];
	_isPaused = YES;
}

- (void)resume
{
	if (![self.timer isValid])
	{
		MPLogWarn(@"Cannot resume invalidated MPTimer (%p).", self);
		return;
	}
	
	if (!_isPaused)
	{
		MPLogWarn(@"No-op: tried to resume an MPTimer (%p) that was never paused.", self);
		return;
	}
	
	MPLogDebug(@"Resumed MPTimer (%p), should fire in %.1f seconds.", self, _secondsLeft);
	
	// Resume the timer.
	NSDate *newFireDate = [NSDate dateWithTimeInterval:_secondsLeft sinceDate:[NSDate date]];
	[self.timer setFireDate:newFireDate];
	
	if (![self isScheduled])
		[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
	
	_isPaused = NO;
}

@end
