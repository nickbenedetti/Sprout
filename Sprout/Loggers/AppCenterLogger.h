//
//  AppCenterLogger.h
//
//  Part of "Sprout" https://github.com/levigroker/Sprout
//
//  Created by Levi Brown on March 20, 2019.
//  Copyright (c) 2019 Levi Brown <mailto:levigroker@gmail.com> This work is
//  licensed under the Creative Commons Attribution 4.0 International License. To
//  view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/
//  or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
//  The above attribution and the included license must accompany any version of
//  the source code, binary distributable, or derivatives.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
@import AppCenter;

@interface AppCenterLogger : DDAbstractLogger <DDLogger>

+ (instancetype)sharedInstance;

/**
 Converts between a given DDLogLevel and an MSLogLevel

 @param ddLogLevel The CocoaLumberjack log level to convert from.
 @return The App Center log level best represented by the given CocoaLumberjack log level.
 */
- (MSLogLevel)msLogLevelForDDLogLevel:(DDLogLevel)ddLogLevel;

// Inherited from DDAbstractLogger

// - (id <DDLogFormatter>)logFormatter;
// - (void)setLogFormatter:(id <DDLogFormatter>)formatter;

@end
