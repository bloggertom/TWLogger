//
//  TWLoggerTest.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 02/05/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWLoggerTest.h"

@implementation TWLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_baseDir  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	_fileManager = [NSFileManager defaultManager];
	_logPath = [self getLogDirPath];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[self.logger stopLogging];
	[self removeLogDir: self.logPath];
    [super tearDown];
}

-(void)setOptions:(TWLoggerOptions *)options{
	if([self.logger respondsToSelector:@selector(setOptions:)]){
		[self.logger performSelector:@selector(setOptions:) withObject:options];
	}
}

-(TWLoggerOptions *)options{
	if([self.logger respondsToSelector:@selector(options)]){
		return [self.logger performSelector:@selector(options)];
	}
	return nil;
}

-(NSString *)getLogDirPath{
	return [self.baseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"TestLogDir-%lld",(long long)[NSDate date].timeIntervalSince1970]];
}

-(void)removeLogDir:(NSString *)logDirPath{
	[[NSFileManager defaultManager]removeItemAtPath:logDirPath error:nil];
}

@end
