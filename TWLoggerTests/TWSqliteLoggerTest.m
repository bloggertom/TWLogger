//
//  TWSqliteLoggerTest.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 02/05/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWLoggerTest.h"
#import "TWSqliteLogger.h"
#import "TWSqlite.h"
#import <OCMock/OCMock.h>

@interface TWSqliteLoggerTest : TWLoggerTest
@end

@implementation TWSqliteLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

//Called by super class.
-(void)setUpLogger{
	self.logger = [[TWSqliteLogger alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[TWSqlite closeDatabase];
    [super tearDown];
}

-(void)testLogCreation{
	[self.logger stopLogging];
	
	//Instant flush
	self.options.flushPeriod = nil;
	self.options.maxPageNum = 0;
	self.logger = [[TWSqliteLogger alloc]initWithOptions:self.options];
	XCTAssertTrue([self.logger startLogging]);
	
	[self.logger logReceived:TWLogLevelInfo body:@"Body of info" fromFile:@"File" forFunction:@"function"];
	
	NSError *error = nil;
	NSArray *contents = [self contentsOfLogDir:&error];
	
	XCTAssertNotNil(contents);
	XCTAssertNil(error);
	XCTAssertEqual(1, contents.count);
	
	NSString *file = [contents firstObject];
	XCTAssertTrue([file hasPrefix:self.options.logFilePrefix]);
	
	[self.logger stopLogging];
	
	[self checkLogExists];
}

-(void)testFlushTiming{
	[self.logger stopLogging];
	
	TWSqliteLogger *logger = [[TWSqliteLogger alloc]init];
	logger.options.flushPeriod.second = 2;
	logger.options.loggingAddress = self.logPath;
	id<TWLoggerDelegate> mockLogger = OCMPartialMock(logger);
	
	XCTAssertTrue([mockLogger startLogging]);
	[mockLogger logReceived:TWLogLevelInfo body:@"Body" fromFile:@"File" forFunction:@"function"];
	
	[NSThread sleepForTimeInterval:3];
	
	OCMVerify([mockLogger flushLogs]);
	
	[logger stopLogging];
	
	[self checkLogExists];
	
}

-(void)testClosingFlush{
	[self.logger stopLogging];
	
	TWSqliteLogger *logger = [[TWSqliteLogger alloc]init];
	//logger.options.flushPeriod.second = 10; Default;
	logger.options.loggingAddress = self.logPath;
	id<TWLoggerDelegate> mockLogger = OCMPartialMock(logger);

	XCTAssertTrue([mockLogger startLogging]);
	[mockLogger logReceived:TWLogLevelInfo body:@"Body" fromFile:@"File" forFunction:@"function"];
	[mockLogger stopLogging];
	OCMVerify([mockLogger flushLogs]);
	
	[self checkLogExists];
}

-(void)testCloseFlushIsNotBlocked{
	[self.logger stopLogging];
	
	TWSqliteLogger *logger = [[TWSqliteLogger alloc]init];
	//logger.options.flushPeriod.second = 10; Default;
	logger.options.loggingAddress = self.logPath;
	XCTAssertEqual(10, logger.options.flushPeriod.second);
	id<TWLoggerDelegate> mockLogger = OCMPartialMock(logger);
	
	XCTestExpectation *expectation = [[XCTestExpectation alloc]initWithDescription:@"Not waiting for schedualed flushed"];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		XCTAssertTrue([mockLogger startLogging]);
		[mockLogger logReceived:TWLogLevelInfo body:@"Body" fromFile:@"File" forFunction:@"function"];
		[mockLogger stopLogging];
		OCMVerify([mockLogger flushLogs]);
		[expectation fulfill];
	});
	
	[self waitForExpectations:@[expectation] timeout:5];
	
	[self checkLogExists];
}

-(void)testLogStorageCapacity{
	[self.logger stopLogging];
	
	TWSqliteLogger *logger = [[TWSqliteLogger alloc]init];
	logger.options.loggingAddress = self.logPath;
	logger.options.flushPeriod.second = 0;// set flush period to something stupid.
	logger.options.flushPeriod.hour = 1;
	logger.options.maxPageNum = 3;
	
	TWSqliteLogger *mockLogger = OCMPartialMock(logger);
	XCTAssertTrue([mockLogger startLogging]);
	
	for (int i=0; i<4; i++){
		[mockLogger logReceived:TWLogLevelInfo body:@"Body" fromFile:@"File" forFunction:@"function"];
	}
	
	OCMVerify([mockLogger flushLogs]);
	
	[mockLogger stopLogging];
	
	TWSqlite *db = [self getTwSqliteDatabase];
	
	NSError *error = nil;
	NSArray *logs = [db selectAllLogEntries:&error];
	
	XCTAssertNotNil(logs);
	XCTAssertNil(error);
	
	XCTAssertEqual(4, logs.count);
}

-(TWSqlite *)getTwSqliteDatabase:(NSString *)path{
	NSError *error = nil;
	TWSqlite *db = [TWSqlite openDatabaseAtPath:path error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(db);
	
	return db;
}

-(TWSqlite *)getTwSqliteDatabase{
	NSError *error = nil;
	NSArray *contents = [self contentsOfLogDir:&error];
	
	XCTAssertNotNil(contents);
	XCTAssertNil(error);
	XCTAssertEqual(1, contents.count);
	
	NSString *file = [contents firstObject];
	XCTAssertTrue([file hasPrefix:self.options.logFilePrefix]);
	
	NSString *logDbPath = [self.logPath stringByAppendingPathComponent:file];
	TWSqlite *db = [self getTwSqliteDatabase:logDbPath];
	
	XCTAssertNil(error);
	XCTAssertNotNil(db);
	
	return db;
}

-(void)checkLogExists{
	TWSqlite *db = [self getTwSqliteDatabase];
	
	NSError *error = nil;
	NSArray *logs = [db selectAllLogEntries:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(logs);
	XCTAssertEqual(1, logs.count);
}

@end
