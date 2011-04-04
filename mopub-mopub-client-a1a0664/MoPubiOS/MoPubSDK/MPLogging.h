//
//  MPLogging.h
//  MoPub
//
//  Created by Andrew He on 2/10/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Lower = finer-grained logs.
typedef enum 
{
	MPLogLevelAll		= 0,
	MPLogLevelTrace		= 10,
	MPLogLevelDebug		= 20,
	MPLogLevelInfo		= 30,
	MPLogLevelWarn		= 40,
	MPLogLevelError		= 50,
	MPLogLevelFatal		= 60,
	MPLogLevelOff		= 70
} MPLogLevel;

void MPLogSetLevel(MPLogLevel level);
void MPLogTrace(NSString *format, ...);
void MPLogDebug(NSString *format, ...);
void MPLogInfo(NSString *format, ...);
void MPLogWarn(NSString *format, ...);
void MPLogError(NSString *format, ...);
void MPLogFatal(NSString *format, ...);
