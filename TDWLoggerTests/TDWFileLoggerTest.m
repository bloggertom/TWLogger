//
//  TDWFileLoggerTest.m
//  TDWLoggerTests
//
//  Created by Thomas Wilson on 17/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TDWLogger/TDWLogger.h>

@interface TDWFileLogger()
@property (nonatomic, strong)TDWLoggerOptions *options;
-(void)stopLogging;
@end

@interface TDWFileLoggerTest : XCTestCase
@property (nonatomic, strong)NSFileManager *fileManager;
@property (nonatomic, strong)NSString *baseDir;
@end

@implementation TDWFileLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_baseDir  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	_fileManager = [NSFileManager defaultManager];
	
	
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}
-(NSString *)getLogDirPath{
	return [self.baseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"TestLogDir-%lld",(long long)[NSDate date].timeIntervalSince1970]];
}
-(void)removeLogDir:(NSString *)logDirPath{
		[[NSFileManager defaultManager]removeItemAtPath:logDirPath error:nil];
}

-(void)testLogCreation{
	NSString *logMessage = @"Logging Test";
	
	TDWFileLogger *fileLogger = [[TDWFileLogger alloc] init];
	NSString *logPath = [self getLogDirPath];
	fileLogger.options.filePath = logPath;

	[fileLogger logReceived:TDWLogLevelDebug body:logMessage fromFile:[NSString stringWithFormat:@"%s",__FILE__] forMethod:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
	
	[self logTest:logMessage logPath:logPath];
	
	[fileLogger stopLogging];
	[self removeLogDir: logPath];
}
-(void)logTest:(NSString *)expectedResult logPath:(NSString *)logDirPath{
	NSError *error = nil;
	NSArray *testDirContents = [self.fileManager contentsOfDirectoryAtPath:logDirPath error:&error];
	XCTAssertNil(error);
	XCTAssert(testDirContents.count == 1);
	
	error = nil;
	NSString *fileContents = [NSString stringWithContentsOfFile:[logDirPath stringByAppendingPathComponent:[testDirContents firstObject]] encoding:NSASCIIStringEncoding error:&error];
	
	XCTAssert([expectedResult isEqualToString:fileContents]);
}

- (void)testMultipleLogs{
	TDWFileLogger *fileLogger = [[TDWFileLogger alloc]init];
	NSString *filePath = [self getLogDirPath];
	fileLogger.options.filePath = filePath;
	NSMutableString *expectedResult = [[NSMutableString alloc]init];
	NSString *format = @"Log test %d";
	for(int i=0; i<3; i++){
		[fileLogger logReceived:TDWLogLevelDebug body:[NSString stringWithFormat:format,i] fromFile:[NSString stringWithFormat:@"%s",__FILE__] forMethod:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
		[expectedResult appendFormat:format, i];
	}
	
	[self logTest:expectedResult logPath:filePath];
	
	
	[fileLogger stopLogging];
	[self removeLogDir:filePath];
}


@end
