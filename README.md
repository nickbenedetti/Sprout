Sprout
===========
[![Build Status](https://travis-ci.org/levigroker/Sprout.svg)](https://travis-ci.org/levigroker/Sprout)
[![Version](http://img.shields.io/cocoapods/v/Sprout.svg)](http://cocoapods.org/?q=Sprout)
[![Platform](http://img.shields.io/cocoapods/p/Sprout.svg)]()
[![License](http://img.shields.io/cocoapods/l/Sprout.svg)](https://github.com/levigroker/Sprout/blob/master/LICENSE.txt)

Use to bootstrap the (excellent) [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack) logging framework and add additional functionality such as Custom Loggers, log archiving, crash stack traces, and more.

### Installing

If you're using [CocoPods](http://cocopods.org) it's as simple as adding this to your `Podfile`:

	pod 'Sprout', '~> 3.1'

Sprout makes use of some preprocessor defines to configure the logging level and some functionality. These preprocessor definitions need to be added to the Pods target for Sprout, as opposed to your own project build settings, because the Pods library gets compiled without being exposed to your project build settings. To do this, you can add a `post_install` hook to your `Podfile` (as seen below).

* `DEBUG=1` If defined, this sets the default logging level to be verbose (`ddLogLevel = DDLogLevelVerbose`) and enables the TTY (console) logger,
otherwise the default is the warning level (`ddLogLevel = DDLogLevelWarning`) and no TTY logger.
* `SPROUT_LOG_LEVEL` can be used to override the default log level. Define `SPROUT_LOG_LEVEL` to whatever log level is appropriate for your configuration. See the **Log Levels** section below.
* `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL=1` By default, Sprout supports CocoaLumberjack's dynamic log level usage by declaring `ddLogLevel` as `const` (`static const int ddLogLevel`). If you don't need dynamic log level support, and would like the extra speed disabling it will provide, you can disable this by defining `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL=1`

#### Podfile post_install

Here's an example `post_install` hook which adds the `DEBUG` and `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL` preprocessor definitions to the `Pods-Sprout` target of the `Pods` project. *Note* `DEBUG` is not added to the `Release` configuration.
This also overrides the default log level by setting `SPROUT_LOG_LEVEL` to a different log level for `Release` vs. other Schemes. 

		post_install do |installer_representation|

		  # Grab the `project` object from the installer (cocoapods < 0.38 use `project`, cocoapods >= 0.38 use pods_project)
		  # See https://github.com/CocoaPods/CocoaPods/issues/2292
		  if installer_representation.respond_to?(:project)
			project = installer_representation.project
		  else
			project = installer_representation.pods_project
		  end

		  # Set our default log levels
		  sprout = (project.targets.select { |target| target.name == 'Sprout' }).first
		  if sprout
			sprout.build_configurations.each do |config|
			  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
			  if config.name == 'Release'
				config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'SPROUT_LOG_LEVEL=DDLogLevelWarning'
			  else
				config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'SPROUT_LOG_LEVEL=DDLogLevelVerbose'
				if !config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'].include? 'DEBUG=1'
				  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DEBUG=1'
				end
			  end
			end
		  end

		end
	
### Documentation

 In the simplest case, setup is just:

* Add `<Sprout/Sprout.h>` to your precompiled header (or import it directly wherever you use it):


		#ifdef __OBJC__
		#import <Foundation/Foundation.h>
		//Third Party
		#import <Sprout/Sprout.h>
		#endif

* For iOS, start Logging in your `application:didFinishLaunchingWithOptions:` UIApplicationDelegate

		- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
		{
			//Initialize logging
			[[Sprout sharedInstance] startLogging];
			...

* For MacOS, start Logging in your `applicationWillFinishLaunching:` NSApplicationDelegate

		- (void)applicationWillFinishLaunching:(NSNotification *)notification
		{
			//Initialize logging
			[[Sprout sharedInstance] startLogging];
			...


* Define `DEBUG`
 In your Preprocessor Macros target build settings, define `DEBUG=1` (this may not be needed, as it is a default setting in later Xcode project templates).

* _Run!_

After the above setup, you should be able to run and see:

		CocoaLumberjack loggers initialized!

appear in your console.

#### Log Levels

By default, Sprout allows the use of dynamic log levels, meaning `setLogLevel:` can be sent at runtime to set the desired log level. This comes with a slight performance hit for log entries, and can be disabled by defining `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL=1`. If disabled, the log level will be static and can only be set at compile time.

The log level defaults to `DDLogLevelVerbose` if `DEBUG` is defined and set to a non-zero value. If `DEBUG` is not defined (or set to zero) the log level defaults to `DDLogLevelWarning`.

The default log level can be overridden by defining `SPROUT_LOG_LEVEL` and setting it to the desired log level.

NOTE: If you're using Sprout with CocoaPods, simply defining this in your precompiled header or project build settings will not have the desired affect, since Sprout is compiled into the Pods library before these are traversed by the pre-compiler. So you will need to define `SPROUT_LOG_LEVEL` in the Podfile `post_install` hook.

See the **Podfile post_install** section above for an example `post_install` hook which does this.

#### Default Loggers

Sprout has default loggers which will be installed under certain circumstances.

* A file logger (`DDFileLogger`) will always be installed. This logger has 24 hour rolling and maximum seven log files.
* A TTY logger (`DDTTYLogger`) will be installed if `DEBUG=1` is true.

You can override which loggers get installed by supplying a `loggersBlock` and returning the loggers you desire before calling `startLogging`. i.e. you can add additional loggers, or remove (some of) the default loggers passed to the block.

Additionally, you can use `addLogger:`, `addLogger:withLogLevel:`, `removeLogger:`, and `removeAllLoggers` after the call to `startLoggers` to modify which loggers are installed.

#### Custom Log Formatter

Sprout comes with `SproutCustomLogFormatter` which outputs two lines for every log entry. For example:

		2014-05-20 16:06:45:602         <60b> startLogging(Sprout.m 164)
		2014-05-20 16:06:45:602  [INfO] CocoaLumberjack loggers initialized!

* The first line specifies the *thread* (`<60b>`), the *function* (`startLogging`), the *file* (`Sprout.m`) and *line number* within the file (`164`).
* The second line is the *actual log message* (`CocoaLumberjack loggers initialized!`), prefixed by the *log level* (`[INfO]`) of the message.

Both lines are prefixed by a *date/time stamp* (`2014-05-20 16:06:45:602`).

If you wish to supply your own log formatter you can provide a `logFormatterBlock` which will be used to obtain a `DDLogFormatter` to use for each logger. The block must be set before calling `startLogging`.

#### Crashlytics Usage

[Crashlytics](http://crashlytics.com) logging is supported by Sprout.

Sadly, using Cocoapods to automatically manage this dependency is not presently possible when `use_frameworks!` is specified. This is due to Crashlytics being provided as a static library (see [this thread](https://twittercommunity.com/t/crashlytics-cocoapod-dynamic-framework-support/47000)).

However, you can manually add support for logging to Crashlytics by making use of the 
 `CrashlyticsLogger` implementation provided. You'll need to include `CrashlyticsLogger.h/m` directly in your project and add it to Sprout before calling `startLogging`

__NOTE:__ You should initialize Crashlytics (call `[Fabric with:@[Crashlytics.class]]`) inside Sprout `startLogging:` block handler. 

Example:

    [Sprout sharedInstance].loggersBlock = ^NSSet<id<DDLogger>> *(NSSet<id<DDLogger>> *defaultLoggers) {
    	NSMutableSet *retVal = [NSMutableSet setWithSet:defaultLoggers];
    	[retVal addObject:[CrashlyticsLogger sharedInstance]];
    	return retVal;
    };

    [[Sprout sharedInstance] startLogging:^{
	    [Fabric with:@[Crashlytics.class]]
    	[[Sprout sharedInstance] logAppAndDeviceInfo];
    }];

#### App Center Usage

[App Center](https://appcenter.ms) logging is supported by Sprout.

You can manually add support for logging to App Center by making use of the 
 `AppCenterLogger` implementation provided. You'll need to include `AppCenterLogger.h/m` directly in your project and add it to Sprout before calling `startLogging`

Example:

    [Sprout sharedInstance].loggersBlock = ^NSSet<id<DDLogger>> *(NSSet<id<DDLogger>> *defaultLoggers) {
    	NSMutableSet *retVal = [NSMutableSet setWithSet:defaultLoggers];
    	[retVal addObject:[AppCenterLogger sharedInstance]];
    	return retVal;
    };

    [[Sprout sharedInstance] startLogging:^{
    	[[Sprout sharedInstance] logAppAndDeviceInfo];
    }];

### Licence

This work is licensed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
Please see the included [LICENSE.txt](https://github.com/levigroker/Sprout/blob/master/LICENSE.txt) for complete details.

### About
A professional iOS engineer by day, my name is Levi Brown. Authoring a blog
[grokin.gs](http://grokin.gs), I am reachable via:

Twitter [@levigroker](https://twitter.com/levigroker)  
Email [levigroker@gmail.com](mailto:levigroker@gmail.com)  

Your constructive comments and feedback are always welcome.
