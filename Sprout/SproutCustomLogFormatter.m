//
//  SproutCustomLogFormatter.m
//
//  Created by Levi Brown on October 4, 2012.
//  Copyright (c) 2012-2017 Levi Brown <mailto:levigroker@gmail.com> This work is
//  licensed under the Creative Commons Attribution 4.0 International License. To
//  view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/
//  or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
//  The above attribution and the included license must accompany any version of
//  the source code, binary distributable, or derivatives.
//

#import "SproutCustomLogFormatter.h"

@implementation SproutCustomLogFormatter

- (id)init
{
    if ((self = [super init]))
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel = nil;
    switch (logMessage->_flag)
    {
		case DDLogFlagError   : logLevel = @"[ERROR]"; break;
		case DDLogFlagWarning : logLevel = @" [WARN]"; break;
		case DDLogFlagInfo    : logLevel = @" [INFO]"; break;
		case DDLogFlagDebug   :
		default               : logLevel = @"[DEBUG]"; break;
    }

	NSString *file = [logMessage->_file lastPathComponent];
    NSString *function = logMessage->_function;
    NSString *timestamp = [self.dateFormatter stringFromDate:(logMessage->_timestamp)];

    char tidCStr[9];
    int tidLen = snprintf(tidCStr, 9, "%x", logMessage->_threadID);
    NSString *threadID = [NSString stringWithCString:tidCStr encoding:NSASCIIStringEncoding];
    threadID = [threadID substringToIndex:MIN((size_t)8, tidLen)];

	return [NSString stringWithFormat:@"%@         <%@> %@(%@ %d)\n%@ %@ %@", timestamp, threadID, function, file, (int)logMessage->_line, timestamp, logLevel, logMessage->_message];
}

@end
