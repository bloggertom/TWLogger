//
//  AbstractLogger.m
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWAbstractLogger.h"
#import "TWLog.h"

@interface TWAbstractLogger ()
@property (nonatomic)dispatch_queue_t flushQueue;
@property (nonatomic, strong)NSCalendar *cal;
@property (nonatomic)BOOL flushingScheduled;
@property (nonatomic, strong)NSObject *flushLock;
@end

@implementation TWAbstractLogger

-(instancetype)init{
	return [self initWithOptions:nil];
}

-(instancetype)initWithOptions:(TWLoggerOptions *)options{
	if(self = [super init]){
		_flushLock = [[NSObject alloc]init];
		_logStore = [[NSMutableArray alloc]init];
		_fileManager = [NSFileManager defaultManager];
		_flushQueue = dispatch_queue_create("logger.flush.queue", DISPATCH_QUEUE_SERIAL);
		_cal = [NSCalendar currentCalendar];
		
		if(options == nil){
			_options = [[TWLoggerOptions alloc]init];
		}else{
			_options = options;
		}

		if(_options.logFilePrefix == nil){
			_options.logFilePrefix = @"TWLog";
		}
		
		if(_options.loggingAddress == nil){
			NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
			path = [path stringByAppendingPathComponent:@"TWLogFiles"];
			_options.loggingAddress = path;
		}
		
	}
	return self;
}

BOOL _logging;
-(BOOL)isLogging{
	return _logging;
}

-(void)setLogging:(BOOL)logging{
	BOOL prev = _logging;
	_logging = logging;
	if(!prev && logging && self.flushPeriod != nil){
		[self scheduleLogFlush];
	}else if(prev && !logging && self.flushPeriod != nil){
		dispatch_sync(self.flushQueue, ^{
			@try{
				[self triggerFlush];
			}
			@catch(NSException *e){
				[TWLog systemLog:@"Failed to flush logs before logging stopped"];
				[TWLog systemLog:e.name];
				[TWLog systemLog:e.reason];
			}
		});
	}
}

-(void)scheduleLogFlush{
	@synchronized (self.flushLock) {
		if(!self.flushingScheduled){
			self.flushingScheduled = YES;
			NSDate *now = [NSDate date];
			NSDate *then = [self.cal dateByAddingComponents:self.flushPeriod toDate:now options:0];
			NSTimeInterval trigger = [then timeIntervalSinceDate:now];
			
			//The wait is asynchronous so will break the lock.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trigger * NSEC_PER_SEC)), self.flushQueue, ^{
				if(self.logging){
					[self triggerFlush];
					self.flushingScheduled = NO;
					[self scheduleLogFlush];
				}
			});
		}
	}
}

-(void)triggerFlush{
	[self flushLogs];
	[self.logStore removeAllObjects];
}

-(void)addLogEntry:(TWLogEntry *)entry{
	dispatch_sync(self.flushQueue, ^{
		[self.logStore addObject:entry];
		if((self.flushPeriod == nil && self.cacheSize == 0) || (self.cacheSize > 0 && self.logStore.count > self.cacheSize)){
			[self flushLogs];
			[self.logStore removeAllObjects];
		}
	});
}

- (void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)stopLogging {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (BOOL)startLogging{
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	return NO;
}

-(void)flushLogs{
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

-(void)stopLoggingWithMessage:(NSString *)message andError:(nullable NSError *)error{
	[TWLog systemLog:message];
	if(error != nil){
		[TWLog systemLog:[NSString stringWithFormat:@"%@",error]];
	}
	[self stopLogging];
}

@end


