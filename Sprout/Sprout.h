//
//  Sprout.h
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

/**
 Sprout is used to bootstrap the (excellent) CocoaLumberjack https://github.com/robbiehanson/CocoaLumberjack logging framework.
 
 Please see the README in the repository:
 https://github.com/levigroker/Sprout

 */

#ifndef _SPROUT_H
#define _SPROUT_H

#import <Foundation/Foundation.h>

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "SproutDDLogAdditions.h"

//C Compatibility
#define SPROUT_LOG_C_MACRO(async, lvl, flg, ctx, frmt, ...) \
LOG_MACRO(async, lvl, flg, ctx, nil, __FUNCTION__, frmt, ##__VA_ARGS__)

//Set the logging level and optional loggers

//File logging is always enabled
#define SPROUT_FILE_LOGGING 1

//Here we set the default log levels
//If `SPROUT_LOG_LEVEL` is defined, then it will be used,
//otherwise the log level defaults to `DDLogLevelVerbose` if `DEBUG` is defined and
//the log level defaults to `DDLogLevelWarning` if `DEBUG` is not defined.
//By default, dynamic log levels are enabled, and `setLogLevel:` can be used to set the log level at runtime dynamically,
//however if `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL` is defined, the log level is static.

#if DEBUG
    #if SPROUT_DISABLE_DYNAMIC_LOG_LEVEL
        #ifdef SPROUT_LOG_LEVEL
            static const int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static const int ddLogLevel = DDLogLevelVerbose;
        #endif
    #else
        #ifdef SPROUT_LOG_LEVEL
            static int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static int ddLogLevel = DDLogLevelVerbose;
        #endif
    #endif
    #define SPROUT_CONSOLE_LOGGING 1
#else
    #if SPROUT_DISABLE_DYNAMIC_LOG_LEVEL
        #ifdef SPROUT_LOG_LEVEL
            static const int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static const int ddLogLevel = DDLogLevelWarning;
        #endif
    #else
        #ifdef SPROUT_LOG_LEVEL
            static int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static int ddLogLevel = DDLogLevelWarning;
        #endif
    #endif
#endif

//Sprout's internal loggers use this context.
#define SPROUT_LOG_CONTEXT 60221413

//Sprout's internal logging level
#if DEBUG
    static const int sproutInternalLogLevel = DDLogLevelVerbose;
#else
    static const int sproutInternalLogLevel = DDLogLevelInfo;
#endif

@interface Sprout : NSObject

#pragma mark - Properties

/**
 A block which can be set to intercept the creation and addition of the set of default loggers to be used.
 The block receives the set of loggers Sprout will use by default and should return the loggers to actually be installed.
 If this property is `nil` the default loggers will be used.
 Changes to this property should be made before a call to `startLogging`.
 */
@property (nonatomic, copy) NSSet<id<DDLogger>> *(^loggersBlock)(NSSet<id<DDLogger>> *defaultLoggers);

/**
 A block which can be set to intercept the creation of the default log formatter.
 The block receives the log formatter Sprout will use by default and should return the log formatter to actually be installed.
 If this property is `nil` the default log formatter will be used.
 Changes to this property should be made before a call to `startLogging`.
 */
@property (nonatomic, copy) id<DDLogFormatter> (^logFormatterBlock)(id<DDLogFormatter> defaultLogFormatter);

/**
 * @return `YES` if Sprout has configured CocoaLumberjack
 */
@property (nonatomic,assign,readonly) BOOL started;

#pragma mark - Startup

/**
 * @return The singleton instance of `Sprout`
 */
+ (Sprout *)sharedInstance;

/**
 * Configures CocoaLumberjack for logging, and attaches signal handlers, etc.
 * This is the same as calling `startLogging:nil`
 * After this is called, `started` will be `YES`
 */
- (void)startLogging;

/**
 * Configures CocoaLumberjack for logging, and attaches signal handlers, etc.
 *
 * @param completion A block to be called after logging has been configured but prior to any logging.
 * After this is called, `started` will be `YES`
 */
- (void)startLogging:(void(^)(void))completion;

#if !SPROUT_DISABLE_DYNAMIC_LOG_LEVEL

#pragma mark - Log Level

/**
 * Sets the logging level to that specified.
 * @param logLevel The new log level to be used. Takes affect immediately.
 * @warning If `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL` is defined, this functionality is disabled.
 * @see https://github.com/robbiehanson/CocoaLumberjack/wiki/DynamicLogLevels
 * Default CocoaLumberjack has these log levels defined:
 *
 *   DDLogLevelOff
 *   DDLogLevelError
 *   DDLogLevelWarning
 *   DDLogLevelInfo
 *   DDLogLevelVerbose
 */
- (void)setLogLevel:(int)logLevel;
#endif

#pragma mark - Logging Utilities

/**
 * Outputs a log statement at DDLogLevelInfo with the app name, bundle identifier, versions (CFBundleShortVersionString and CFBundleVersion), device model, OS name and version.
 */
- (void)logAppAndDeviceInfo;

/**
 * @return An `NSArray` of `NSURL` objects containing the file URLs to the most recent (up to 10) log files. The first item in the array will be the most recently created log file.
 */
- (NSArray *)logFiles;

#pragma mark - Loggers

/**
 * Adds the given logger to CocoaLumberjack, with log level `DDLogLevelAll`, after configuring it with an instance of the default log formatter specified by the `defaultLogFormatterClass` property.
 *
 * @param logger The logger to add.
 */
- (void)addLogger:(id <DDLogger>)logger;

/**
 * Adds the given logger to CocoaLumberjack, with the specified log level, after configuring it with an instance of the default log formatter specified by the `defaultLogFormatterClass` property.
 *
 * @param logger The logger to add.
 */
- (void)addLogger:(id <DDLogger>)logger withLogLevel:(NSUInteger)logLevel;

/**
 * Removes the given logger from CocoaLumberjack
 *
 * @param logger The logger to remove.
 */
- (void)removeLogger:(id <DDLogger>)logger;

/**
 * Removes all loggers from CocoaLumberjack
 */
- (void)removeAllLoggers;

/**
 * Gets all currently installed loggers.
 *
 * @return An NSArray of DDLogger objects which are currently installed into CocoaLumberjack
 */
- (NSArray *)allLoggers;

#pragma mark - Helpers

#pragma mark Device Info

- (NSString *)appVersion;
- (NSString *)appBuildNumber;
- (NSString *)appName;
- (NSString *)appIdentifier;
- (void)deviceName:(NSString **)deviceName deviceModel:(NSString **)deviceModel deviceMachine:(NSString **)deviceMachine systemName:(NSString **)systemName systemVersion:(NSString **)systemVersion;

#pragma mark Misc

+ (NSString *)backtraceSkipping:(NSUInteger)skip length:(NSUInteger)length;
+ (NSArray *)trimmedBacktraceSkipping:(NSUInteger)skip length:(NSUInteger)length;
+ (NSString *)stringForLogLevel:(int)logLevel;

/**
 Returns a URL representing a newly created unique temporary directory.

 @return an NSURL referencing the newly created unique temporary directory, or `nil` if one could not be created.
 */
- (NSURL *)tempDirectory;

@end

#endif /* _SPROUT_H */
