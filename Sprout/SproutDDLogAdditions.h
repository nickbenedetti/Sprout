//
//  SproutDDLogAdditions.h
//
//  Created by Levi Brown on November 9, 2015.
//  Copyright (c) 2012-2016 Levi Brown <mailto:levigroker@gmail.com>
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

/**
 Additional convenience macros for DDLog
*/

#ifndef _SPROUT_DDLOG_ADDITIONS_H
#define _SPROUT_DDLOG_ADDITIONS_H

#import <CocoaLumberjack/DDLog.h>

// Synchronous logging regardless of the log level
#define DDLogSyncAlwaysError(frmt, ...)   SYNC_LOG_OBJC_MACRO(LOG_LEVEL_DEF, LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysWarn(frmt, ...)    SYNC_LOG_OBJC_MACRO(LOG_LEVEL_DEF, LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysInfo(frmt, ...)    SYNC_LOG_OBJC_MACRO(LOG_LEVEL_DEF, LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysDebug(frmt, ...)   SYNC_LOG_OBJC_MACRO(LOG_LEVEL_DEF, LOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysVerbose(frmt, ...) SYNC_LOG_OBJC_MACRO(LOG_LEVEL_DEF, LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

// Normal sync/async logging regardless of the log level
#define DDLogAlwaysError(frmt, ...)   LOG_OBJC_MACRO(LOG_ASYNC_ERROR,   LOG_LEVEL_DEF, LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define DDLogAlwaysWarn(frmt, ...)    LOG_OBJC_MACRO(LOG_ASYNC_WARN,    LOG_LEVEL_DEF, LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define DDLogAlwaysInfo(frmt, ...)    LOG_OBJC_MACRO(LOG_ASYNC_INFO,    LOG_LEVEL_DEF, LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define DDLogAlwaysDebug(frmt, ...)   LOG_OBJC_MACRO(LOG_ASYNC_DEBUG,   LOG_LEVEL_DEF, LOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define DDLogAlwaysVerbose(frmt, ...) LOG_OBJC_MACRO(LOG_ASYNC_VERBOSE, LOG_LEVEL_DEF, LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

#endif /* _SPROUT_DDLOG_ADDITIONS_H */
