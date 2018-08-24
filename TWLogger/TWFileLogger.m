//
//  TDWFileLogger.m
//  TWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWFileLogger.h"
#import "TWAbstractLogger.h"

@interface TWFileLogger()

@property (nonatomic, strong)NSFileHandle *currentLogHandle;
@property (nonatomic, strong)NSString *currentLogPath;

@end

@implementation TWFileLogger

-(instancetype)init{
	TWLoggerOptions *options = [[TWLoggerOptions alloc]init];
	options.maxPageNum = 80;
	options.maxPageSize = 0;
	options.pageLife = [[NSDateComponents alloc]init];
	options.pageLife.day = 1;
	
	return [self initWithOptions:options];
}

-(void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function{
	@synchronized(self){
		if(!self.isLogging || self.currentLogHandle == nil){
			[TWLog systemLog: @"Log received when logging not active"];
			return;
		}
	}
	NSError *error = nil;
	if([self logFileHasExpired:self.currentLogPath error:&error] || [self logFileHasReachedMaxSize:self.currentLogPath error:&error]){
		//check valid
		[self.currentLogHandle synchronizeFile];
		[self.currentLogHandle closeFile];
		self.currentLogPath = [self getLogFileUrl:&error];
		self.currentLogHandle = [NSFileHandle fileHandleForWritingAtPath:self.currentLogPath];
		//if there is metadata the file will already contain it.
		[self.currentLogHandle seekToEndOfFile];
	}
	if(error){
		[TWLog systemLog:@"Failed to create log file handle"];
		[TWLog systemLog:[NSString stringWithFormat:@"%@", error]];
		[self stopLogging];
		return;
	}
	NSString *logString = body;
	if(self.logFormatter){
		logString = [self.logFormatter formatLog:level body:body fromFile:file forFunction:function];
	}
	
	@try{
		[self.currentLogHandle writeData:[logString dataUsingEncoding:NSASCIIStringEncoding]];
		[self.currentLogHandle synchronizeFile];
	}@catch(NSException *e){
		//Possibly means something else is in control of the file.
		[TWLog systemLog:@"Failed to write to log"];
		[TWLog systemLog:e.name];
		[TWLog systemLog:e.reason];
		self.logging = NO;
	}
	
}

-(BOOL)startLogging{
	NSError *error = nil;
	if(_currentLogHandle == nil && !self.isLogging){
		_currentLogPath = [self getLogFileUrl:&error];
		if(_currentLogPath == nil){
			[self stopLoggingWithMessage:@"Failed to create log file" andError:error];
			return NO;
		}
		_currentLogHandle = [NSFileHandle fileHandleForWritingAtPath:self.currentLogPath];
		if(_currentLogHandle == nil){
			[self stopLoggingWithMessage:@"Failed to open logger" andError:[NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorFailedToOpenLog userInfo:@{NSLocalizedDescriptionKey: @"Unable to create/open file"}]];
			return NO;
		}
		[_currentLogHandle seekToEndOfFile];
	}
	self.logging = YES;
	return YES;
}

-(void)stopLogging{
	@synchronized(self){
		self.logging = NO;
		[self.currentLogHandle synchronizeFile];
		[self.currentLogHandle closeFile];
		self.currentLogHandle = nil;
	}
}

-(void)flushLogs{
	[self.currentLogHandle synchronizeFile];
}

-(NSString *)getLogFileUrl:(NSError **)error{
	BOOL isDirectory = NO;
	if(![self.fileManager fileExistsAtPath:self.options.loggingAddress isDirectory:&isDirectory]){
		if(![self.fileManager createDirectoryAtPath:self.options.loggingAddress withIntermediateDirectories:YES attributes:nil error:error]){
			return nil;
		}
		isDirectory = YES;
	}
	
	if(isDirectory){
		NSArray *files = [self.fileManager contentsOfDirectoryAtPath:self.options.loggingAddress error:error];
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
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorInvalidFilePath userInfo:@{NSLocalizedDescriptionKey: @"Invalid log storage directory."}];
	}
	
	return nil;
}

