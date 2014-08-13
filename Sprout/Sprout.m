//
//  Sprout.m
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

#include <execinfo.h>

#if TARGET_OS_MAC
#include <sys/sysctl.h>

static NSString * const kSystemVersionPlistLocation = @"/System/Library/CoreServices/SystemVersion.plist";
static NSString * const kSystemVersionKeyProductName = @"ProductName";
static NSString * const kSystemVersionKeyProductUserVisibleVersion = @"ProductUserVisibleVersion";
static NSString * const kSystemVersionKeyProductBuildVersion = @"ProductBuildVersion";

static NSString * const kSysInfoKeyHardwarePlatform = @"hw.model";
#endif

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "Sprout.h"
#import "SproutCustomLogFormatter.h"
#import "SSZipArchive.h"

#define DDLogException(frmt, ...)   LOG_MAYBE(YES, ddLogLevel, LOG_FLAG_ERROR, 0, "Exception Handler", frmt, ##__VA_ARGS__)
#define DDLogSignal(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ERROR, ddLogLevel, LOG_FLAG_ERROR, 0, "Signal Handler", frmt, ##__VA_ARGS__)

void exceptionHandler(NSException *exception);
void signalHandler(int signal);

@interface Sprout ()

@property (nonatomic,assign) BOOL started;
@property (nonatomic,strong) DDFileLogger *fileLogger;
@property (nonatomic,strong) DDTTYLogger *ttyLogger;
@property (nonatomic,strong) TestFlightLogger *testFlightLogger;
@property (nonatomic,strong) CrashlyticsLogger *crashlyticsLogger;
@property (nonatomic,strong) NSFileManager *fileManager;

@end

void exceptionHandler(NSException *exception)
{
    DDLogException(@"Exception: %@\nCall stack:\n%@", exception, [exception callStackSymbols]);
}

void signalHandler(int signal)
{
    NSString *signalSring = @"unknown";
    switch (signal)
    {
        case SIGABRT:
            signalSring = @"SIGABRT";
            break;
        case SIGILL:
            signalSring = @"SIGILL";
            break;
        case SIGBUS:
            signalSring = @"SIGBUS";
            break;
        case SIGSEGV:
            signalSring = @"SIGSEGV";
            break;
        default:
            break;
    }
    NSString *backtrace = [Sprout backtraceSkipping:2 /* Skip the backrace method and this signal handler */ length:20 /* Get the next 20 stack frames */];
    DDLogSignal(@"Recieved %@ signal. Call stack:\n%@", signalSring, backtrace);
}

@implementation Sprout

#pragma mark - Lifecycle

+ (Sprout *)sharedInstance
{
    static dispatch_once_t onceQueue;
    static Sprout *sprout = nil;
    
    dispatch_once(&onceQueue, ^{ sprout = [[self alloc] init]; });
    return sprout;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.fileManager = [[NSFileManager alloc] init];
        self.defaultLogFormatterClass = [SproutCustomLogFormatter class];
    }
    
    return self;
}

#pragma mark Class Level

//Original concept and code from http://www.cocoawithlove.com/2010/05/handling-unhandled-exceptions-and.html
//Since modified
+ (NSString *)backtraceSkipping:(int)skip length:(int)length
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = skip; i < skip + length; ++i)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    NSString *retVal = [backtrace componentsJoinedByString:@"\n"];
    return retVal;
}

#pragma mark - Implementation

- (void)startLogging
{
    if (!self.started)
    {
        //Initialize logging
        
        //Register our handler for uncaught exceptions
        NSSetUncaughtExceptionHandler(&exceptionHandler);
        
        //Register our handler for signals
        
        //Create the signal action structure
        struct sigaction signalAction;
        //Initialize the signal action structure
        memset(&signalAction, 0, sizeof(signalAction));
        //Set 'signalHandler' as the handler in the signal action structure
        signalAction.sa_handler = &signalHandler;
        //Set 'signalHandler' as the handlers for SIGABRT, SIGILL and SIGBUS
        sigaction(SIGABRT, &signalAction, NULL);
        sigaction(SIGILL, &signalAction, NULL);
        sigaction(SIGBUS, &signalAction, NULL);
        sigaction(SIGSEGV, &signalAction, NULL);
        
        [self addDefaultLoggers];

        DDLogInfo(@"[Sprout] CocoaLumberjack loggers initialized!");
        
        self.started = YES;
    }
}

#ifndef SPROUT_DISABLE_DYNAMIC_LOG_LEVEL
- (void)setLogLevel:(int)logLevel
{
    ddLogLevel = logLevel;
}
#endif

