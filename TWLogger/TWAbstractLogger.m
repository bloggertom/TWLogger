//
//  AbstractLogger.m
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWAbstractLoggerProject.h"

@implementation TWAbstractLogger

-(instancetype)init{
	TWLoggerOptions *options = [[TWLoggerOptions alloc]init];
	
	options.maxPageNum = 80;
	options.maxPageSize = 0;
	options.logFilePrefix = @"TWLog";
	options.pageLife = [[NSDateComponents alloc]init];
	options.pageLife.day = 1;
	options.dateTimeFormat = TWDateTimeFormatDefault;
	
	NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	path = [path stringByAppendingPathComponent:@"TWLogFiles"];
	options.loggingDirectory = path;
	
	return [self initWithOptions:options];
}

-(instancetype)initWithOptions:(TWLoggerOptions *)options{
	if(self = [super init]){
		_options = options;
		if(_options.logFormat != nil){
			_logFormatter = [[TWLogFormatter alloc]initWithLogFormat:self.options.logFormat dateTimeFormat:options.dateTimeFormat];
		}
		self.logging = YES;
	}
	
	return self;
}

BOOL _logging;
-(BOOL)isLogging{
	return _logging;
}

-(void)setLogging:(BOOL)logging{
	_logging = logging;
}

- (void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)stopLogging {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end


