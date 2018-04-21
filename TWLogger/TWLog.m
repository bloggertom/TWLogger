//
//  Logger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWLog.h"
#import "TWUtils.h"

@interface LoggerReference :NSObject
@property (nonatomic)dispatch_queue_t logQueue;
@property (nonatomic, strong)id<TWLoggerDelegate>logger;
@end

@implementation LoggerReference

-(instancetype)initWithLogger:(id<TWLoggerDelegate>)logger queue:(dispatch_queue_t)logQueue{
	self = [super init];
	if(self){
		_logQueue = logQueue;
		_logger = logger;
	}
	return self;
}

@end

@implementation TWLog

void tdwLogD(const char *file, const char *functionName, NSString *format, ...) {
	// Type to hold information about variable arguments.
	va_list ap;
	
	// Initialize a variable argument list.
	va_start (ap, format);
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
	
	[TWLog tdwLog:TWLogLevelDebug from:fileName inFunction:function body:body];
	
	// End using variable argument list.
	va_end (ap);
}

void tdwLogL(const char *file, const char *functionName, TWLogLevel level, NSString *format, ...) {
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
	
	[TWLog tdwLog:level from:fileName inFunction:function body:body];
}

+ (void)tdwLog:(TWLogLevel)level from:(NSString *)file inFunction:(NSString *)functionName body:(NSString *)body{
	if(body){
		fprintf(stderr, "%s", body.UTF8String);
	}
	if(_loggers.count > 0 && _log){
		[_loggers enumerateObjectsUsingBlock:^(LoggerReference* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			dispatch_sync(obj.logQueue, ^{
				[obj.logger logReceived:level body:body fromFile:file forFunction:functionName];
			});
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
NSMutableArray<LoggerReference *> *_loggers;
+(void)addLogger:(id<TWLoggerDelegate>)logger{
	if(logger == nil){
		return;
	}
	if(_loggers == nil){
		_loggers = [[NSMutableArray alloc]init];
	}
	LoggerReference *ref = [[LoggerReference alloc]initWithLogger:logger queue:dispatch_queue_create("logging-queue", DISPATCH_QUEUE_SERIAL)];
	[_loggers addObject:ref];
}

+(id<TWLoggerDelegate>)removeLogger:(id<TWLoggerDelegate>)logger{
	if(logger == nil || _loggers == nil){
		return nil;
	}
	
	NSInteger count = 0;
	while(count < _loggers.count){
		if(logger == [_loggers objectAtIndex:count].logger){
			[_loggers removeObjectAtIndex:count];
			[logger stopLogging];
			return logger;
		}
		count++;
	}
	
	return nil;
}

static TWLogLevel _defaultLevel = TWLogLevelDebug;
+(void)setDefaultLogLevel:(TWLogLevel)level{
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
