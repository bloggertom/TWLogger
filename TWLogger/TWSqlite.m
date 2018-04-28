//
//  TWSqlite.m
//  TWLogger
//
//  Created by Thomas Wilson on 28/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWSqlite.h"
#import <sqlite3.h>
#define DATE_TIME_FORMAT @"YYYY-MM-dd-HH-mm-ss O"

@interface TWSqlite ()
@property (nonatomic)sqlite3 *database;
@end

@implementation TWSqlite

static sqlite3 *database;
NSInteger databaseVersion = 1;

-(BOOL)openDatabaseAtPath:(NSString *)path error:(NSError *)error{
	return NO;
}

-(BOOL)insertEntry:(TWLogEntry *)entry error:(NSError *)error{
	return NO;
}

-(BOOL)insertEntries:(NSArray<TWLogEntry *> *)entries error:(NSError *)error{
	return NO;
}

-(BOOL)deleteEntriesFromBeforeDate:(NSDate *)date error:(NSError *)error{
	return NO;
}

@end
