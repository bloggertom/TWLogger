//
//  TWSqlite.h
//  TWLogger
//
//  Created by Thomas Wilson on 28/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TWSqliteLogEntry;

@interface NSString (TWSqlite)
+(NSString *)stringWithSqliteString:(const unsigned char*)text;
@end

@interface TWSqlite : NSObject

-(instancetype)init NS_UNAVAILABLE;

+(instancetype)openDatabaseAtPath:(NSString *)path error:(NSError **)error;
+(void)closeDatabase;

-(TWSqliteLogEntry *)selectLogEntryWithRowId:(NSInteger)rowId error:(NSError **)error;
-(NSArray<TWSqliteLogEntry *> *)selectAllLogEntries:(NSError **)error;
-(NSInteger)insertEntry:(TWSqliteLogEntry *)entry error:(NSError **)error;
-(BOOL)deleteEntryWithRowId:(NSInteger)rowId error:(NSError **)error;
-(BOOL)deleteEntriesFromBeforeTimeStame:(double)timeStamp error:(NSError **)error;

-(BOOL)insertMetadata:(NSDictionary<NSString*, NSString*> *)metaData error:(NSError **)error;
-(NSDictionary *)selectAllMetadata:(NSError **)error;

+(bool)isOpen;

@end
