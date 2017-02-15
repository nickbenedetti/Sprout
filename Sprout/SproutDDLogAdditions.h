//
//  SproutDDLogAdditions.h
//
//  Created by Levi Brown on November 9, 2015.
//  Copyright (c) 2015-2017 Levi Brown <mailto:levigroker@gmail.com> This work is
//  licensed under the Creative Commons Attribution 4.0 International License. To
//  view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/
//  or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
//  The above attribution and the included license must accompany any version of
//  the source code, binary distributable, or derivatives.
//

/**
 Additional convenience macros for DDLog
*/

#ifndef _SPROUT_DDLOG_ADDITIONS_H
#define _SPROUT_DDLOG_ADDITIONS_H

#import <CocoaLumberjack/CocoaLumberjack.h>

// Synchronous logging regardless of the log level
#define DDLogSyncAlwaysError(frmt, ...)   LOG_MACRO(NO, LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysWarn(frmt, ...)    LOG_MACRO(NO, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysInfo(frmt, ...)    LOG_MACRO(NO, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysDebug(frmt, ...)   LOG_MACRO(NO, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogSyncAlwaysVerbose(frmt, ...) LOG_MACRO(NO, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

// Normal sync/async logging regardless of the log level
#define DDLogAlwaysError(frmt, ...)   LOG_MACRO(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAlwaysWarn(frmt, ...)    LOG_MACRO(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAlwaysInfo(frmt, ...)    LOG_MACRO(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAlwaysDebug(frmt, ...)   LOG_MACRO(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogAlwaysVerbose(frmt, ...) LOG_MACRO(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#endif /* _SPROUT_DDLOG_ADDITIONS_H */
