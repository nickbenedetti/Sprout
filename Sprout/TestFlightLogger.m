//
//  TestFlightLogger.m
//
//  Created by Levi Brown on October 4, 2012.
//  Copyright (c) 2012, 2013, 2014 Levi Brown <mailto:levigroker@gmail.com>
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

#import "TestFlightLogger.h"

//Declare the TFLog function from TestFlight as weak, and then supply a bogus implementation
//which will get replaced by the actual (strongly referenced) function if TestFlight is linked.
//The check in `init` for the TestFlight class is intended to prevent this function from being executed.
OBJC_EXTERN void TFLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) __attribute__((weak));
void TFLog(NSString *format, ...) {
    printf("[ERROR] TestFlightLogger: TFLog() unimplemented!");
};

//Similarlly, define TestFlight constants we use, as weak.
NSString *const TFOptionLogToConsole __attribute__((weak));
NSString *const TFOptionLogToSTDERR __attribute__((weak));

@implementation TestFlightLogger

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceQueue;
    static TestFlightLogger *retVal = nil;
    
    dispatch_once(&onceQueue, ^{ retVal = [[self alloc] init]; });
    return retVal;
}

- (instancetype)init
{
    TestFlightLogger *retVal = nil;
    
    //Check to see if we have TestFlight installed and if we do, return our instance, otherwise return `nil`
    Class cls = NSClassFromString (@"TestFlight");
    if (cls)
    {
        self = [super init];
        if (self)
        {
            retVal = self;
            //Call TestFlight's setOptions: such that we do not log to the console or STDERR (since CocoaLumberjack will log where we want)
            SEL selector = NSSelectorFromString(@"setOptions:");
            IMP imp = [[cls class] methodForSelector:selector];
            void (*func)(id, SEL, NSDictionary *) = (void *)imp;
            func([cls class], selector, @{ TFOptionLogToConsole: @NO, TFOptionLogToSTDERR: @NO });
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
        TFLog(@"%@", logMsg);
    }
}

- (NSString *)loggerName
{
	return @"cocoa.lumberjack.testFlightLogger";
}

@end
