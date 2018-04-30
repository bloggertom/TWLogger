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

-(NSInteger)insertEntry:(TWSqliteLogEntry *)entry error:(NSError **)error;
-(BOOL)deleteEntryWithRowId:(NSInteger)rowId error:(NSError **)error;
-(BOOL)deleteEntriesFromBeforeTimeStame:(double)timeStamp error:(NSError **)error;

@end