- (void)logAppAndDeviceInfo
{
    NSString *appName = [self appName];
    NSString *appVersion = [self appVersion];
    NSString *appIdentifier = [self appIdentifier];
    NSString *appBuildNumber = [self appBuildNumber];
    NSString *deviceModel;
    NSString *systemName;
    NSString *systemVersion;
    
    [self deviceModel:&deviceModel systemName:&systemName systemVersion:&systemVersion];

    DDLogInfo(@"%@ %@ (%@ %@) %@, %@ %@", appName ?: @"<unknown_app_name>", appVersion ?: @"<unknown_app_version>", appIdentifier ?: @"<unknown_app_identifier>", appBuildNumber ?: @"<unknown_app_build_number>", deviceModel ?: @"<unknown_device_model>", systemName ?: @"<unknown_system_name>", systemVersion ?: @"<unknown_system_version>");
}

- (NSData *)logsAsZippedData
{
    NSData *retVal = nil;
#ifdef _SSZIPARCHIVE_H
    NSString *tempDir = [self tempDirectory];
    if (tempDir)
    {
        NSString *tempFile = [tempDir stringByAppendingPathComponent:[self UUID]];
        NSArray *logFiles = [self logFiles];
        if ([SSZipArchive createZipFileAtPath:tempFile withFilesAtPaths:logFiles])
        {
            //Read the temp zip file into memory
            retVal = [NSData dataWithContentsOfFile:tempFile];
            //Delete the temp directory and contents
            [self.fileManager removeItemAtPath:tempDir error:nil];
        }
    }
#else
#warning SSZipArchive framework not found in project, or not included in precompiled header. `logsAsZippedData` will return `nil`.
#endif
    
    return retVal;
}

- (NSArray *)logFiles
{
    NSUInteger maximumLogFilesToReturn = MIN(self.fileLogger.logFileManager.maximumNumberOfLogFiles, 10);
    NSMutableArray *logFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    NSArray *sortedLogFileInfos = [self.fileLogger.logFileManager sortedLogFileInfos];
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); ++i)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSString *logFile = logFileInfo.filePath;
        if (logFile)
        {
            [logFiles addObject:logFile];
        }
    }
    return logFiles;
}

#pragma mark - Logging Setup

- (void)addDefaultLoggers
{
    NSArray *loggers = self.defaultLoggers;
    for (id<DDLogger> logger in loggers)
    {
        [self addLogger:logger];
        DDLogVerbose(@"[Sprout] Added logger: '%@'", [logger loggerName]);
    }
}

- (id<DDLogFormatter>)createDefaultLogFormatter
{
    Class formatterClass = self.defaultLogFormatterClass;
    id<DDLogFormatter> formatter = [[formatterClass alloc] init];
    if (![formatter conformsToProtocol:@protocol(DDLogFormatter)])
    {
        formatter = [[SproutCustomLogFormatter alloc] init];
    }
    
    return formatter;
}

- (NSArray *)defaultLoggers
{
    if (!_defaultLoggers)
    {
        NSMutableArray *loggers = [NSMutableArray arrayWithCapacity:4];
        
        id<DDLogger> logger = nil;
        
        logger = [self setupTTYLogger];
        if (logger)
        {
            self.ttyLogger = logger;
            [loggers addObject:logger];
        }
        
        logger = [self setupFileLogger];
        if (logger)
        {
            self.fileLogger = logger;
            [loggers addObject:logger];
        }
        
        logger = [self setupTestFlightLogger];
        if (logger)
        {
            self.testFlightLogger = logger;
            [loggers addObject:logger];
        }
        
        logger = [self setupCrashlyticsLogger];
        if (logger)
        {
            self.crashlyticsLogger = logger;
            [loggers addObject:logger];
        }
        
        _defaultLoggers = loggers;
    }

    return _defaultLoggers;
}

- (void)addLogger:(id <DDLogger>)logger
{
    [self addLogger:logger withLogLevel:LOG_LEVEL_ALL];
}

- (void)addLogger:(id <DDLogger>)logger withLogLevel:(int)logLevel
{
    if (logger)
    {
        id<DDLogFormatter> formatter = [self createDefaultLogFormatter];
        [logger setLogFormatter:formatter];
        
        [DDLog addLogger:logger];
    }
}

- (void)removeLogger:(id <DDLogger>)logger
{
    [DDLog removeLogger:logger];
}

- (void)removeAllLoggers
{
    [DDLog removeAllLoggers];
}

- (NSArray *)allLoggers
{
    return [DDLog allLoggers];
}

- (DDTTYLogger *)setupTTYLogger
{
    DDTTYLogger *logger = nil;
    
    #ifdef SPROUT_CONSOLE_LOGGING
    //Console
    logger = [DDTTYLogger sharedInstance];
    [logger setColorsEnabled:YES];
    #endif
    
    return logger;
}

