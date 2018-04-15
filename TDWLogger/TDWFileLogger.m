//
//  TDWFileLogger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWFileLogger.h"

@interface TDWFileLogger()

@property (nonatomic, strong)NSFileManager *fileManager;
@property (nonatomic, strong)TDWLoggerOptions *options;

@end

@implementation TDWFileLogger

-(instancetype)init{
		TDWLoggerOptions *options = [[TDWLoggerOptions alloc]init];
		
		options.maxPageNum = 80;
		options.pageMaxSize = -1;
		NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
		path = [path stringByAppendingPathComponent:@"TDWLogs"];
		options.filePath = [NSURL URLWithString:path];
	
	return [self initWithOptions:options];
}

-(instancetype)initWithOptions:(TDWLoggerOptions *)options{
	if(self = [super init]){
		_fileManager = [NSFileManager defaultManager];
		_options = options;
	}
	
	return self;
}

-(void)logReceived:(TDWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method{
	
}

@end
