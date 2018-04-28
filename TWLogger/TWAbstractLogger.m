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
	self = [super init];
	if(self){
		_flushLock = [[NSObject alloc]init];
		_logStore = [[NSMutableArray alloc]init];
		_fileManager = [NSFileManager defaultManager];
		_flushQueue = dispatch_queue_create("logger.flush.queue", DISPATCH_QUEUE_SERIAL);
		_cal = [NSCalendar currentCalendar];
	}
	return self;
}

-(instancetype)initWithOptions:(TWLoggerOptions *)options{
	if(self = [self init]){
		_options = options;
		if(_options.logFormat != nil){
			_logFormatter = self.options.logFormat;
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
	if(!prev && logging && self.options.flushPeriod != nil){
		[self scheduleLogFlush];
	}
}

-(void)scheduleLogFlush{
	@synchronized (self.flushLock) {
		if(!self.flushingScheduled){
			self.flushingScheduled = YES;
			NSDate *now = [NSDate date];
			NSDate *then = [self.cal dateByAddingComponents:self.options.flushPeriod toDate:now options:0];
			NSTimeInterval trigger = [then timeIntervalSinceDate:now];
			
			//The wait is asynchronous so will break the lock.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(trigger * NSEC_PER_SEC)), self.flushQueue, ^{
				[self flushQueue];
				[self.logStore removeAllObjects];
				self.flushingScheduled = NO;
				if(self.logging){
					[self scheduleLogFlush];
				}
			});
		}
	}
	
	
}
-(void)addLogEntry:(TWLogEntry *)entry{
	dispatch_async(self.flushQueue, ^{
		[self.logStore addObject:entry];
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


