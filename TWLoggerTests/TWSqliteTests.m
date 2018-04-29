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
	
	TWSqliteLogEntry *entry = [[TWSqliteLogEntry alloc]init];
	entry.function = @"TestFunction";
	entry.file = @"TestFile";
	entry.logLevel = [TWUtils logLevelString:TWLogLevelInfo];
	entry.logBody = @"Really long log body";
	NSDate *date = [NSDate date];
	entry.datetime = [self.dateFormatter stringFromDate:date];
	entry.timestamp = [date timeIntervalSince1970];
	
	[self addLogEntry:entry toDatabase:twSqlite];
	
}

-(void)addLogEntry:(TWSqliteLogEntry *)entry toDatabase:(TWSqlite *)database{
	NSError *error = nil;
	if(![database insertEntry:entry error:&error]){
		NSLog(@"%@", error);
		XCTAssertNotNil(error);
		XCTFail(@"Failed to insert entry");
		return;
	}
	
	XCTAssertNil(error);
}

@end
