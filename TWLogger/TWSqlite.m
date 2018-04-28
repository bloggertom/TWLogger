//
//  TWSqlite.m
//  TWLogger
//
//  Created by Thomas Wilson on 28/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWSqlite.h"
#import <sqlite3.h>
#import "TWLoggerErrors.h"
#define DATE_TIME_FORMAT @"YYYY-MM-dd-HH-mm-ss O"

NSString * const TWLogTableName = @"TWLogEntries";

NSString * const TWLogTableColumnDateTime = @"date_time";
NSString * const TWLogTableColumnLevel = @"level";
NSString * const TWLogTableColumnBody = @"body";
NSString * const TWLogTableColumnFunction = @"function";
NSString * const TWLogTableColumnFile = @"file";

@interface TWSqlite ()
@property (nonatomic)sqlite3 *database;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation TWSqlite
TWSqlite *instance;

NSInteger databaseVersion = 1;

-(instancetype)init{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"-init is not a valid initializer for the class TWSqlite"
								 userInfo:nil];
}

-(instancetype)initInternal:(NSString *)path error:(NSError **)error{
	self = [super init];
	if(self){
		_dateFormatter = [[NSDateFormatter alloc]init];
		[_dateFormatter setDateFormat:DATE_TIME_FORMAT];
		if(![self openOrCreateDatabaseAtPath:path error:error]){
			return nil;
		}
		
	
		return self;
	}
	return nil;
}

+(instancetype)openDatabaseAtPath:(NSString *)path error:(NSError **)error{
	if(instance){
		@throw [NSException exceptionWithName:NSInternalInconsistencyException
									   reason:@"Database connection already established"
									 userInfo:nil];
	}
	instance = [[TWSqlite alloc]initInternal:path error:error];
	
	return instance;
}

-(BOOL)openOrCreateDatabaseAtPath:(NSString *)path error:(NSError **)error{
	int result = sqlite3_open(path.UTF8String, &_database);
	if(result != SQLITE_OK){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorFailedToOpenLog userInfo:
				  @{NSLocalizedDescriptionKey: @"Unable to create/open database"}];
		return NO;
	}

	return [self createLogTable:error];
}

-(BOOL)createLogTable:(NSError **)error{
	NSString *query = [NSString stringWithFormat:@"CREATE TABLE %@ IF NOT EXISTS (%@, %@, %@, %@, %@);", TWLogTableName,TWLogTableColumnDateTime, TWLogTableColumnLevel, TWLogTableColumnFile, TWLogTableColumnFunction, TWLogTableColumnBody];
	
	if(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL) != SQLITE_OK){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
				  @{NSLocalizedDescriptionKey: @"Failed write database schema"}];
		return NO;
	}
	return YES;
}

-(BOOL)insertEntry:(TWLogEntry *)entry error:(NSError **)error{
	return NO;
}

-(BOOL)insertEntries:(NSArray<TWLogEntry *> *)entries error:(NSError **)error{
	return NO;
}

-(BOOL)deleteEntriesFromBeforeDate:(NSDate *)date error:(NSError **)error{
	return NO;
}

+(void)closeDatabase{
	if(instance.database){
		sqlite3_close(instance.database);
		instance.database = nil;
		instance = nil;
	}
}
@end
