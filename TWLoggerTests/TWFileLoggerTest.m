//
//  TDWFileLoggerTest.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 17/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWFileLogger.h"
#import "TWLoggerTest.h"

@interface TWFileLogger()
-(NSString *)createMetaDataString:(NSDictionary *)metaData;
@end

@interface TWFileLoggerTest : TWLoggerTest
@end

@implementation TWFileLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)setUpLogger{
	self.logger = [[TWFileLogger alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

-(void)testLogCreation{
	NSString *logMessage = @"Logging Test";

	[self.logger logReceived:TWLogLevelDebug body:logMessage fromFile:[NSString stringWithFormat:@"%s",__FILE__] forFunction:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	[self logTest:logMessage];
	
}

-(void)logTest:(NSString *)expectedResult{
	NSError *error = nil;
	NSArray *testDirContents = [self contentsOfLogDir:&error];
	XCTAssertNil(error);
	XCTAssert(testDirContents.count == 1);
	
	error = nil;
	NSString *fileContents = [NSString stringWithContentsOfFile:[self.logPath stringByAppendingPathComponent:[testDirContents firstObject]] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssert([expectedResult isEqualToString:fileContents]);
}

- (void)testMultipleLogs{
	NSMutableString *expectedResult = [[NSMutableString alloc]init];
	NSString *format = @"Log test %d";
	for(int i=0; i<3; i++){
		[self.logger logReceived:TWLogLevelDebug body:[NSString stringWithFormat:format,i] fromFile:[NSString stringWithFormat:@"%s",__FILE__] forFunction:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
		[expectedResult appendFormat:format, i];
	}
	
	[self logTest:expectedResult];
}

-(void)testLogFileExists{
	NSString *logText = @"Extra Log";
	
	[self testExpiringLog];//create 2 logs files
	[self.logger stopLogging];
	
	self.logger = [[TWFileLogger alloc]init];
	self.options.loggingAddress = self.logPath;
	[self.logger startLogging];
	
	[self.logger logReceived:TWLogLevelDebug body:logText fromFile:[NSString stringWithUTF8String:__FILE__] forFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
	
	NSError *error = nil;
	NSArray *contents = [self contentsOfLogDir:&error];
	
	XCTAssertNil(error);
	XCTAssert(contents.count == 2);
	
	contents = [contents sortedArrayUsingSelector:@selector(compare:)];
	
	error = nil;
	NSString *expectedResult = [NSString stringWithFormat:@"Log Message 2%@", logText];
	NSString *fileContent = [NSString stringWithContentsOfFile:[self.logPath stringByAppendingPathComponent:contents.lastObject] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(expectedResult, fileContent);
}

-(void)testExpiringLog{
	((TWFileLogger*)self.logger).pageLife.day = 0;
	((TWFileLogger*)self.logger).pageLife.second = 1;
	NSString *logMessage1 = @"Log Message 1";
	NSString *logMessage2 = @"Log Message 2";
	[self.logger logReceived:TWLogLevelDebug body:logMessage1 fromFile:[NSString stringWithFormat:@"%s",__FILE__] forFunction:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	[NSThread sleepForTimeInterval:2];
	
	[self.logger logReceived:TWLogLevelDebug body:logMessage2 fromFile:[NSString stringWithFormat:@"%s", __FILE__] forFunction:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	NSError *error = nil;
	NSArray *contents = [self contentsOfLogDir:&error];
	
	XCTAssertNil(error);
	XCTAssert(contents.count == 2);
	
	contents = [contents sortedArrayUsingSelector:@selector(compare:)];
	
	NSString *file1Path = [contents objectAtIndex:0];
	NSString *file2Path = [contents objectAtIndex:1];
	
	error = nil;
	NSString *file1Content = [NSString stringWithContentsOfFile:[self.options.loggingAddress stringByAppendingPathComponent:file1Path] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(logMessage1, file1Content);

	error = nil;
	NSString *file2Content = [NSString stringWithContentsOfFile:[self.options.loggingAddress stringByAppendingPathComponent:file2Path] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(logMessage2, file2Content);
}

-(void)testLogSize{
	
	((TWFileLogger*)self.logger).maxPageSize = 1;// 1Kb
	NSString *logMessage = [self getRandomString:1500];
	
	[self.logger logReceived:TWLogLevelDebug body:logMessage fromFile:[NSString stringWithUTF8String:__FILE__] forFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
	
	NSError *error = nil;
	NSArray *logCache = [self contentsOfLogDir:&error];
	
	XCTAssertNil(error);
	XCTAssert(logCache.count == 1);
	
	error = nil;
	NSString *logContent = [NSString stringWithContentsOfFile:[self.logPath stringByAppendingPathComponent:logCache.firstObject] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(logMessage, logContent);
	
	NSString *newLog = @"The new log";
	[self.logger logReceived:TWLogLevelDebug body:newLog fromFile:[NSString stringWithUTF8String:__FILE__] forFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
	
	error = nil;
	logCache = [self contentsOfLogDir:&error];
	
	XCTAssertNil(error);
	XCTAssert(logCache.count == 2);
	
	logCache = [logCache sortedArrayUsingSelector:@selector(compare:)];
	
	error = nil;
	logContent = [NSString stringWithContentsOfFile:[self.logPath stringByAppendingPathComponent:logCache.lastObject] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(newLog, logContent);
	
}
-(NSString *)getRandomString:(NSUInteger)size{
	NSRange range = NSMakeRange(33, 93);
	unichar charArray[size];
	
	for(int i=0; i<size; i++){
		charArray[i] = (char) arc4random_uniform((int)range.length) + range.location;
	}
	
	return [NSString stringWithCharacters:&charArray[0] length:size];
}

-(void)testLogFileFormatting{
	TWFileLogger *fileLogger = [[TWFileLogger alloc]init];
	fileLogger.logFormatter = [TWLogFormatter defaultLogFormatter];
	
	//TODO: this needs finishing?
}

-(void)testMetadata{
	[self.logger stopLogging];
	[self resetLogs];
	
	NSDictionary *metaData = @{@"Key1" : @"Value1",
							   @"Key2" : @"Value2",
							   @"Key3" : @"Value3",
							   };
	self.options.metaData = metaData;
	
	XCTAssertTrue([self.logger startLogging]);
	
	NSError *error = nil;
	NSArray *logCache = [self contentsOfLogDir:&error];
	
	XCTAssertNil(error);
	XCTAssert(logCache.count == 1);
	
	error = nil;
	NSString *logContent = [NSString stringWithContentsOfFile:[self.logPath stringByAppendingPathComponent:logCache.firstObject] encoding:NSASCIIStringEncoding error:&error];
	TWFileLogger *fileLogger = (TWFileLogger *)self.logger;
	XCTAssertEqualObjects([fileLogger createMetaDataString:metaData], logContent);
}

-(void)resetLogs{
	NSError *error = nil;
	[self.fileManager removeItemAtPath:self.logPath error:&error];
}
@end
