//
//  TWSqlite.h
//  TWLogger
//
//  Created by Thomas Wilson on 28/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TWLogEntry;
@interface TWSqlite : NSObject

-(instancetype)init NS_UNAVAILABLE;

+(instancetype)openDatabaseAtPath:(NSString *)path error:(NSError **)error;
+(void)closeDatabase;

-(BOOL)insertEntry:(TWLogEntry *)entry error:(NSError **)error;
-(BOOL)insertEntries:(NSArray<TWLogEntry*>*)entries error:(NSError **)error;
-(BOOL)deleteEntriesFromBeforeDate:(NSDate *)date error:(NSError **)error;

@end
