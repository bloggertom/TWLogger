//
//  TWSqliteLogger.m
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWSqliteLogger.h"
#import "TWAbstractLoggerProject.h"
#import <sqlite3.h>

@interface TWSqliteLogger()
@property (nonatomic)sqlite3 *database;
@end

@implementation TWSqliteLogger
-(instancetype)init{
	self = [super init];
	if(self){
		self.options.pageLife.day = 0;
		self.options.pageLife.month = 1;
	}
	return self;
}
-(void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function{
	if(_database == nil){
		NSError *error = nil;
		[self openOrCreateDatabase:self.options.loggingDirectory error:&error];
	}
}
-(BOOL)openOrCreateDatabase:(NSString *)loggingDirectory error:(NSError **)error{
	BOOL isDir;
	if(![self.fileManager fileExistsAtPath:loggingDirectory isDirectory:&isDir]){
		[self.fileManager createDirectoryAtPath:loggingDirectory withIntermediateDirectories:YES attributes:nil error:error];
		if(error){
			return NO;
		}
		isDir = YES;
	}
	if(isDir){
		NSString *databasePath = [loggingDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-Database.db",self.options.logFilePrefix]];
		int result = sqlite3_open(databasePath.UTF8String, &_database);
		if(result != SQLITE_OK){
			*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorFailedToOpenLog userInfo:@{NSLocalizedDescriptionKey: @"Unable to create/open file"}];
			return NO;
		}
	}else{
		*error = [NSError errorWithDomain:ERROR_DOMAIN code:TWLoggerErrorInvalidFilePath userInfo:@{NSLocalizedDescriptionKey: @"Invalid log storage directory."}];
		return NO;
	}
	return YES;
}

-(void)stopLogging{
	//close database and stuff;
	if(_database != nil){
		sqlite3_close(_database);
	}
}

@end
