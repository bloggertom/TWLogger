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

@implementation NSDateComponents (pagelife)

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(NSDateComponents *)invertedDateComponents{
	NSDateComponents *inverted = [[NSDateComponents alloc]init];
	if(self.nanosecond != NSDateComponentUndefined){
		inverted.nanosecond = self.nanosecond *-1;
	}
	if(self.second != NSDateComponentUndefined){
		inverted.second = self.second *-1;
	}
	if(self.minute != NSDateComponentUndefined){
		inverted.minute = self.minute *-1;
	}
	if(self.hour != NSDateComponentUndefined){
		inverted.hour = self.hour *-1;
	}
	
	
	//deprecated
	if(self.week != NSDateComponentUndefined){
		inverted.week = self.week *-1;
	}
	
	if(self.day != NSDateComponentUndefined){
		inverted.day = self.day *-1;
	}
	if(self.weekOfYear != NSDateComponentUndefined){
		inverted.weekOfYear = self.weekOfYear *-1;
	}
	if(self.weekdayOrdinal != NSDateComponentUndefined){
		inverted.weekdayOrdinal = self.weekdayOrdinal *-1;
	}
	if(self.weekday != NSDateComponentUndefined){
		inverted.weekday = self.weekday *-1;
	}

	if(self.month != NSDateComponentUndefined){
		inverted.month = self.month *-1;
	}
	if(self.quarter != NSDateComponentUndefined){
		inverted.quarter = self.quarter *-1;
	}
	if(self.yearForWeekOfYear != NSDateComponentUndefined){
		inverted.yearForWeekOfYear = self.yearForWeekOfYear *-1;
	}
	if(self.year != NSDateComponentUndefined){
		inverted.year = self.year *-1;
	}
	if(self.era != NSDateComponentUndefined){
		inverted.era = self.era *-1;
	}
	return inverted;
}
#pragma GCC diagnostic pop
@end

@interface TWSqliteLogger()
@property (nonatomic, strong)TWSqlite *twSqlite;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation TWSqliteLogger

-(instancetype)init{
	TWLoggerOptions *options = [[TWLoggerOptions alloc]init];
	self.flushPeriod = [[NSDateComponents alloc]init];
	self.flushPeriod.second = 10;
	self.cacheSize = 10;
	_dateFormatter = [[NSDateFormatter alloc]init];
	[_dateFormatter setDateFormat:DATE_TIME_FORMAT];
	
	return [self initWithOptions:options];
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
		if(*error){
			return NO;
		}
		isDir = YES;
	}
	if(isDir){
		NSString *databasePath = [loggingDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-Database.db",self.options.logFilePrefix]];
		_twSqlite = [TWSqlite openDatabaseAtPath:databasePath error:error];
		if(self.twSqlite != nil && self.options.metaData.count > 0 && ![self.twSqlite insertMetadata:self.options.metaData error:error]){
			return NO;
		}
	}else{
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorInvalidFilePath userInfo:@{NSLocalizedDescriptionKey: @"Invalid log storage directory."}];
		return NO;
	}
	
	return _twSqlite != nil;
}

-(void)writeLogEntry:(TWLogEntry *)entry{
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

-(void)flushLogs{
	@synchronized(self){
		for (TWLogEntry *entry in self.logStore) {
			[self writeLogEntry:entry];
		}
		[self removeExpiredLogs];
	}
}

-(void)removeExpiredLogs{
	//Called withing a @synchronized so should be safe.
	if(self.logExpiration == nil){
		return;
	}
	
	NSDate *now = [NSDate date];
	NSDate *expiryDate = [[NSCalendar currentCalendar] dateByAddingComponents:[self.logExpiration invertedDateComponents] toDate:now options:0];
	
	NSTimeInterval exiryTime = [expiryDate timeIntervalSince1970];
	//date components were already negative. Do the old switcharoo.
	if(exiryTime > [now timeIntervalSince1970]){
		expiryDate = [[NSCalendar currentCalendar] dateByAddingComponents:self.logExpiration toDate:now options:0];
		exiryTime = [expiryDate timeIntervalSince1970];
	}
	
	NSError *error = nil;
	[self.twSqlite deleteEntriesFromBeforeTimeStame:exiryTime error:&error];
	
}

-(void)stopLogging{
	//close database and stuff;
	@synchronized(self){
		self.logging = NO;
		[TWSqlite closeDatabase];
		_twSqlite = nil;
	}
}

-(void)dealloc{
	[self stopLogging];
}
@end
