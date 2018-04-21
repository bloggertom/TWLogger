//
//  TWLogFormatterTest.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWLogFormatterProject.h"
#import "TWUtils.h"
@interface TWLogFormatterTest : XCTestCase

@end

@implementation TWLogFormatterTest

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFormatting {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
	NSString *format = [NSString stringWithFormat:@"%@,%@,%@,%@,%@", TWLogFormatDateTime, TWLogFormatFile, TWLogFormatFunction, TWLogFormatBody, TWLogFormatLevel];
	TWLogFormatter *formatter = [[TWLogFormatter alloc]initWithLogFormat:format];
	NSString *logBody = @"Log Body";
	NSString *fileName = @"ComplexFilesAreComplex";
	NSString *functionName = @"ObjectiveCFunctionsAreVerbose";
	NSString *levelStr = [TWUtils logLevelString:TWLogLevelDebug];
	
	NSString *formattedLog = [formatter formatLog:TWLogLevelDebug body:logBody fromFile:fileName forFunction:functionName];
	
	NSArray *components = [formattedLog componentsSeparatedByString:@","];
	XCTAssert(components.count == 5);
	//Get dates tested. Probably needs formatting.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	dateFormatter.dateFormat = TWDateTimeFormatDefault;
	
	NSDate *date = [dateFormatter dateFromString:components[0]];
	
	XCTAssertNotNil(date);
	XCTAssertEqualObjects(fileName, components[1]);
	XCTAssertEqualObjects(functionName, components[2]);
	XCTAssertEqualObjects(logBody, components[3]);
	XCTAssertEqualObjects(levelStr, components[4]);
	NSLog(@"%@",formattedLog);
	
}

@end
