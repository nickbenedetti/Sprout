//
//  CrashlyticsLogger.m
//
//  Part of "Sprout" https://github.com/levigroker/Sprout
//
//  Created by Levi Brown on August 12, 2014.
//  Copyright (c) 2014-2017 Levi Brown <mailto:levigroker@gmail.com> This work is
//  licensed under the Creative Commons Attribution 4.0 International License. To
//  view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/
//  or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
//  The above attribution and the included license must accompany any version of
//  the source code, binary distributable, or derivatives.
//

#import "CrashlyticsLogger.h"
#import <Crashlytics/Crashlytics.h>

@implementation CrashlyticsLogger

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceQueue;
    static CrashlyticsLogger *retVal = nil;
    
    dispatch_once(&onceQueue, ^{ retVal = [[self alloc] init]; });
    return retVal;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->_message;
    
    if (_logFormatter)
    {
        logMsg = [_logFormatter formatLogMessage:logMessage];
    }
    
    if (logMsg)
    {
		CLSLog(@"%@", logMsg);
    }
}

- (NSString *)loggerName
{
	return @"sprout.cocoalumberjack.crashlyticslogger";
}

@end
