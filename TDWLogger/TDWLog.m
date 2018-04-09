//
//  Logger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWLog.h"

@implementation TDWLog

void cLogger(const char *file, const char *functionName, NSString *format, ...) {
	
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
	
	[TDWLog logFromFile:fileName inFunction:function body:body];
}

+ (void)logFromFile:(NSString *)file inFunction:(NSString *)functionName body:(NSString *)body{
	NSMutableString *logStr = [[NSMutableString alloc]init];
	[logStr appendFormat:@"%@ ", [NSDate date]];
	if(file != nil){
		[logStr appendFormat:@"%@ ", file];
	}
	
	if(functionName != nil){
		[logStr appendFormat:@"%@ ", functionName];
	}
	
	if(body){
		[logStr appendFormat:@"%@", body];
	}
	
	fprintf(stderr, "%s", logStr.UTF8String);
	if([_delegate respondsToSelector:@selector(logReceived:fromFile:forMethod:)] && [_delegate respondsToSelector:@selector(log)] && _delegate.log){
		[_delegate logReceived:logStr fromFile:file forMethod:functionName];
	}
	
}

static id<TDWLoggerDelegate> _delegate;
+(id<TDWLoggerDelegate>)delegate{
	return _delegate;
}

+(void)setDelegate:(id<TDWLoggerDelegate>)delegate{
	_delegate = delegate;
}
@end
