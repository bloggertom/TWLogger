//
//  TDWFileLogger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWFileLogger.h"
#import "TDWLog.h"
@interface TDWFileLogger()

@property (nonatomic, strong)NSFileManager *fileManager;
@property (nonatomic, strong)TDWLoggerOptions *options;
@property (nonatomic, strong)NSFileHandle *currentLogHandle;

@end

@implementation TDWFileLogger

-(instancetype)init{
	TDWLoggerOptions *options = [[TDWLoggerOptions alloc]init];
	
	options.maxPageNum = 80;
	options.pageMaxSize = -1;
	options.logFilePrefix = @"TDWLogFiles";
	options.pageLife = [[NSDateComponents alloc]init];
	options.pageLife.day = 1;
	
	NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	path = [path stringByAppendingPathComponent:@"TDWLogs"];
	options.filePath = [NSURL URLWithString:path];
	
	return [self initWithOptions:options];
}

-(instancetype)initWithOptions:(TDWLoggerOptions *)options{
	if(self = [super init]){
		_fileManager = [NSFileManager defaultManager];
		_options = options;
		self.logging = YES;
	}
	
	return self;
}

-(void)logReceived:(TDWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method{
	if(!self.isLogging){
		return;
	}
	
}

-(NSFileHandle *)getLogFileHandle{
	BOOL isDirectory = NO;
	if(![self.fileManager fileExistsAtPath:self.options.filePath.absoluteString isDirectory:&isDirectory]){
		NSError *error = nil;
		if(![self.fileManager createDirectoryAtURL:self.options.filePath withIntermediateDirectories:YES attributes:nil error:&error]){
			[TDWLog systemLog:@"Failed create logging directory"];
			[TDWLog systemLog:[NSString stringWithFormat:@"%@",error]];
			self.logging = NO;
			return nil;
		}
	}
	
	if(isDirectory){
		NSError *error = nil;
		NSArray *files = [self.fileManager contentsOfDirectoryAtPath:self.options.filePath.absoluteString error:&error];
		if(files.count == 0){
			if(error){
				[TDWLog systemLog:@"Failed to initialise log file system"];
				[TDWLog systemLog:[NSString stringWithFormat:@"%@",error]];
				self.logging = NO;
				return nil;
			}
			return [self handleToNewLogFile];
			
		}else{
			NSArray *logFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
				if([evaluatedObject isKindOfClass:[NSString class]]){
					NSString *fileName = (NSString *)evaluatedObject;
					return [fileName hasPrefix:self.options.logFilePrefix];
				}
				return NO;
			}]];
			
			return [self handleToExistingLogFile:logFiles];
		}
	}else{
			//Error;
	}
	
	return nil;
}

-(NSFileHandle *)handleToNewLogFile{
	return nil;
}

-(NSFileHandle *)handleToExistingLogFile:(NSArray<NSString *> *)files{
	if(files.count == 0){
		return [self handleToNewLogFile];
	}
	
	return nil;
}

BOOL _logging;
-(BOOL)isLogging{
	return _logging;
}

-(void)setLogging:(BOOL)logging{
	_logging = logging;
}
@end
