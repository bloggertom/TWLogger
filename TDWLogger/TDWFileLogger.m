//
//  TDWFileLogger.m
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWFileLogger.h"
#import "TDWLog.h"

typedef NS_ENUM(NSUInteger, TDWFileLoggerError) {
	TDWFileLoggerErrorUnknown = 2000,
	TDWFileLoggerErrorInvalidFilePath = 2001,
};

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
	options.logFilePrefix = @"TDWLog";
	options.pageLife = [[NSDateComponents alloc]init];
	options.pageLife.day = 1;
	
	NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	path = [path stringByAppendingPathComponent:@"TDWLogsFiles"];
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

-(NSFileHandle *)getLogFileHandle:(NSError **)error{
	BOOL isDirectory = NO;
	if(![self.fileManager fileExistsAtPath:self.options.filePath.absoluteString isDirectory:&isDirectory]){
		if(![self.fileManager createDirectoryAtURL:self.options.filePath withIntermediateDirectories:YES attributes:nil error:error]){
			return nil;
		}
	}
	
	if(isDirectory){
		NSArray *files = [self.fileManager contentsOfDirectoryAtPath:self.options.filePath.absoluteString error:error];
		if(files.count == 0){
			if(error){
				return nil;
			}
			return [self handleToNewLogFile:error];
			
		}else{
			NSArray *logFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
				if([evaluatedObject isKindOfClass:[NSString class]]){
					NSString *fileName = (NSString *)evaluatedObject;
					return [fileName hasPrefix:self.options.logFilePrefix];
				}
				return NO;
			}]];
			
			return [self handleToExistingLogFile:logFiles error:error];
		}
	}else if(*error == nil){
		*error = [NSError errorWithDomain:@"TDWFileLogger" code:TDWFileLoggerErrorInvalidFilePath userInfo:@{NSLocalizedDescriptionKey: @"Invalid log storage directory."}];
	}
	
	return nil;
}

-(NSFileHandle *)handleToNewLogFile:(NSError **)error{
	NSString *fileName = [NSString stringWithFormat:@"%@-%f.log",self.options.logFilePrefix, [[NSDate date] timeIntervalSince1970]];
	
	NSURL *fileUrl = [self.options.filePath URLByAppendingPathComponent:fileName];
	
	if(![self.fileManager contentsOfDirectoryAtPath:fileUrl.absoluteString error:error]){
		return nil;
	}
	
	NSFileHandle *fileHanle = [NSFileHandle fileHandleForWritingToURL:fileUrl error:error];
	
	return fileHanle;
}

-(NSFileHandle *)handleToExistingLogFile:(NSArray<NSString *> *)files error:(NSError **)error{
	if(files.count == 0){
		return [self handleToNewLogFile:error];
	}
	
	//check it against options to ensure its valid
	NSString *file = [self fileNameOfNewestFile:files];
	
	//life time
	NSURL *fileUrl = [self.options.filePath URLByAppendingPathComponent:file];
	BOOL expired = [self logFileHasExpired:fileUrl error:error];
	if(error|| expired){
		return [self handleToNewLogFile:error];
	}
	
	//pageMaxSize
	BOOL logCapacityReached = [self logHasReachedCapacity:fileUrl error:error];
	if(error|| logCapacityReached){
		return [self handleToNewLogFile:error];
	}
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:fileUrl error:error];
	
	if(error){
		return nil;
	}
	[fileHandle seekToEndOfFile];
	
	return fileHandle;
}

-(BOOL)logHasReachedCapacity:(NSURL *)logFile error:(NSError **)error{
	NSDictionary *fileAtt = [self.fileManager attributesOfItemAtPath:logFile.absoluteString error:error];
	if([fileAtt fileSize] >= self.options.pageMaxSize *1000){
		return YES;
	}
	return NO;
}

-(BOOL)logFileHasExpired:(NSURL *)logFile error:(NSError **)error{
	
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
@end
