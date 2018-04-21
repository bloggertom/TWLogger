//
//  TDWFileLoggerTest.m
//  TDWLoggerTests
//
//  Created by Thomas Wilson on 17/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TWLogger/TWLogger.h>

@interface TWFileLogger()
@property (nonatomic, strong)TWLoggerOptions *options;
-(void)stopLogging;
@end

@interface TWFileLoggerTest : XCTestCase
@property (nonatomic, strong)NSFileManager *fileManager;
@property (nonatomic, strong)NSString *baseDir;
@property (nonatomic, strong)TWFileLogger *fileLogger;
@property (nonatomic, strong)NSString *logPath;
@end

@implementation TWFileLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_baseDir  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	_fileManager = [NSFileManager defaultManager];
	_fileLogger = [[TWFileLogger alloc]init];
	_logPath = [self getLogDirPath];
	
	self.fileLogger.options.loggingDirectory = self.logPath;
	
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
	[self.fileLogger stopLogging];
	[self removeLogDir: self.logPath];
	
}
-(NSString *)getLogDirPath{
	return [self.baseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"TestLogDir-%lld",(long long)[NSDate date].timeIntervalSince1970]];
}

-(void)removeLogDir:(NSString *)logDirPath{
		[[NSFileManager defaultManager]removeItemAtPath:logDirPath error:nil];
}

-(void)testLogCreation{
	NSString *logMessage = @"Logging Test";

	[self.fileLogger logReceived:TDWLogLevelDebug body:logMessage fromFile:[NSString stringWithFormat:@"%s",__FILE__] forMethod:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	[self logTest:logMessage];
	
}

-(void)logTest:(NSString *)expectedResult{
	NSError *error = nil;
	NSArray *testDirContents = [self.fileManager contentsOfDirectoryAtPath:self.logPath error:&error];
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
		[self.fileLogger logReceived:TDWLogLevelDebug body:[NSString stringWithFormat:format,i] fromFile:[NSString stringWithFormat:@"%s",__FILE__] forMethod:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
		[expectedResult appendFormat:format, i];
	}
	
	[self logTest:expectedResult];
}

-(void)testLogFileExists{
	NSString *logText = @"Extra Log";
	
	[self testExpiringLog];//create 2 logs files
	[self.fileLogger stopLogging];
	
	_fileLogger = [[TWFileLogger alloc]init];
	self.fileLogger.options.loggingDirectory = self.logPath;
	
	[self.fileLogger logReceived:TDWLogLevelDebug body:logText fromFile:[NSString stringWithUTF8String:__FILE__] forMethod:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
	
	NSError *error = nil;
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:self.logPath error:&error];
	
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
	self.fileLogger.options.pageLife.day = 0;
	self.fileLogger.options.pageLife.second = 1;
	NSString *logMessage1 = @"Log Message 1";
	NSString *logMessage2 = @"Log Message 2";
	[self.fileLogger logReceived:TDWLogLevelDebug body:logMessage1 fromFile:[NSString stringWithFormat:@"%s",__FILE__] forMethod:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	[NSThread sleepForTimeInterval:2];
	
	[self.fileLogger logReceived:TDWLogLevelDebug body:logMessage2 fromFile:[NSString stringWithFormat:@"%s", __FILE__] forMethod:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	NSError *error = nil;
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:self.logPath error:&error];
	
	XCTAssertNil(error);
	XCTAssert(contents.count == 2);
	
	contents = [contents sortedArrayUsingSelector:@selector(compare:)];
	
	NSString *file1Path = [contents objectAtIndex:0];
	NSString *file2Path = [contents objectAtIndex:1];
	
	error = nil;
	NSString *file1Content = [NSString stringWithContentsOfFile:[self.fileLogger.options.loggingDirectory stringByAppendingPathComponent:file1Path] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(logMessage1, file1Content);

	error = nil;
	NSString *file2Content = [NSString stringWithContentsOfFile:[self.fileLogger.options.loggingDirectory stringByAppendingPathComponent:file2Path] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(logMessage2, file2Content);
}

-(void)testLogCacheSize{
	
	self.fileLogger.options.maxPageSize = 1;// 1Kb
	NSString *logMessage = [self getRandomString:1500];
	
	[self.fileLogger logReceived:TDWLogLevelDebug body:logMessage fromFile:[NSString stringWithUTF8String:__FILE__] forMethod:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
	
	NSError *error = nil;
	NSArray *logCache = [self.fileManager contentsOfDirectoryAtPath:self.logPath error:&error];
	
	XCTAssertNil(error);
	XCTAssert(logCache.count == 1);
	
	error = nil;
	NSString *logContent = [NSString stringWithContentsOfFile:[self.logPath stringByAppendingPathComponent:logCache.firstObject] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertEqualObjects(logMessage, logContent);
	
	NSString *newLog = @"The new log";
	[self.fileLogger logReceived:TDWLogLevelDebug body:newLog fromFile:[NSString stringWithUTF8String:__FILE__] forMethod:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];
	
	error = nil;
	logCache = [self.fileManager contentsOfDirectoryAtPath:self.logPath error:&error];
	
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
@end
