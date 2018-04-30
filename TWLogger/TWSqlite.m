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
#import "TWSqliteLogEntry.h"
#import "TWUtils.h"

NSString * const TWLogTableName = @"TWLogEntries";

NSString * const TWLogTableColumnTimeStamp = @"timestamp";
NSString * const TWLogTableColumnDateTime = @"date_time";
NSString * const TWLogTableColumnLevel = @"level";
NSString * const TWLogTableColumnBody = @"body";
NSString * const TWLogTableColumnFunction = @"function";
NSString * const TWLogTableColumnFile = @"file";

@interface TWSqlite ()

@property (nonatomic)sqlite3 *database;
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
	NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ REAL, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT);", TWLogTableName, TWLogTableColumnTimeStamp, TWLogTableColumnDateTime, TWLogTableColumnLevel, TWLogTableColumnFile, TWLogTableColumnFunction, TWLogTableColumnBody];
	
	if(sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL) != SQLITE_OK){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
				  @{NSLocalizedDescriptionKey: @"Failed write database schema"}];
		return NO;
	}
	
	return YES;
}

-(NSInteger)insertEntry:(TWSqliteLogEntry *)entry error:(NSError **)error{
	NSInteger index = 0;
	NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (?,?,?,?,?,?);",
					   TWLogTableName,
					   //columns
					   TWLogTableColumnTimeStamp,
					   TWLogTableColumnDateTime,
					   TWLogTableColumnLevel,
					   TWLogTableColumnFile,
					   TWLogTableColumnFunction,
					   TWLogTableColumnBody];
	
	sqlite3_stmt *statement;
	@try{
		if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
			sqlite3_bind_double(statement, 1, entry.timestamp);
			sqlite3_bind_text(statement, 2, entry.datetime.UTF8String, 0, NULL);
			sqlite3_bind_text(statement, 3, entry.logLevel.UTF8String, 0, NULL);
			sqlite3_bind_text(statement, 4, entry.file.UTF8String, 0, NULL);
			sqlite3_bind_text(statement, 5, entry.function.UTF8String, 0, NULL);
			sqlite3_bind_text(statement, 6, entry.logBody.UTF8String, 0, NULL);
			
			int result = sqlite3_step(statement);
			if(result == SQLITE_OK || result == SQLITE_DONE){
				index = sqlite3_last_insert_rowid(self.database);
				return index;
			}
		}
	}
	@finally{
		if(statement){
			sqlite3_finalize(statement);
		}
	}
	
	//getting to here means we've failed.
	*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
				  @{NSLocalizedDescriptionKey: @"Failed to write log entry"}];
	
	
	return 0;
}

-(BOOL)deleteEntriesFromBeforeTimeStame:(double)timeStamp error:(NSError **)error{
	NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ < ?;",TWLogTableName, TWLogTableColumnTimeStamp];
	
	sqlite3_stmt *statement;
	@try{
		if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
			sqlite3_bind_double(statement, 1, timeStamp);
			
			int result = sqlite3_step(statement);
			if(result == SQLITE_DONE || SQLITE_OK){
				return YES;
			}
		}
	}
	@finally
	{
		sqlite3_finalize(statement);
	}
	
	*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
			  @{NSLocalizedDescriptionKey: @"Failed to remove log entries"}];
	
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
