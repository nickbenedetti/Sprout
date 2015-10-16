//
//  CrashlyticsLogger.m
//
//  Created by Levi Brown on August 12, 2014.
//  Copyright (c) 2014, 2015 Levi Brown <mailto:levigroker@gmail.com>
//  This work is licensed under the Creative Commons Attribution 3.0
//  Unported License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative
//  Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041,
//  USA.
//
//  The above attribution and the included license must accompany any version
//  of the source code. Visible attribution in any binary distributable
//  including this work (or derivatives) is not required, but would be
//  appreciated.
//

#import "CrashlyticsLogger.h"

//Declare the CLSLog function from Crashlytics as weak, and then supply a bogus implementation
//which will get replaced by the actual (strongly referenced) function if Crashlytics is linked.
//The check in `init` for the Crashlytics class is intended to prevent this function from being executed.
OBJC_EXTERN void CLSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) __attribute__((weak));
void CLSLog(NSString *format, ...) {
    printf("[ERROR] CrashlyticsLogger: CLSLog() unimplemented!");
};

@implementation CrashlyticsLogger

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceQueue;
    static CrashlyticsLogger *retVal = nil;
    
    dispatch_once(&onceQueue, ^{ retVal = [[self alloc] init]; });
    return retVal;
}

- (instancetype)init
{
    CrashlyticsLogger *retVal = nil;
    
    //Check to see if we have Crashlytics installed and if we do, return our instance, otherwise return `nil`
    Class cls = NSClassFromString (@"Crashlytics");
    if (cls)
    {
        self = [super init];
        if (self)
        {
            retVal = self;
        }
    }
    
    return retVal;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = logMessage->logMsg;
    
    if (formatter)
    {
        logMsg = [formatter formatLogMessage:logMessage];
    }
    
    if (logMsg)
    {
        CLSLog(@"%@", logMsg);
    }
}

- (NSString *)loggerName
{
	return @"cocoa.lumberjack.crashlyticsLogger";
}

@end
