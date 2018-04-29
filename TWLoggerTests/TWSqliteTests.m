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
#import "TWLogEntry.h"
@interface TWSqliteTests : XCTestCase

@end

@implementation TWSqliteTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
	
	TWLogEntry *entry = [[TWLogEntry alloc]init];
	entry.function = @"TestFunction";
	entry.file = @"TestFile";
	entry.logLevel = TWLogLevelInfo;
	entry.logBody = @"Really long log body";
	entry.datetime = [NSDate date];
	
	[self addLogEntry:entry toDatabase:twSqlite];
	
}

-(void)addLogEntry:(TWLogEntry *)entry toDatabase:(TWSqlite *)database{
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
