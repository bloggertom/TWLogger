//
//  TDWLoggerTests.m
//  TDWLoggerTests
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TWLogger/TWLogger.h>

@interface TWFileLogger()
@property (nonatomic, strong)TWLoggerOptions *options;
-(void)stopLogging;
@end

@interface TWLoggerTests : XCTestCase

@end

@implementation TWLoggerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testConcurrentFileLogging{
	TWFileLogger *fileLogger = [[TWFileLogger alloc]init];
	[TWLog addLogger:fileLogger];
	
	NSArray *logStrings = [self performConcurrentLogs];
	
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileLogger.options.loggingDirectory error:&error];
	
	XCTAssertNil(error);
	XCTAssertTrue(contents.count == 1);
	
	error = nil;
	NSString *fileContent = [NSString stringWithContentsOfFile:[fileLogger.options.loggingDirectory  stringByAppendingPathComponent:contents.firstObject]  encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(fileContent);
	
	for (NSString *log in logStrings) {
		NSRange range = [fileContent rangeOfString:log];
		XCTAssertTrue(range.location != NSNotFound);
		XCTAssertEqual(range.length, log.length);
	}
	
	[TWLog removeLogger:fileLogger];
	[[NSFileManager defaultManager] removeItemAtPath:fileLogger.options.loggingDirectory error:&error];
}

-(NSArray<NSString *> *)performConcurrentLogs{
	NSMutableArray *expectations = [[NSMutableArray alloc]init];
	NSMutableArray *logStrings = [[NSMutableArray alloc]init];
	for(int i=0; i<50; i++){
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
