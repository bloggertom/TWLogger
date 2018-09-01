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
NSString * const TWLogMetaDataTableName = @"TWLogMetaData";

NSString * const TWLogTableColumnTimeStamp = @"timestamp";
NSString * const TWLogTableColumnDateTime = @"date_time";
NSString * const TWLogTableColumnLevel = @"level";
NSString * const TWLogTableColumnBody = @"body";
NSString * const TWLogTableColumnFunction = @"function";
NSString * const TWLogTableColumnFile = @"file";

NSString * const TWLogMetaDataColumnKey =  @"key";
NSString * const TWLogMetaDataColumnValue = @"value";

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

-(BOOL)insertMetadata:(NSDictionary<NSString*, NSString*> *)metaData error:(NSError **)error{
	NSString *query = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", TWLogMetaDataTableName];
	
	if(sqlite3_exec(self.database, query.UTF8String, NULL, NULL, NULL) != SQLITE_OK){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
				  @{NSLocalizedDescriptionKey: @"Failed to delete old meta data"}];
		return NO;
	}
	
	query = [NSString stringWithFormat:@"CREATE TABLE %@ (%@ TEXT, %@, TEXT);", TWLogMetaDataTableName, TWLogMetaDataColumnKey, TWLogMetaDataColumnValue];
	
	if(sqlite3_exec(self.database, query.UTF8String, NULL, NULL, NULL) != SQLITE_OK){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
				  @{NSLocalizedDescriptionKey: @"Failed to create meta data table"}];
		return NO;
	}
	
	for (NSString *key in metaData) {
		query = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@) VALUES (?,?);", TWLogMetaDataTableName, TWLogMetaDataColumnKey, TWLogMetaDataColumnValue];
		
		sqlite3_stmt *statement;
		@try{
			if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
				sqlite3_bind_text(statement, 1, key.UTF8String, -1, NULL);
				sqlite3_bind_text(statement, 2, [metaData objectForKey:key].UTF8String, -1, NULL);
				
				int result = sqlite3_step(statement);
				if(result != SQLITE_OK && result != SQLITE_DONE){
					*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
							  @{NSLocalizedDescriptionKey: @"Failed to write metadata entry to database"}];
					return NO;
				}
			}
		}
		@finally{
			if(statement != nil){
				sqlite3_finalize(statement);
			}
		}
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
			sqlite3_bind_text(statement, 2, entry.datetime.UTF8String, -1, NULL);
			sqlite3_bind_text(statement, 3, entry.logLevel.UTF8String, -1, NULL);
			sqlite3_bind_text(statement, 4, entry.file.UTF8String, -1, NULL);
			sqlite3_bind_text(statement, 5, entry.function.UTF8String, -1, NULL);
			sqlite3_bind_text(statement, 6, entry.logBody.UTF8String, -1, NULL);
			
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

-(BOOL)deleteEntryWithRowId:(NSInteger)rowId error:(NSError **)error{
	NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ROWID = ?;", TWLogTableName];
	
	sqlite3_stmt *statement;
	@try{
		if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
			sqlite3_bind_int64(statement, 1, rowId);
			
			int result = sqlite3_step(statement);
			if(result == SQLITE_OK || result == SQLITE_DONE){
				return YES;
			}
		}
	}@finally{
		if(statement){
			sqlite3_finalize(statement);
		}
	}
	*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToWrite userInfo:
			  @{NSLocalizedDescriptionKey: @"Failed to remove log entry"}];
	
	return NO;
}