-(NSString *)urlToNewLogFile:(NSError **)error{
	NSInteger timestamp = (long long)([[NSDate date] timeIntervalSince1970] * 10000);
	NSString *fileName = [NSString stringWithFormat:@"%@-%lld.log",self.options.logFilePrefix, (long long)timestamp];

	NSString *fileUrl = [self.options.loggingAddress stringByAppendingPathComponent:fileName];
	NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:self.options.loggingAddress error:error];
	
	if(*error){
		return nil;
	}
	
	if(![self.fileManager createFileAtPath:fileUrl contents:nil attributes:nil]){
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorFailedToCreateLogFile userInfo:@{NSLocalizedDescriptionKey : @"Failed to create new log file"}];
		return nil;
	}
	if(self.options.metaData){
		NSString *metaData = [self createMetaDataString:self.options.metaData];
		
		if(![metaData writeToFile:fileUrl atomically:NO encoding:NSASCIIStringEncoding error:error]){
			[TWLog systemLog:@"Failed to write metadata to log file:"];
			[TWLog systemLog:metaData];
		}
	}
	contents = [contents arrayByAddingObject:fileName];
	if(self.options.maxPageNum > 0 && contents.count > self.options.maxPageNum){
		//Remove oldest file.
		if([self deleteOldestLog:contents error:error]){
			[TWLog systemLog:[NSString stringWithFormat:@"Failed to delete old log"]];
		}
	}
	
	return fileUrl;
}

-(NSString *)createMetaDataString:(NSDictionary *)metaData{
	if(metaData == nil || metaData.count == 0){
		return nil;
	}
	NSArray *allkeys = metaData.allKeys;
	NSMutableString *metaString = [[NSMutableString alloc]init];
	for (NSString *key in allkeys) {
		NSString *value = [metaData objectForKey:key];
		[metaString appendFormat:@"%@: %@/n", key, value ];
	}
	
	return metaString.copy;
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
	NSString *fileUrl = [self.options.loggingAddress stringByAppendingPathComponent:file];
	BOOL expired = [self logFileHasExpired:fileUrl error:error];
	BOOL full = [self logFileHasReachedMaxSize:fileUrl error:error];
	if(*error || expired || full){
		if(*error){
			[TWLog systemLog: [NSString stringWithFormat:@"%@",(*error)]];
			*error = nil;
		}
		return [self urlToNewLogFile:error];
	}
	return fileUrl;
}

-(BOOL)logFileHasExpired:(NSString *)logFile error:(NSError **)error{
	if(self.options.pageLife == nil){
		return NO;
	}
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:logFile error:error];
	if(*error){
		return NO;
	}
	NSDate *fileCreation = [fileAtt fileCreationDate];
	
	NSDate *expiryDate = [calendar dateByAddingComponents:self.options.pageLife toDate:fileCreation options:0];
	NSDate *now = [NSDate date];
	return ([expiryDate compare:now] == NSOrderedAscending || [expiryDate compare:now] == NSOrderedSame);
}

-(BOOL)logFileHasReachedMaxSize:(NSString *)logFile error:(NSError **)error{
	if(self.options.maxPageSize <= 0){
		return NO;
	}
	
	NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:logFile error:error];
	if(*error){
		return NO;
	}
	
	NSInteger sizeKb = [fileAtt fileSize]/1000;
	
	return sizeKb >= self.options.maxPageSize;
}

-(NSArray *)sortFilesByCreationDate:(NSArray *)files{
	NSArray *sortedArray = [files sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		NSString *pathObj1 = [self.options.loggingAddress stringByAppendingPathComponent:obj1];
		NSString *pathObj2 = [self.options.loggingAddress stringByAppendingPathComponent:obj2];
		
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
