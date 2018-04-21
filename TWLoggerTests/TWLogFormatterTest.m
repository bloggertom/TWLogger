//
//  TWLogFormatterTest.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWLogFormatterProject.h"
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
	NSString *format = [NSString stringWithFormat:@"%@,%@,%@,%@", TWLogFormatDateTime, TWLogFormatFile, TWLogFormatFunction, TWLogFormatBody];
	TWLogFormatter *formatter = [[TWLogFormatter alloc]initWithFormat:format];
	NSString *logBody = @"Log Body";
	NSString *fileName = @"ComplexFilesAreComplex";
	NSString *functionName = @"ObjectiveCFunctionsAreVerbose";
	
	NSString *formattedLog = [formatter formatLog:TDWLogLevelDebug body:logBody fromFile:fileName forMethod:functionName];
	
	NSArray *components = [formattedLog componentsSeparatedByString:@","];
	XCTAssert(components.count == 4);
	//Get dates tested. Probably needs formatting.
	//NSDate *date;
	
	
	XCTAssertEqualObjects(fileName, components[1]);
	XCTAssertEqualObjects(functionName, components[2]);
	XCTAssertEqualObjects(logBody, components[3]);
	
}

@end