- (DDFileLogger *)setupFileLogger
{
    DDFileLogger *logger = nil;
    
    #ifdef SPROUT_FILE_LOGGING
    //File logging
    logger = [[DDFileLogger alloc] init];
    logger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    logger.logFileManager.maximumNumberOfLogFiles = 7;
    #endif

    return logger;
}

- (TestFlightLogger *)setupTestFlightLogger
{
    TestFlightLogger *logger = [TestFlightLogger sharedInstance];
    
    return logger;
}

- (CrashlyticsLogger *)setupCrashlyticsLogger
{
    CrashlyticsLogger *logger = [CrashlyticsLogger sharedInstance];
    
    return logger;
}

#pragma mark - Helpers

- (NSString *)appVersion
{
    NSString *retVal = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return retVal;
}

- (NSString *)appBuildNumber
{
    NSString *retVal = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return retVal;
}

- (NSString *)appName
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [info objectForKey:@"CFBundleDisplayName"];
    if (!name)
    {
        name = [info objectForKey:@"CFBundleName"];
    }

    return name;
}

- (NSString *)appIdentifier
{
    NSString *retVal = [[NSBundle mainBundle] bundleIdentifier];
    return retVal;
}

- (void)deviceModel:(NSString **)deviceModel systemName:(NSString **)systemName systemVersion:(NSString **)systemVersion
{
#if TARGET_OS_IPHONE
    [self iosDeviceModel:deviceModel systemName:systemName systemVersion:systemVersion];
#elif TARGET_OS_MAC
    [self osxDeviceModel:deviceModel systemName:systemName systemVersion:systemVersion];
#endif
}

#if TARGET_OS_IPHONE

- (void)iosDeviceModel:(NSString **)deviceModel systemName:(NSString **)systemName systemVersion:(NSString **)systemVersion
{
    if (deviceModel)
    {
        *deviceModel = [UIDevice currentDevice].model;
    }
    if (systemName)
    {
        *systemName = [UIDevice currentDevice].systemName;
    }
    if (systemVersion)
    {
        *systemVersion = [UIDevice currentDevice].systemVersion;
    }
}

#endif //iOS

#if TARGET_OS_MAC

- (void)osxDeviceModel:(NSString **)deviceModel systemName:(NSString **)systemName systemVersion:(NSString **)systemVersion
{
    if (deviceModel)
    {
        *deviceModel = [self sysInfoByName:kSysInfoKeyHardwarePlatform];
    }
    
    //See http://stackoverflow.com/questions/11072804/mac-os-x-10-8-replacement-for-gestalt-for-testing-os-version-at-runtime
    NSDictionary *systemVersionDict = [NSDictionary dictionaryWithContentsOfFile:kSystemVersionPlistLocation];
    
    if (systemName)
    {
        *systemName = systemVersionDict[kSystemVersionKeyProductName];
    }
    if (systemVersion)
    {
        NSString *version = systemVersionDict[kSystemVersionKeyProductName];
        NSString *buildNumber = systemVersionDict[kSystemVersionKeyProductBuildVersion];
        *systemVersion = [NSString stringWithFormat:@"%@ (%@)", version ?: @"<unknown_system_version", buildNumber ?: @"<unknown_system_build_number>"];
    }
}

- (NSString *)sysInfoByName:(NSString *)name
{
    NSString *retVal = nil;
    
    if (name.length > 0)
    {
        const char *cName = [name cStringUsingEncoding:NSUTF8StringEncoding];
        
        size_t size;
        sysctlbyname(cName, NULL, &size, NULL, 0);
        char *buffer = malloc(size);
        sysctlbyname(cName, buffer, &size, NULL, 0);
        retVal = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        free(buffer);
    }
    
    return retVal;
}

#endif //Mac OS

- (NSString *)tempDirectory
{
    //Modified from: http://cocoawithlove.com/2009/07/temporary-files-and-folders-in-cocoa.html
    
    NSString *retVal = nil;
    
    NSString *tempDirectoryTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:[self UUID]];
    const char *tempDirectoryTemplateCString = [tempDirectoryTemplate fileSystemRepresentation];
    char *tempDirectoryNameCString = (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
    strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
    
    char *result = mkdtemp(tempDirectoryNameCString);
    if (result)
    {
        retVal = [self.fileManager stringWithFileSystemRepresentation:tempDirectoryNameCString length:strlen(result)];
    }
    
    free(tempDirectoryNameCString);
    
    return retVal;
}

- (NSString *)UUID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef stringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *retVal = (NSString *)CFBridgingRelease(stringRef);
    return retVal;
}

@end

