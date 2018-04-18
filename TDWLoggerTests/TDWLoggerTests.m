//
//  TDWLoggerTests.m
//  TDWLoggerTests
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TDWLogger/TDWLogger.h>

@interface TDWFileLogger()
@property (nonatomic, strong)TDWLoggerOptions *options;
-(void)stopLogging;
@end

@interface TDWLoggerTests : XCTestCase

@end

@implementation TDWLoggerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testConcurrentFileLogging{
	TDWFileLogger *fileLogger = [[TDWFileLogger alloc]init];
	[TDWLog addLogger:fileLogger];
	
	NSArray *logStrings = [self performConcurrentLogs];
	
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileLogger.options.filePath error:&error];
	
	XCTAssertNil(error);
	XCTAssertTrue(contents.count == 1);
	
	error = nil;
	NSString *fileContent = [NSString stringWithContentsOfFile:[fileLogger.options.filePath  stringByAppendingPathComponent:contents.firstObject]  encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(fileContent);
	
	for (NSString *log in logStrings) {
		NSRange range = [fileContent rangeOfString:log];
		XCTAssertTrue(range.location != NSNotFound);
		XCTAssertEqual(range.length, log.length);
	}
	
	[TDWLog removeLogger:fileLogger];
	[[NSFileManager defaultManager] removeItemAtPath:fileLogger.options.filePath error:&error];
}

-(NSArray<NSString *> *)performConcurrentLogs{
	NSMutableArray *expectations = [[NSMutableArray alloc]init];
	NSMutableArray *logStrings = [[NSMutableArray alloc]init];
	for(int i=0; i<50; i++){
		XCTestExpectation *expectation = [[XCTestExpectation alloc]initWithDescription:[NSString stringWithFormat:@"Test Excpection %d",i]];
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
