//
//  TWLoggerTests.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TWLogger/TWLogger.h>
#import "TWSqlite.h"
#import "TWSqliteLogEntry.h"
#import "TWUtils.h"

@interface TWFileLogger()
@property (nonatomic, strong)TWLoggerOptions *options;
-(void)stopLogging;
@end

@interface TWLoggerFrameworkTests : XCTestCase

@end

@implementation TWLoggerFrameworkTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testNSLogToFile{
	TWFileLogger *fileLogger = [[TWFileLogger alloc]init];
	[TWLog addLogger:fileLogger];
	NSString *logMessage = @"logging NSLog logging test";
	NSLog(logMessage);
	
	[self checkLogFolderContents:fileLogger.options.loggingAddress result:[NSString stringWithFormat:@"%@\n", logMessage]];
									   
	[self cleanUpLogger:fileLogger];
}

-(void)testTWLog{
	TWFileLogger *fileLogger = [[TWFileLogger alloc]init];
	[TWLog addLogger:fileLogger];
	NSString *logMessage = @"logging NSLog logging test";
	TWLog(TWLogLevelDebug, logMessage);
	
	[self checkLogFolderContents:fileLogger.options.loggingAddress result:[NSString stringWithFormat:@"%@\n",logMessage]];
	
	[self cleanUpLogger:fileLogger];
}

-(void)testLevelDefines{
	TWSqliteLogger *logger =  [[TWSqliteLogger alloc]init];
	logger.flushPeriod = nil;
	logger.cacheSize = 0;
	
	[TWLog addLogger:logger];
	
	TWLogDebug(@"Debug");
	TWLogWarning(@"Warning");
	TWLogInfo(@"Info");
	TWLogFatal(@"Fatal");
	
	[TWLog removeLogger:logger];
	
	NSError *error = nil;
	TWSqlite *db = [TWSqlite openDatabaseAtPath:[self getLogFilePath:logger] error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(db);
	
	error = nil;
	NSArray<TWSqliteLogEntry *> *logs = [db selectAllLogEntries:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(logs);
	XCTAssertEqual(4, logs.count);
	
	NSDictionary *dic = @{logs[0].logBody : logs[0].logLevel,
						  logs[1].logBody : logs[1].logLevel,
						  logs[2].logBody : logs[2].logLevel,
						  logs[3].logBody : logs[3].logLevel,
						  };
	
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelDebug], [dic objectForKey:@"Debug\n"]);
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelInfo], [dic objectForKey:@"Info\n"]);
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelWarning], [dic objectForKey:@"Warning\n"]);
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelFatal], [dic objectForKey:@"Fatal\n"]);
	
	[TWSqlite closeDatabase];
	
	[self cleanUpLogger:logger];
}

-(void)testLoggingFilter{
	TWSqliteLogger *logger =  [[TWSqliteLogger alloc]init];
	logger.flushPeriod = nil;
	logger.cacheSize = 0;
	
	[TWLog addLogger:logger];
	
	[TWLog setLogLevelFilter:TWLogLevelInfo];
	
	TWLogDebug(@"Debug");
	TWLogWarning(@"Warning");
	TWLogInfo(@"Info");
	TWLogFatal(@"Fatal");
	NSLog(@"NSLog");//default to debug
	
	[TWLog removeLogger:logger];
	
	NSError *error = nil;
	TWSqlite *db = [TWSqlite openDatabaseAtPath:[self getLogFilePath:logger] error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(db);
	
	error = nil;
	NSArray<TWSqliteLogEntry *> *logs = [db selectAllLogEntries:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(logs);
	XCTAssertEqual(3, logs.count);
	
	NSDictionary *dic = @{logs[0].logBody : logs[0].logLevel,
						  logs[1].logBody : logs[1].logLevel,
						  logs[2].logBody : logs[2].logLevel,
						  };
	
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelInfo], [dic objectForKey:@"Info\n"]);
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelWarning], [dic objectForKey:@"Warning\n"]);
	XCTAssertEqualObjects([TWUtils logLevelString:TWLogLevelFatal], [dic objectForKey:@"Fatal\n"]);
	
	[TWSqlite closeDatabase];
	
	[self cleanUpLogger:logger];
}

-(void)checkLogFolderContents:(NSString *)loggingDirectory result:(NSString *)expectedContents{
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:loggingDirectory error:&error];
	
	XCTAssertNil(error);
	XCTAssert(contents.count == 1);
	
	error = nil;
	NSString *logContent = [NSString stringWithContentsOfFile:[loggingDirectory stringByAppendingPathComponent:contents.firstObject] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(logContent);
	
	XCTAssertEqualObjects(expectedContents, logContent);
}

-(void)cleanUpLogger:(id<TWLoggerDelegate>)logger{
	[TWLog removeLogger:logger];
	
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logger.options.loggingAddress error:&error];
	
	XCTAssertNil(error);
	XCTAssert(contents.count == 1);
	
	error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:logger.options.loggingAddress error:&error];
	XCTAssertNil(error);
}
-(void)testConcurrentFileLogging{
	TWFileLogger *fileLogger = [[TWFileLogger alloc]init];
	[TWLog addLogger:fileLogger];
	
	NSArray *logStrings = [self performConcurrentLogs];
	
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileLogger.options.loggingAddress error:&error];
	
	XCTAssertNil(error);
	XCTAssertTrue(contents.count == 1);
	
	error = nil;
	NSString *fileContent = [NSString stringWithContentsOfFile:[self getLogFilePath:fileLogger]  encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(fileContent);
	
	for (NSString *log in logStrings) {
		NSRange range = [fileContent rangeOfString:log];
		XCTAssertTrue(range.location != NSNotFound);
		XCTAssertEqual(range.length, log.length);
	}
	
	[self cleanUpLogger:fileLogger];
}

-(NSString *)getLogFilePath:(id<TWLoggerDelegate>)logger{
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logger.options.loggingAddress error:&error];
	
	XCTAssertNil(error);
	XCTAssertTrue(contents.count == 1);
	return [logger.options.loggingAddress  stringByAppendingPathComponent:contents.firstObject];
	
}
-(NSArray<NSString *> *)performConcurrentLogs{
	NSMutableArray *expectations = [[NSMutableArray alloc]init];
	NSMutableArray *logStrings = [[NSMutableArray alloc]init];
	for(int i=0; i<100; i++){
		XCTestExpectation *expectation = [[XCTestExpectation alloc]initWithDescription:[NSString stringWithFormat:@"Test Expectation %d",i]];
		[expectations addObject:expectation];
		NSString *logString = [NSString stringWithFormat:@"Log num %d",i];
		[logStrings addObject:logString];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSLog(logString);
			[expectation fulfill];
		});
	}
	[self waitForExpectations:expectations timeout:180];
	
	return logStrings;
}
@end
