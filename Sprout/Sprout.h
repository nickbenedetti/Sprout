//
//  Sprout.h
//
//  Created by Levi Brown on October 4, 2012.
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
 Sprout is used to bootstrap the (excellent) CocoaLumberjack https://github.com/robbiehanson/CocoaLumberjack logging framework.
 
 In the simplest case, setup is just:
 
 - Add `Sprout.h` to your precompiled header:
 
        #ifdef __OBJC__
        #import <Foundation/Foundation.h>
        //Third Party
        #import "Sprout.h"
        #endif
 
 - Start Logging in your `application:didFinishLaunchingWithOptions:` UIApplicationDelegate
 
        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
        {
            //Initialize logging
            [[Sprout sharedInstance] startLogging];
            //. . .
 
 - Define `DEBUG`
 In your Preprocessor Macros target build settings, define `DEBUG=1` (this may not be needed, as it is a default setting in later XCode project templates).
 
 - Run!
 After the above setup, you should be able to run and see:
 
        CocoaLumberjack loggers initialized!
 
 appear in your console.
 
 To use with Crashlytics http://crashlytics.com :
 
 If you have Crashlytics installed, Sprout will automatically add the `CrashlyticsLogger` to send log messages to the `CLSLog` Crashlytics SDK logger at your current log level.
 @warning If you're using Crashlytics you should initialize Sprout before calling `Crashlytics startWithAPIKey:`
*/

#ifndef _SPROUT_H
#define _SPROUT_H

#import <Foundation/Foundation.h>

#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "CrashlyticsLogger.h"
#import "SproutDDLogAdditions.h"

//Set the logging level and optional loggers

//File logging is always enabled
#define SPROUT_FILE_LOGGING 1

//Here we set the default log levels
//If `SPROUT_LOG_LEVEL` is defined, then it will be used,
//otherwise the log level defaults to `LOG_LEVEL_VERBOSE` if `DEBUG` is defined and
//the log level defaults to `LOG_LEVEL_WARN` if `DEBUG` is not defined.
//By default, dynamic log levels are enabled, and `setLogLevel:` can be used to set the log level at runtime dynamically,
//however if `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL` is defined, the log level is static.

#if DEBUG
    #if SPROUT_DISABLE_DYNAMIC_LOG_LEVEL
        #ifdef SPROUT_LOG_LEVEL
            static const int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static const int ddLogLevel = LOG_LEVEL_VERBOSE;
        #endif
    #else
        #ifdef SPROUT_LOG_LEVEL
            static int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static int ddLogLevel = LOG_LEVEL_VERBOSE;
        #endif
    #endif
    #define SPROUT_CONSOLE_LOGGING 1
#else
    #if SPROUT_DISABLE_DYNAMIC_LOG_LEVEL
        #ifdef SPROUT_LOG_LEVEL
            static const int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static const int ddLogLevel = LOG_LEVEL_WARN;
        #endif
    #else
        #ifdef SPROUT_LOG_LEVEL
            static int ddLogLevel = SPROUT_LOG_LEVEL;
        #else
            static int ddLogLevel = LOG_LEVEL_WARN;
        #endif
    #endif
#endif

//Sprout's internal loggers use this context.
#define SPROUT_LOG_CONTEXT 60221413

//Sprout's internal logging level
#if DEBUG
    static const int sproutInternalLogLevel = LOG_LEVEL_VERBOSE;
#else
    static const int sproutInternalLogLevel = LOG_LEVEL_INFO;
#endif

@interface Sprout : NSObject

#pragma mark - Properties

/**
 * @return `YES` if Sprout has configured CocoaLumberjack
 */
@property (nonatomic,assign,readonly) BOOL started;
/**
 * @return The `DDFileLogger` used to write log statements to files.
 */
@property (nonatomic,strong,readonly) DDFileLogger *fileLogger;
/**
 * @return The `DDTTYLogger` used to write log statements to the console.
 */
@property (nonatomic,strong,readonly) DDTTYLogger *ttyLogger;
/**
 * @return The `CrashlyticsLogger` used to write log statements to Crashlytics, or `nil` if Crashlytics logging is disabled.
 */
@property (nonatomic,strong,readonly) CrashlyticsLogger *crashlyticsLogger;
/**
 * An NSArray of objects conforming to the DDLogger protocol which are the default installed loggers.
 * Set this to an empty array to have no default loggers. Setting it to `nil` will use the defaults.
 * Changes to this property should be made before a call to `startLogging`.
 */
@property (nonatomic,strong) NSArray *defaultLoggers;
/**
 * The default log formatter.
 * Set this to a class implementing the `DDLogFormatter` protocol prior to calling `startLogging` to set a custom log formatter.
 * This defaults to `SproutCustomLogFormatter.class`
 */
@property (nonatomic,strong) Class<DDLogFormatter> defaultLogFormatterClass;
/**
 * @return The `NSFileManager` used to perform file based operations.
 */
@property (nonatomic,strong,readonly) NSFileManager *fileManager;

#pragma mark - Startup

/**
 * @return The singleton instance of `Sprout`
 */
+ (Sprout *)sharedInstance;

/**
 * Configures CocoaLumberjack for logging, and attaches signal handlers, etc.
 * After this is called, `started` will be `YES`
 */
- (void)startLogging;

#if !SPROUT_DISABLE_DYNAMIC_LOG_LEVEL

#pragma mark - Log Level

/**
 * Sets the logging level to that specified.
 * @param logLevel The new log level to be used. Takes affect immediately.
 * @warning If `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL` is defined, this functionality is disabled.
 * @see https://github.com/robbiehanson/CocoaLumberjack/wiki/DynamicLogLevels
 * Default CocoaLumberjack has these log levels defined:
 *
 *   LOG_LEVEL_OFF
 *   LOG_LEVEL_ERROR
 *   LOG_LEVEL_WARN
 *   LOG_LEVEL_INFO
 *   LOG_LEVEL_VERBOSE
 */
- (void)setLogLevel:(int)logLevel;
#endif

#pragma mark - Logging Utilities

/**
 * Outputs a log statement at LOG_LEVEL_INFO with the app name, bundle identifier, versions (CFBundleShortVersionString and CFBundleVersion), device model, OS name and version.
 */
- (void)logAppAndDeviceInfo;

/**
 * @return An `NSArray` of `NSString` objects containing the full path to the most recent (up to 10) log files.
 */
- (NSArray *)logFiles;

#pragma mark - Loggers

/**
 * Adds the given logger to CocoaLumberjack, with log level `LOG_LEVEL_ALL`, after configuring it with an instance of the default log formatter specified by the `defaultLogFormatterClass` property.
 *
 * @param logger The logger to add.
 */
- (void)addLogger:(id <DDLogger>)logger;

/**
 * Adds the given logger to CocoaLumberjack, with the specified log level, after configuring it with an instance of the default log formatter specified by the `defaultLogFormatterClass` property.
 *
 * @param logger The logger to add.
 */
- (void)addLogger:(id <DDLogger>)logger withLogLevel:(int)logLevel;

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

#pragma mark - Potential Overrides

/**
 * Adds the loggers from the `defaultLoggers` property to CocoaLumberjack
 */
- (void)addDefaultLoggers;
/**
 * Creates a new instance of the DDLogFormatter specified by the `defaultLogFormatterClass` property.
 *
 * @return A new instance of the default DDLogFormatter
 */
- (id<DDLogFormatter>)createDefaultLogFormatter;
/**
 * Setup the console (TTY) logger
 */
- (DDTTYLogger *)setupTTYLogger;
/**
 * Setup the File logger
 */
- (DDFileLogger *)setupFileLogger;
/**
 * Setup the Crashlytics logger
 */
- (CrashlyticsLogger *)setupCrashlyticsLogger;

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
- (NSString *)tempDirectory;
- (NSString *)UUID;

@end

#endif /* _SPROUT_H */