-(TWSqliteLogEntry *)selectLogEntryWithRowId:(NSInteger)rowId error:(NSError **)error{
	NSString *query = [NSString stringWithFormat:@"SELECT ROWID,%@,%@,%@,%@,%@,%@ FROM %@ WHERE ROWID = ?;",
					   TWLogTableColumnTimeStamp,
					   TWLogTableColumnDateTime,
					   TWLogTableColumnLevel,
					   TWLogTableColumnFile,
					   TWLogTableColumnFunction,
					   TWLogTableColumnBody,
					   //from
					   TWLogTableName];
	
	sqlite3_stmt *statement;
	@try{
		if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
			sqlite3_bind_int64(statement, 1, rowId);
			int result = sqlite3_step(statement);
			if(result == SQLITE_ROW){
				return [self getLogEntryFromStatement:statement];
			}else if(result == SQLITE_DONE){
				*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteLogEntryNotFound userInfo:@{NSLocalizedDescriptionKey: @"Log entry not found"}];
				return nil;
			}
		}
	}@finally{
		if(statement){
			sqlite3_finalize(statement);
		}
	}
	
	*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToRead userInfo:@{NSLocalizedDescriptionKey: @"Failed to read log entry"}];
	
	return nil;
}

-(NSArray *)selectAllLogEntries:(NSError *__autoreleasing *)error{
	NSString *query = [NSString stringWithFormat:@"SELECT ROWID,%@,%@,%@,%@,%@,%@ FROM %@;",
					   TWLogTableColumnTimeStamp,
					   TWLogTableColumnDateTime,
					   TWLogTableColumnLevel,
					   TWLogTableColumnFile,
					   TWLogTableColumnFunction,
					   TWLogTableColumnBody,
					   //from
					   TWLogTableName];
	
	sqlite3_stmt *statement;
	@try{
		if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
			NSMutableArray *entries = [[NSMutableArray alloc]init];
			int result = 0;
			while((result = sqlite3_step(statement)) == SQLITE_ROW){
				[entries addObject:[self getLogEntryFromStatement:statement]];
			}
			if(result == SQLITE_DONE){
				return entries;
			}
		}
	}
	@finally{
		if(statement != nil){
			sqlite3_finalize(statement);
		}
	}
	
	*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToRead userInfo:@{NSLocalizedDescriptionKey: @"Failed to read log entries"}];
	
	return nil;
}

-(NSDictionary *)selectAllMetadata:(NSError **)error{
	NSString *query = [NSString stringWithFormat:@"SELECT %@,%@ FROM %@;",
					   TWLogMetaDataColumnKey,
					   TWLogMetaDataColumnValue,
					   TWLogMetaDataTableName];
	
	sqlite3_stmt *statement;
	@try{
		if(sqlite3_prepare(self.database, query.UTF8String, -1, &statement, NULL) == SQLITE_OK){
			NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
			int result = 0;
			while((result = sqlite3_step(statement)) == SQLITE_ROW){
				NSString *key = [NSString stringWithSqliteString:sqlite3_column_text(statement, 0)];
				NSString *value = [NSString stringWithSqliteString:sqlite3_column_text(statement, 1)];
				
				[metaData setObject:value forKey:key];
			}
			
			if(result == SQLITE_DONE){
				return metaData;
			}
		}
	}
	@finally{
		if(statement != nil){
			sqlite3_finalize(statement);
		}
	}
	
	*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorSqliteFailedToRead userInfo:
			  @{NSLocalizedDescriptionKey: @"Failed to retrieve metadata"}];
	   
	return nil;
}

-(TWSqliteLogEntry *)getLogEntryFromStatement:(sqlite3_stmt *)statement{
	TWSqliteLogEntry *entry = [[TWSqliteLogEntry alloc]init];
	
	entry.logId = sqlite3_column_int64(statement, 0);
	entry.timestamp = sqlite3_column_double(statement, 1);
	entry.datetime = [NSString stringWithSqliteString:sqlite3_column_text(statement, 2)];
	entry.logLevel = [NSString stringWithSqliteString:sqlite3_column_text(statement, 3)];
	entry.file = [NSString stringWithSqliteString:sqlite3_column_text(statement, 4)];
	entry.function = [NSString stringWithSqliteString:sqlite3_column_text(statement, 5)];
	entry.logBody = [NSString stringWithSqliteString:sqlite3_column_text(statement, 6)];
	
	return entry;
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

+(bool)isOpen{
	return instance.database != nil;
}
@end

@implementation NSString (TWSqlite)
+(NSString *)stringWithSqliteString:(const unsigned char*)text{
	if(text){
		return [NSString stringWithUTF8String:(const char*)text];
	}else{
		return nil;
	}
	
}
@end

