//
//  Logger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWLog.h"
#import "TDWUtils.h"

@implementation TDWLog

void tdwLogD(const char *file, const char *functionName, NSString *format, ...) {
	// Type to hold information about variable arguments.
	va_list ap;
	
	// Initialize a variable argument list.
	va_start (ap, format);
	tdwLogL(file, functionName, _defaultLevel, format);
	
	// End using variable argument list.
	va_end (ap);
}

void tdwLogL(const char *file, const char *functionName, TDWLogLevel level, NSString *format, ...) {
		// Type to hold information about variable arguments.
	va_list ap;
	
		// Initialize a variable argument list.
	va_start (ap, format);
	
		// NSLog only adds a newline to the end of the NSLog format if
		// one is not already there.
		// Here we are utilizing this feature of NSLog()
	if (![format hasSuffix: @"\n"])
	{
		format = [format stringByAppendingString: @"\n"];
	}
	
	NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
	
		// End using variable argument list.
	va_end (ap);
	
	NSString *fileName = nil;
	if(file){
		fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
	}
	NSString *function = nil;
	if(functionName){
		function = [NSString stringWithUTF8String:functionName];
	}
	
	[TDWLog tdwLog:level from:fileName inFunction:function body:body];
}

+ (void)tdwLog:(TDWLogLevel)level from:(NSString *)file inFunction:(NSString *)functionName body:(NSString *)body{
	if(body){
		fprintf(stderr, "%s", body.UTF8String);
	}
	if(_loggers.count > 0 && _log){
		[_loggers enumerateObjectsUsingBlock:^(id<TDWLoggerDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[obj logReceived:level body:body fromFile:file forMethod:functionName];
		}];
	}
	
}
+(void)systemLog:(NSString *)body{
	if (![body hasSuffix: @"\n"])
	{
		body = [body stringByAppendingString: @"\n"];
	}
	fprintf(stderr, "%s", body.UTF8String);
}
NSMutableArray<id<TDWLoggerDelegate>> *_loggers;
+(void)addLogger:(id<TDWLoggerDelegate>)logger{
	if(logger == nil){
		return;
	}
	if(_loggers == nil){
		_loggers = [[NSMutableArray alloc]init];
	}
	
	[_loggers addObject:logger];
}

+(id<TDWLoggerDelegate>)removeLogger:(id<TDWLoggerDelegate>)logger{
	if(logger == nil || _loggers == nil){
		return nil;
	}
	
	NSInteger count = 0;
	while(count < _loggers.count){
		if(logger == [_loggers objectAtIndex:count]){
			[_loggers removeObjectAtIndex:count];
			return logger;
		}
		count++;
	}
	
	return nil;
}


static __weak id<TDWLoggerDelegate> _delegate;
+(id<TDWLoggerDelegate>)delegate{
	return _delegate;
}

+(void)setDelegate:(id<TDWLoggerDelegate>)delegate{
	_delegate = delegate;
}

static TDWLogLevel _defaultLevel = TDWLogLevelDebug;
+(void)setDefaultLogLevel:(TDWLogLevel)level{
	_defaultLevel = level;
}

static BOOL _log = YES;
+(BOOL)isLogging{
	return _log;
}

+(void)log:(BOOL)logging{
	_log = logging;
}

@end
