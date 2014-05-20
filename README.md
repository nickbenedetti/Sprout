Sprout
===========
 Used to bootstrap the (excellent) [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack) logging framework.

### Installing

If you're using [CocoPods](http://cocopods.org) it's as simple as adding this to your `Podfile`:

	pod 'Sprout', '~> 1.2'

Sprout makes use of some preprocessor defines to configure the logging level and some functionality. These preprocessor definitions need to be added to the Pods target for Sprout, as opposed to your own project build settings, because the Pods library gets compiled without being exposed to your project build settings. To do this, you can add a `post_install` hook to your `Podfile` (as seen below).

* `DEBUG=1` If defined, this sets the logging level to be verbose (`ddLogLevel = LOG_LEVEL_VERBOSE`) and enables the TTY (console) logger,
otherwise the default is the warning level (`ddLogLevel = LOG_LEVEL_WARN`) and no TTY logger.
* `TESTFLIGHT=1` If defined, Sprout will add the `TestFlightLogger` to send log messages to the `TFLog` TestFlight SDK logger at your current log level. Please see the details below.
* `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL=1` By default, Sprout supports CocoaLumberjack's dynamic log level usage by declaring `ddLogLevel` as `const` (`static const int ddLogLevel`). If you don't need dynamic log level support, and would like the extra speed disabling it will provide, you can disable this by defining `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL=1`

#### Podfile post_install

Here's an example `post_install` hook which adds the `DEBUG`, `TESTFLIGHT` and `SPROUT_DISABLE_DYNAMIC_LOG_LEVEL` preprocessor definitions to the `Pods-Sprout` target of the `Pods` project. *Note* `DEBUG` is not added to the `Release` configuration.

		post_install do |installer_representation|
		  installer_representation.project.targets.each do |target|
			if target.name == 'Pods-Sprout'
			  target.build_configurations.each do |config|
				config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
				config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'SPROUT_DISABLE_DYNAMIC_LOG_LEVEL=1'
				config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'TESTFLIGHT=1'
				if config.name != 'Release' and !config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'].include? 'DEBUG=1'
					config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DEBUG=1'
				end
			  end
			  break
			end
		  end
		end
	
### Documentation

 In the simplest case, setup is just:

* Add `Sprout.h` to your precompiled header:


		#ifdef __OBJC__
		#import <Foundation/Foundation.h>
		//Third Party
		#import "Sprout.h"
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
 In your Preprocessor Macros target build settings, define `DEBUG=1` (this may not be needed, as it is a default setting in later XCode project templates).

* _Run!_

After the above setup, you should be able to run and see:

		CocoaLumberjack loggers initialized!

appear in your console.

#### Custom Log Formatter

Sprout comes with `CustomLogFormatter` which outputs two lines for every log entry. For example:

		2014-05-20 16:06:45:602         <60b> startLogging(Sprout.m 164)
		2014-05-20 16:06:45:602  [INfO] CocoaLumberjack loggers initialized!

* The first line specifies the *thread* (`<60b>`), the *function* (`startLogging`), the *file* (`Sprout.m`) and *line number* within the file (`164`).
* The second line is the *actual log message* (`CocoaLumberjack loggers initialized!`), prefixed by the *log level* (`[INfO]`) of the message.

Both lines are prefixed by a *date/time stamp* (`2014-05-20 16:06:45:602`).

#### TestFlight Usage
[TestFlight](http://testflightapp.com) is a great tool, and Sprout has support for it.

If you `#define TESTFLIGHT` (or define `TESTFLIGHT` in your build settings), Sprout will add the `TestFlightLogger` to send log messages to the `TFLog` TestFlight SDK logger at your current log level.

__NOTE:__ If you define `TESTFLIGHT` you must have `libTestFlight.a` linked or you'll get a linker error (see https://testflightapp.com/sdk/doc/ for information on installing TestFlight)

__NOTE:__ If you're using TestFlight you should initialize Sprout before calling `TestFlight takeOff:`

__NOTE:__ You may wish to disable TestFlight's direct logging to the console so you do not see double messages printed to the console. You can add these lines before your `TestFlight takeOff:`

		//Disable TestFlight from logging to the console directly. Sprout (CocoaLumberjack) handles this for us.
		[TestFlight setOptions:@{ TFOptionLogToConsole : @NO }];
		[TestFlight setOptions:@{ TFOptionLogToSTDERR : @NO }];

### Version History

* 1.0 - March 1, 2013
 * Initial public release.
* 1.1 - September 20, 2013
  * Added dynamic log level support.
  * Added basic app, device, and OS logging functionality.
* 1.2 - February 13, 2014
  * Fixing use of TestFlightLogger
* 1.2.1 - March 11, 2014
  * Fixing deadlock issue when logging exceptions.
* 1.3 - May 20, 2014
  * Making Sprout "cross platform" (iOS and OSX).
  * Added documentation for Podfile `post_install` hook and preprocessor definitions.
  * Added documentation for `CustomLogFormatter` format.
  
### Licence

This work is licensed under the [Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/).
Please see the included LICENSE.txt for complete details.

### About
A professional iOS engineer by day, my name is Levi Brown. Authoring a technical
blog [grokin.gs](http://grokin.gs), I am reachable via:

Twitter [@levigroker](https://twitter.com/levigroker)  
App.net [@levigroker](https://alpha.app.net/levigroker)  
EMail [levigroker@gmail.com](mailto:levigroker@gmail.com)  

Your constructive comments and feedback are always welcome.
