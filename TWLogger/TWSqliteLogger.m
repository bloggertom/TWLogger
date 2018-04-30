//
//  TWSqliteLogger.m
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWSqliteLogger.h"
#import "TWAbstractLogger.h"
#import "TWLog.h"
#import "TWSqlite.h"
#import "TWLogEntry.h"
#import "TWSqliteLogEntry.h"
#import "TWUtils.h"

@interface TWSqliteLogger()
@property (nonatomic, strong)TWSqlite *twSqlite;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation TWSqliteLogger

-(instancetype)init{
	self = [super init];
	if(self){
		self.options.pageLife.day = 0;
		self.options.pageLife.month = 1;
		self.options.flushPeriod = [[NSDateComponents alloc]init];
		self.options.flushPeriod.second = 10;
		
		_dateFormatter = [[NSDateFormatter alloc]init];
		[_dateFormatter setDateFormat:DATE_TIME_FORMAT];
	}
	return self;
}

-(void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function{
	@synchronized(self){
		if(self.twSqlite == nil || !self.isLogging){
			[TWLog systemLog: @"Log received when logging not active"];
			return;
		}
	}
	TWLogEntry *entry = [[TWLogEntry alloc]init];
	entry.datetime = [NSDate date];
	entry.logLevel = level;
	entry.logBody = body;
	entry.file = file;
	entry.function = function;
	
	if(self.options.flushPeriod != nil){
		[self addLogEntry:entry];
	}else{
		
	}
	
}

-(BOOL)startLogging{
	NSError *error = nil;
	if(![self openOrCreateDatabase:self.options.loggingAddress error:&error]){
		[self stopLoggingWithMessage:@"Failed to open or create database" andError:error];
		return NO;
	}
	self.logging = YES;
	return YES;
}

-(BOOL)openOrCreateDatabase:(NSString *)loggingDirectory error:(NSError **)error{
	BOOL isDir;
	if(![self.fileManager fileExistsAtPath:loggingDirectory isDirectory:&isDir]){
		[self.fileManager createDirectoryAtPath:loggingDirectory withIntermediateDirectories:YES attributes:nil error:error];
		if(error){
			return NO;
		}
		isDir = YES;
	}
	if(isDir){
		NSString *databasePath = [loggingDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-Database.db",self.options.logFilePrefix]];
		_twSqlite = [TWSqlite openDatabaseAtPath:databasePath error:error];
	}else{
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorInvalidFilePath userInfo:@{NSLocalizedDescriptionKey: @"Invalid log storage directory."}];
		return NO;
	}
	return YES;
}

-(void)flushLogs{
	for (TWLogEntry *entry in self.logStore) {
		NSError *error = nil;
		TWSqliteLogEntry *dbEntry = [[TWSqliteLogEntry alloc]init];
		
		dbEntry.datetime = [_dateFormatter stringFromDate:entry.datetime];
		dbEntry.logLevel = [TWUtils logLevelString:entry.logLevel];
		dbEntry.file = entry.file;
		dbEntry.function = entry.function;
		dbEntry.logBody = entry.logBody;
		dbEntry.timestamp = [entry.datetime timeIntervalSince1970];
		
		if([self.twSqlite insertEntry:dbEntry error:&error] == 0){
			[TWLog systemLog:@"Failed to write log with error:"];
			[TWLog systemLog:[NSString stringWithFormat:@"%@",error]];
		}
	}
}

-(void)stopLogging{
	//close database and stuff;
	@synchronized(self){
		self.logging = NO;
		[TWSqlite closeDatabase];
		_twSqlite = nil;
	}
}

@end
