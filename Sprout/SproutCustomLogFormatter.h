//
//  SproutCustomLogFormatter.h
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

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface SproutCustomLogFormatter : NSObject <DDLogFormatter>

@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@end
