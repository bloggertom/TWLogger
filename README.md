#  TWLogger (Dev Release)

A simple logging framework written in objective-c.

Created to be extended and included in project which already makes extensive use of NSLog. Importing the TWLogger.h file into a file overrides NSLog allowing easy intergration with minimal changes

NSLogs will be given the defaul log level of TWLogLevelDebug unless changed using `[TWLog setDefaultLogLevel: logLevel]`.

## Usage

Configure and create a loging object. Inbuilt are 2 loggers `TWFileLogger` and `TWSqliteLogger`. If required these a `TWLoggerOptions` object to adjust logging behaviour. I have attempted to ensure sentable defaults are used when no options are passed in. Then call `[TWLog addLogger:]` passing in your logger object.

For example:
```objective-c

TWFileLogger *logger = [TWFileLogger alloc]init];
[TWLog addLogger:logger];

```
To later remove a logger you can call  `[TWLog removeLogger:];

To log something without sending it through the logging framework you can use `[TWLog systemLog:(NSString *)string]`.

There is a log formatter included but currently it's not very well documented.

## Extention

New loggers just need to adhere to the `TWLogDelegate` protocol. An `TWAbstractLogger` class is available, this handles caching and triggering of flushes for you otherwise you will need to build your own method for triggering log writes.

## Things still to do

The main things I have left to do are:

1. Add a json/remote logger.
2. Review and complete API documentation.
3. Rethink how loggers are configured.
4. Add functionality for meta data in logs.
