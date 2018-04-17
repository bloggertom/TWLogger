//
//  TDWFileLogger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWFileLogger.h"

#define ERROR_DOMAIN @"TDWFileLogger"

typedef NS_ENUM(NSUInteger, TDWFileLoggerError) {
	TDWFileLoggerErrorUnknown = 2000,
	TDWFileLoggerErrorInvalidFilePath = 2001,
	TDWFileLoggerErrorFailedToCreateLogFile = 2002,
};

@interface TDWFileLogger()

@property (nonatomic, strong)NSFileManager *fileManager;
@property (nonatomic, strong)TDWLoggerOptions *options;
@property (nonatomic, strong)NSFileHandle *currentLogHandle;
@property (nonatomic, strong)NSString *currentLogPath;

@end

@implementation TDWFileLogger

-(instancetype)init{
	TDWLoggerOptions *options = [[TDWLoggerOptions alloc]init];
	
	options.maxPageNum = 80;
	options.maxLogCacheCapacity = 0;
	options.logFilePrefix = @"TDWLog";
	options.pageLife = [[NSDateComponents alloc]init];
	options.pageLife.day = 1;
	
	NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	path = [path stringByAppendingPathComponent:@"TDWLogFiles"];
	options.filePath = path;
	
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
	NSError *error = nil;
	if(_currentLogHandle == nil){
		_currentLogPath = [self getLogFileUrl:&error];
		if(_currentLogPath == nil){
			[self stopLoggingWithMessage:@"Failed to create log file" andError:error];
			return;
		}
		_currentLogHandle = [NSFileHandle fileHandleForWritingAtPath:self.currentLogPath];
		
	}else if([self logFileHasExpired:self.currentLogPath error:&error]){
		//check valid
		[self.currentLogHandle synchronizeFile];
		[self.currentLogHandle closeFile];
		self.currentLogPath = [self getLogFileUrl:&error];
	}
	if(error){
		[TDWLog systemLog:@"Failed to create log file handle"];
		[TDWLog systemLog:[NSString stringWithFormat:@"%@", error]];
		[self stopLogging];
		return;
	}
	
	@try{
		[self.currentLogHandle writeData:[body dataUsingEncoding:NSASCIIStringEncoding]];
		[self.currentLogHandle synchronizeFile];
	}@catch(NSException *e){
		//Possibly means something else is in control of the file.
		[TDWLog systemLog:@"Failed to write to log"];
		[TDWLog systemLog:e.name];
		[TDWLog systemLog:e.reason];
		[self stopLogging];
	}
	
}

-(NSString *)getLogFileUrl:(NSError **)error{
	BOOL isDirectory = NO;
	if(![self.fileManager fileExistsAtPath:self.options.filePath isDirectory:&isDirectory]){
		if(![self.fileManager createDirectoryAtPath:self.options.filePath withIntermediateDirectories:YES attributes:nil error:error]){
			return nil;
		}
		isDirectory = YES;
	}
	
	if(isDirectory){
		NSArray *files = [self.fileManager contentsOfDirectoryAtPath:self.options.filePath error:error];
		if(files.count == 0){
			if(*error){
				return nil;
			}
			return [self urlToNewLogFile:error];
			
		}else{
			NSArray *logFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
				if([evaluatedObject isKindOfClass:[NSString class]]){
					NSString *fileName = (NSString *)evaluatedObject;
					return [fileName hasPrefix:self.options.logFilePrefix];
				}
				return NO;
			}]];
			
			return [self urlToExistingLogFile:logFiles error:error];
		}
	}else if(*error == nil){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TDWFileLoggerErrorInvalidFilePath userInfo:@{NSLocalizedDescriptionKey: @"Invalid log storage directory."}];
	}
	
	return nil;
}

-(NSString *)urlToNewLogFile:(NSError **)error{
	NSString *fileName = [NSString stringWithFormat:@"%@-%f.log",self.options.logFilePrefix, [[NSDate date] timeIntervalSince1970]];
	
	NSString *fileUrl = [self.options.filePath stringByAppendingPathComponent:fileName];
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:self.options.filePath error:error];
	
	if(*error){
		return nil;
	}
	
	if([self logHasReachedCapacity:contents error:error]){
		if([self deleteOldestLog:contents error:error]){
			[TDWLog systemLog:[NSString stringWithFormat:@"Failed to delete old log"]];
		}
	}
	
	if(![self.fileManager createFileAtPath:fileUrl contents:nil attributes:nil]){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TDWFileLoggerErrorFailedToCreateLogFile userInfo:@{NSLocalizedDescriptionKey : @"Failed to create new log file"}];
		return nil;
	}
	
	contents = [contents arrayByAddingObject:fileName];
	if(self.options.maxPageNum > 0 && contents.count > self.options.maxPageNum){
		//Remove oldest file.
		if([self deleteOldestLog:contents error:error]){
			[TDWLog systemLog:[NSString stringWithFormat:@"Failed to delete older log"]];
		}
	}
	
	return fileUrl;
}

