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
@property (nonatomic, strong)NSURL *currentLogUrl;

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
	NSError *error = nil;
	if(_currentLogHandle == nil){
		_currentLogUrl = [self getLogFileUrl:&error];
		if(_currentLogUrl == nil){
			[self stopLoggingWithMessage:@"Failed to create log file" andError:error];
			return;
		}
		_currentLogHandle = [NSFileHandle fileHandleForWritingToURL:self.currentLogUrl error:&error];
	}else if([self logFileHasExpired:self.currentLogUrl error:&error]){
		//check valid
		[self.currentLogHandle synchronizeFile];
		[self.currentLogHandle closeFile];
		self.currentLogUrl = [self getLogFileUrl:&error];
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

-(NSURL *)getLogFileUrl:(NSError **)error{
	BOOL isDirectory = NO;
	if(![self.fileManager fileExistsAtPath:self.options.filePath.absoluteString isDirectory:&isDirectory]){
		if(![self.fileManager createDirectoryAtPath:self.options.filePath.absoluteString withIntermediateDirectories:YES attributes:nil error:error]){
			return nil;
		}
		isDirectory = YES;
	}
	
	if(isDirectory){
		NSArray *files = [self.fileManager contentsOfDirectoryAtPath:self.options.filePath.absoluteString error:error];
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

-(NSURL *)urlToNewLogFile:(NSError **)error{
	NSString *fileName = [NSString stringWithFormat:@"%@-%f.log",self.options.logFilePrefix, [[NSDate date] timeIntervalSince1970]];
	
	NSURL *fileUrl = [self.options.filePath URLByAppendingPathComponent:fileName];
	NSArray *contents = [self.fileManager contentsOfDirectoryAtURL:self.options.filePath includingPropertiesForKeys:nil options:0 error:error];
	if(error){
		return nil;
	}
	
	if([self logHasReachedCapacity:contents error:error]){
		if([self deleteOldestLog:contents error:error]){
			[TDWLog systemLog:[NSString stringWithFormat:@"Failed to delete old log"]];
		}
	}
	
	if(![self.fileManager createFileAtPath:fileUrl.absoluteString contents:nil attributes:nil]){
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

-(NSURL *)urlToExistingLogFile:(NSArray<NSString *> *)files error:(NSError **)error{
	if(files.count == 0){
		return [self urlToNewLogFile:error];
	}
	
	//check it against options to ensure its valid
	NSString *file = [self fileNameOfNewestFile:files];
	
	//life time
	NSURL *fileUrl = [self.options.filePath URLByAppendingPathComponent:file];
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
		NSURL *filePath = [self.options.filePath URLByAppendingPathComponent:logFile];
		NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:filePath.absoluteString error:error];
		logsSize += [fileAtt fileSize];
	}
	logsSize = logsSize/1000;
	return (logsSize >= self.options.maxLogCacheCapacity);
}

-(BOOL)logFileHasExpired:(NSURL *)logFile error:(NSError **)error{
	if(self.options.pageLife == nil){
		return NO;
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:logFile.absoluteString error:error];
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
		NSURL *pathObj1 = [self.options.filePath URLByAppendingPathComponent:obj1];
		NSURL *pathObj2 = [self.options.filePath URLByAppendingPathComponent:obj2];
		
		NSError *error = nil;
		NSDictionary *obj1Attr = [self.fileManager attributesOfItemAtPath:pathObj1.absoluteString error:&error];
		NSDictionary *obj2Attr = [self.fileManager attributesOfItemAtPath:pathObj2.absoluteString error:&error];
		
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
