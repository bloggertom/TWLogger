//
//  TDWFileLoggerTest.m
//  TDWLoggerTests
//
//  Created by Thomas Wilson on 17/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TDWLogger/TDWLogger.h>

@interface TDWFileLoggerTest : XCTestCase
@property (nonatomic, strong)TDWFileLogger *fileLogger;
@property (nonatomic, strong)NSString *logDirPath;
@property (nonatomic, strong)NSFileManager *fileManager;
@end

@implementation TDWFileLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_fileLogger = [[TDWFileLogger alloc]init];
	[TDWLog addLogger:self.fileLogger];
	
	_logDirPath  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	_logDirPath = [self.logDirPath stringByAppendingPathComponent:@"TDWLogFiles"];
	_fileManager = [NSFileManager defaultManager];
	
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	self.fileLogger = nil;
	[TDWLog removeLogger:self.fileLogger];
	_fileLogger = nil;
	
	[[NSFileManager defaultManager]removeItemAtPath:self.logDirPath error:nil];
	
    [super tearDown];
}

-(void)testLogCreation{
	NSString *logMessage = @"Logging Test";
	NSError *error = nil;
	NSArray *testDirContents = [self.fileManager contentsOfDirectoryAtPath:self.logDirPath error:&error];
	
	XCTAssertNotNil(error);
	XCTAssertNil(testDirContents);
	NSLog(logMessage);
	
	error = nil;

	testDirContents = [self.fileManager contentsOfDirectoryAtPath:self.logDirPath error:&error];
	XCTAssertNil(error);
	XCTAssert(testDirContents.count == 1);
	
	error = nil;
	NSString *fileContents = [NSString stringWithContentsOfFile:[self.logDirPath stringByAppendingPathComponent:[testDirContents firstObject]] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssert([logMessage isEqualToString:[fileContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]);
	
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