-(BOOL)deleteOldestLog:(NSArray *)contents error:(NSError **)error{
	NSString *oldestLog = [self fileNameOfOldestFile:contents];
	return [self.fileManager removeItemAtPath:oldestLog error:error];
}

-(NSString *)urlToExistingLogFile:(NSArray<NSString *> *)files error:(NSError **)error{
	if(files.count == 0){
		return [self urlToNewLogFile:error];
	}
	
	//check it against options to ensure its valid
	NSString *file = [self fileNameOfNewestFile:files];
	
	//life time
	NSString *fileUrl = [self.options.filePath stringByAppendingPathComponent:file];
	BOOL expired = [self logFileHasExpired:fileUrl error:error];
	if(error|| expired){
		return [self urlToNewLogFile:error];
	}
	return fileUrl;
}

-(BOOL)logHasReachedCapacity:(NSArray<NSString*>*)logFiles error:(NSError **)error{
	if(self.options.maxLogCacheCapacity <= 0){
		return NO;
	}
	NSUInteger logsSize = 0;
	for (NSString *logFile in logFiles) {
		NSString *filePath = [self.options.filePath stringByAppendingPathComponent:logFile];
		NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:filePath error:error];
		logsSize += [fileAtt fileSize];
	}
	logsSize = logsSize/1000;
	return (logsSize >= self.options.maxLogCacheCapacity);
}

-(BOOL)logFileHasExpired:(NSString *)logFile error:(NSError **)error{
	if(self.options.pageLife == nil){
		return NO;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:logFile error:error];
	NSDate *fileCreation = [fileAtt fileCreationDate];
	
	NSDate *expiryDate = [calendar dateByAddingComponents:self.options.pageLife toDate:fileCreation options:0];
	NSDate *now = [NSDate date];
	return ([expiryDate compare:now] == NSOrderedDescending || [expiryDate compare:now] == NSOrderedSame);
}

BOOL _logging;
-(BOOL)isLogging{
	return _logging;
}

-(void)setLogging:(BOOL)logging{
	_logging = logging;
}

-(void)stopLoggingWithMessage:(NSString *)message andError:(nullable NSError *)error{
	[TDWLog systemLog:message];
	if(error != nil){
		[TDWLog systemLog:[NSString stringWithFormat:@"%@",error]];
	}
	[self stopLogging];
}

-(void)stopLogging{
	self.logging = NO;
	[self.currentLogHandle synchronizeFile];
	[self.currentLogHandle closeFile];
}
-(NSArray *)sortFilesByCreationDate:(NSArray *)files{
	NSArray *sortedArray = [files sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		NSString *pathObj1 = [self.options.filePath stringByAppendingPathComponent:obj1];
		NSString *pathObj2 = [self.options.filePath stringByAppendingPathComponent:obj2];
		
		NSError *error = nil;
		NSDictionary *obj1Attr = [self.fileManager attributesOfItemAtPath:pathObj1 error:&error];
		NSDictionary *obj2Attr = [self.fileManager attributesOfItemAtPath:pathObj2 error:&error];
		
		return [[obj1Attr fileCreationDate] compare:[obj2Attr fileCreationDate]];
		
	}];
	
	return sortedArray;
}
-(NSString *)fileNameOfNewestFile:(NSArray<NSString*>*)files{
		//find file with most recent date stamp
	NSArray *sortedArray = files;
	if(sortedArray.count > 1){
		sortedArray = [self sortFilesByCreationDate:files];
	}
	return sortedArray.lastObject;
}

-(NSString *)fileNameOfOldestFile:(NSArray<NSString*>*)files{
	NSArray *sortedArray = files;
	if(sortedArray.count > 1){
		sortedArray = [self sortFilesByCreationDate:files];
	}
	return sortedArray.firstObject;
}
@end
