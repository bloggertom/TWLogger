//
//  TWSqliteTests.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 29/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "TWSqlite.h"
#import "TWSqliteLogEntry.h"
#import "TWUtils.h"
#import "TWLoggerErrors.h"
@interface TWSqliteTests : XCTestCase
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation TWSqliteTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_dateFormatter = [[NSDateFormatter alloc]init];
	_dateFormatter.dateFormat = DATE_TIME_FORMAT;
	
	
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	[TWSqlite closeDatabase];
}

- (void)testOpenDataBase {
	[self getDatabase];
}

-(void)testTwoInstances{
	[self getDatabase];
	@try{
		[self getDatabase];
		XCTFail(@"2 Instances of database created");
	}@catch(NSException *e){
		//success
	}
}

-(TWSqlite *)getDatabase{
	NSError *error = nil;
	TWSqlite *twSqlite = [TWSqlite openDatabaseAtPath:@":memory:" error:&error];
	
	XCTAssertNil(error);
	if(error){
		NSLog(@"%@", error);
	}
	XCTAssertNotNil(twSqlite);
	
	return twSqlite;
}


-(void)testAddLogEntry{
	TWSqlite *twSqlite = [self getDatabase];
	
	TWSqliteLogEntry *entry = [self createLogEntry];
	
	[self addLogEntry:entry toDatabase:twSqlite];
	
}

-(void)testGetLogEntry{
	TWSqlite *twSqlite = [self getDatabase];
	
	TWSqliteLogEntry *entry = [self createLogEntry];
	NSInteger rowId = [self addLogEntry:entry toDatabase:twSqlite];
	
	TWSqliteLogEntry *testEntry = [self getLogEntryWithId:rowId from:twSqlite];
	
	XCTAssertEqual(entry.timestamp, testEntry.timestamp);
	XCTAssertEqualObjects(entry.datetime, testEntry.datetime);
	XCTAssertEqualObjects(entry.logLevel, testEntry.logLevel);
	XCTAssertEqualObjects(entry.file, testEntry.file);
	XCTAssertEqualObjects(entry.function, testEntry.function);
	XCTAssertEqualObjects(entry.logBody, testEntry.logBody);
}

-(NSInteger)addLogEntry:(TWSqliteLogEntry *)entry toDatabase:(TWSqlite *)database{
	NSError *error = nil;
	NSInteger rowId = [database insertEntry:entry error:&error];
	XCTAssertNil(error);
	XCTAssertNotEqual(0, rowId);
	
	return rowId;
}

-(TWSqliteLogEntry *)getLogEntryWithId:(NSInteger)rowId from:(TWSqlite *)database{
	NSError *error = nil;
	TWSqliteLogEntry *entry = [database selectLogEntryWithRowId:rowId error:&error];
	XCTAssertNotNil(entry);
	XCTAssertNil(error);
	
	XCTAssertEqual(rowId, entry.logId);
	
	return entry;
}

-(TWSqliteLogEntry *)createLogEntry{
	TWSqliteLogEntry *entry = [[TWSqliteLogEntry alloc]init];
	entry.function = @"TestFunction";
	entry.file = @"TestFile";
	entry.logLevel = [TWUtils logLevelString:TWLogLevelInfo];
	entry.logBody = @"Really long log body";
	NSDate *date = [NSDate date];
	entry.datetime = [self.dateFormatter stringFromDate:date];
	entry.timestamp = [date timeIntervalSince1970];
	return entry;
}

-(void)testDeleteLogEntry{
	TWSqlite *twSqlite = [self getDatabase];
	
	TWSqliteLogEntry *entry = [self createLogEntry];
	
	NSInteger rowId = [self addLogEntry:entry toDatabase:twSqlite];
	
	NSError *error = nil;
	XCTAssertTrue([twSqlite deleteEntryWithRowId:rowId error:&error]);
	XCTAssertNil(error);
	
	TWSqliteLogEntry *test = [twSqlite selectLogEntryWithRowId:rowId error:&error];
	
	XCTAssertNil(test);
	XCTAssertNotNil(error);
	
	XCTAssertEqual(TWLoggerErrorSqliteLogEntryNotFound, error.code);
}

-(void)testGetAllLogEntries{
	TWSqlite *twSqlite = [self getDatabase];
	
	for(int i=0; i<10; i++){
		TWSqliteLogEntry *entry = [self createLogEntry];
		XCTAssertTrue([self addLogEntry:entry toDatabase:twSqlite] > 0);
	}
	
	NSError *error = nil;
	NSArray *logs = [twSqlite selectAllLogEntries:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(logs);
	XCTAssertEqual(10, logs.count);
}

-(void)testMetaData{
	TWSqlite *twSqlite = [self getDatabase];
	
	NSDictionary *metatest= @{@"key1": @"value1",
	  @"key2": @"value2",
	  @"key3": @"value3"
	  };
	
	NSError *error = nil;
	XCTAssertTrue([twSqlite insertMetadata:metatest error:&error]);
	XCTAssertNil(error);
	
	error = nil;
	
	NSDictionary *metatestActual = [twSqlite selectAllMetadata:&error];
	XCTAssertNotNil(metatestActual);
	XCTAssertEqual(3, metatestActual.count);
	XCTAssertNil(error);
	for (NSString *key in metatest) {
		XCTAssertNotNil([metatestActual objectForKey:key]);
		XCTAssertEqualObjects([metatest objectForKey:key], [metatestActual objectForKey:key]);
	}
}

@end
